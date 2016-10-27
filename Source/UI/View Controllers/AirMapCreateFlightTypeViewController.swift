//
//  AirMapCreateFlightTypeViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/12/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import Mapbox
import GLKit
import RxSwift
import RxCocoa
import RxSwiftExt
import SwiftTurf

enum DrawingUIState: Equatable {
	case Panning
	case Drawing
	case Editing(ControlPoint)
}

func ==(lhs: DrawingUIState, rhs: DrawingUIState) -> Bool {
	return String(lhs) == String(rhs)
}

class RedAdvisory: MGLPolygon {}

class Buffer: MGLPolygon {}

class InvalidIntersection: NSObject, MGLAnnotation {
	
	var coordinate: CLLocationCoordinate2D
	
	init(coordinate: CLLocationCoordinate2D) {
		self.coordinate = coordinate
	}
}

class InvalidIntersectionView: MGLAnnotationView {
	
	init() {
		super.init(reuseIdentifier: String(InvalidIntersection))
		
		userInteractionEnabled = false
		scalesWithViewingDistance = false
	}
	
	override init(frame: CGRect) {
		super.init(frame: CGRectMake(0, 0, 35, 35))
		
		layer.backgroundColor = UIColor.clearColor().CGColor
		layer.zPosition = -100
		layer.borderWidth = 2
		layer.opacity = 0.5
		layer.borderColor = UIColor.airMapRed().CGColor
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		layer.cornerRadius = bounds.size.width / 2
	}
}

class AirMapCreateFlightTypeViewController: UIViewController {
	
	// MARK: Properties
	
	typealias Meters = CLLocationDistance

	@IBOutlet weak var mapView: AirMapMapView!
	@IBOutlet weak var actionButton: UIButton!
	@IBOutlet weak var bufferSlider: UISlider!
	@IBOutlet weak var bufferTitleLabel: UILabel!
	@IBOutlet weak var bufferValueLabel: UILabel!
	@IBOutlet weak var toolTip: UILabel!
	
	@IBOutlet var flightTypeButtons: [AirMapFlightTypeButton]!
	@IBOutlet weak var nextButton: UIButton!
	@IBOutlet weak var advisoriesInfoButton: UIButton!
	@IBOutlet weak var inputViewContainer: UIView!
	
	private let drawingOverlayView = AirMapDrawingOverlayView()
	private let editingOverlayView = AirMapPointEditingOverlay()
	private let mapViewDelegate = AirMapMapboxMapViewDelegate()

	private let geoTypes: [AirMapFlight.FlightGeometryType] = [.Point, .Path, .Polygon]
	private let selectedGeoType = Variable(AirMapFlight.FlightGeometryType.Point)
	private let controlPoints = Variable([ControlPoint]())
	private let state = Variable(DrawingUIState.Panning)
	private let buffer = Variable(Meters(304.8))
	
	private let controlPointsHidden = Variable(false)
	
	private var flight: AirMapFlight {
		return (navigationController as! AirMapFlightPlanNavigationController).flight.value
	}
	
	private let disposeBag = DisposeBag()
	
	override var inputAccessoryView: UIView? {
		return inputViewContainer
	}
	
	private static let bufferFormatter: NSNumberFormatter = {
		$0.numberStyle = .DecimalStyle
		$0.maximumFractionDigits = 0
		return $0
	}(NSNumberFormatter())
	
}

extension AirMapCreateFlightTypeViewController {
	
	// MARK: View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupMap()
		setupDrawingOverlay()
		setupEditingOverlay()
		setupBindings()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		drawingOverlayView.frame = mapView.frame
		editingOverlayView.frame = mapView.bounds
		
		// Insert the editing view below the annotations view
		if let mapGLKView = mapView.subviews.filter({ $0 is GLKView }).first {
			mapGLKView.insertSubview(editingOverlayView, atIndex: 0)
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let identifier = segue.identifier else { return }
		switch identifier {
		case "pushFlightDetails":
			let flightDetails = segue.destinationViewController as! AirMapFlightPlanViewController
			flightDetails.location = Variable(flight.coordinate)
		case "modalAdvisories":
			let nav = segue.destinationViewController as! UINavigationController
			let advisoriesVC = nav.viewControllers.first as! AirMapAdvisoriesViewController
			let status = (navigationController as! AirMapFlightPlanNavigationController).status.value!
			advisoriesVC.status = Variable(status)
		default:
			break
		}
	}
	
	@IBAction func unwindToFlightPlanMap(segue: UIStoryboardSegue) { /* IB hook; keep */ }
	
	override func canBecomeFirstResponder() -> Bool {
		return true
	}
	
}

extension AirMapCreateFlightTypeViewController {
	
	// MARK: Setup

	private func setupBindings() {
		
		typealias $ = AirMapCreateFlightTypeViewController
		
		let geoType = selectedGeoType.asDriver()
		let coordinates = controlPoints.asDriver()
			.map { $0.filter { $0.type == ControlPointType.Vertex }.map { $0.coordinate } }

		geoType
			.driveNext(unowned(self, $.configureForType))
			.addDisposableTo(disposeBag)
		
		geoType
			.throttle(0.25)
			.mapToVoid()
			.driveNext(unowned(self, $.centerFlightPlan))
			.addDisposableTo(disposeBag)
		
		buffer.asDriver()
			.skip(1)
			.throttle(0.25)
			.mapToVoid()
			.driveNext(unowned(self, $.centerFlightPlan))
			.addDisposableTo(disposeBag)

		state.asDriver()
			.driveNext(unowned(self, $.configureForState))
			.addDisposableTo(disposeBag)
		
		controlPoints.asDriver()
			.driveNext(unowned(self, $.drawControlPoints))
			.addDisposableTo(disposeBag)
	
		let snappedBuffer = bufferSlider.rx_value.asDriver()
			.map(unowned(self, $.sliderValueToBuffer))

		snappedBuffer.map { $0.displayString }
			.drive(bufferValueLabel.rx_text)
			.addDisposableTo(disposeBag)

		snappedBuffer.map { $0.buffer }
			.driveNext(unowned(self, $.drawNewProposedRadius))
			.addDisposableTo(disposeBag)

		snappedBuffer.map { $0.buffer }
			.throttle(0.25)
			.drive(buffer)
			.addDisposableTo(disposeBag)

		let validatedInput = Driver
			.combineLatest(geoType, coordinates, buffer.asDriver()) { [unowned self] geoType, coordinates, buffer in
				(geoType, coordinates, buffer, self.geometryValidation(geoType, coordinates: coordinates))
			}

		validatedInput
			.driveNext(unowned(self, $.drawFlightArea))
			.addDisposableTo(disposeBag)
		
		validatedInput
			.map { $0.3.valid }
			.drive(nextButton.rx_enabled)
			.addDisposableTo(disposeBag)

		let status = (navigationController as! AirMapFlightPlanNavigationController).status
		
		validatedInput
			.asObservable()
			.filter { $0.3.valid }
			.flatMapLatest(unowned(self, $.getStatus))
			.shareReplayLatestWhileConnected()
			.map { Optional.Some($0) }
			.bindTo(status)
		
		status
			.asObservable()
			.map { $0?.advisoryColor ?? .Gray }
			.asDriver(onErrorJustReturn: .Yellow)
			.driveNext(unowned(self, $.applyAdvisoryColorToNextButton))
			.addDisposableTo(disposeBag)

		status
			.asObservable()
			.unwrap()
			.map { $0.advisories.filter { $0.color == .Red } }
			.map { $0.map { $0.id as String } }
			.flatMapLatest { ids -> Observable<[AirMapAirspace]> in
				if ids.count == 0 {
					return .just([])
				} else {
					return AirMap.rx_listAirspace(ids)
				}
			}
			.asDriver(onErrorJustReturn: [])
			.driveNext(unowned(self, $.drawRedAdvisoryAirspaces))
			.addDisposableTo(disposeBag)

		status
			.asObservable()
			.map { $0 != nil }
			.asDriver(onErrorJustReturn: false)
			.drive(advisoriesInfoButton.rx_enabled)
			.addDisposableTo(disposeBag)
		
		controlPointsHidden.asDriver()
			.driveNext(mapView.hideControlPoints)
			.addDisposableTo(disposeBag)
	}
	
	private func setupMap() {
		
		mapView.centerCoordinate = flight.coordinate
		mapView.configure(layers: [], theme: .Standard)
		mapView.minimumZoomLevel = 8
		mapView.maximumZoomLevel = 22
		mapView.delegate = mapViewDelegate
		mapViewDelegate.controlPointDelegate = self
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleAnnotations))
		mapView.addGestureRecognizer(tapGesture)
		
		// Prevent calling of single tap for multi-tap gestures (i.e. double taps)
		mapView.gestureRecognizers?
			.flatMap { $0 as? UITapGestureRecognizer }
			.filter { $0.numberOfTapsRequired > 1 }
			.forEach { tapGesture.requireGestureRecognizerToFail($0) }
 	}
	
	@objc private func toggleAnnotations() {
		if selectedGeoType.value != .Point {
			controlPointsHidden.value = !controlPointsHidden.value
		}
	}
	
	private func setupDrawingOverlay() {
		
		drawingOverlayView.delegate = self
		drawingOverlayView.multipleTouchEnabled = false
		drawingOverlayView.backgroundColor = UIColor.airMapGray().colorWithAlphaComponent(0.333)
		view.insertSubview(drawingOverlayView, belowSubview: actionButton)
	}
	
	private func setupEditingOverlay() {
		
		editingOverlayView.backgroundColor = .clearColor()
		editingOverlayView.userInteractionEnabled = false
		// Editing overlay is inserted to the view hierarchy in viewDidLayoutSubviews
	}
	
	// MARK: Configure

	func configureForType(type: AirMapFlight.FlightGeometryType) {
		
		(navigationController as! AirMapFlightPlanNavigationController).status.value = nil
		
		if let annotations = mapView.annotations {
			mapView.removeAnnotations(annotations)
		}
		
		var radiusSliderAlpha: CGFloat = 1
		let radiusSliderOffset: CGFloat = 50
		var radiusSliderTransform: CGAffineTransform = CGAffineTransformMakeTranslation(0, -radiusSliderOffset)
		
		toolTip.superview!.superview!.hidden = false
		
		switch type {
			
		case .Path:
			drawingOverlayView.discardsDuplicateClosingPoint = false
			actionButton.hidden = false
			bufferTitleLabel.text = "Width"
			controlPoints.value = []

		case .Point:
			actionButton.hidden = true
			bufferTitleLabel.text = "Radius"
			toolTip.superview!.superview!.hidden = true
			controlPoints.value = [
				ControlPoint(type: .Vertex, coordinate: mapView.centerCoordinate)
			]

		case .Polygon:
			drawingOverlayView.discardsDuplicateClosingPoint = true
			actionButton.hidden = false
			controlPoints.value = []
			radiusSliderTransform = CGAffineTransformIdentity
			radiusSliderAlpha = 0
		}
		
		let animations = {
			self.mapView.logoView.transform = radiusSliderTransform
			self.mapView.attributionButton.transform = radiusSliderTransform
			self.bufferSlider.superview?.transform = CGAffineTransformConcat(radiusSliderTransform, CGAffineTransformMakeTranslation(0, radiusSliderOffset))
			self.bufferSlider.superview?.alpha = radiusSliderAlpha
		}

		UIView.animateWithDuration(0.3, delay: 0, options: [.BeginFromCurrentState], animations: animations, completion: nil)
		state.value = .Panning
	}
	
	func configureForState(state: DrawingUIState) {
	
		let bundle = NSBundle(forClass: AirMap.self)

		let drawIcon = UIImage(named: "draw_icon", inBundle: bundle, compatibleWithTraitCollection: nil)!
		let drawIconSelected = UIImage(named: "draw_icon_selected", inBundle: bundle, compatibleWithTraitCollection: nil)!

		let trashIcon = UIImage(named: "trash_icon", inBundle: bundle, compatibleWithTraitCollection: nil)
		let trashIconSelected = UIImage(named: "trash_icon_selected", inBundle: bundle, compatibleWithTraitCollection: nil)
		let trashIconHighlighted = UIImage(named: "trash_icon_highlighted", inBundle: bundle, compatibleWithTraitCollection: nil)
		toolTip.superview?.backgroundColor = UIColor.airMapGray().colorWithAlphaComponent(0.25)
		
		switch state {
		
		case .Panning:
			
			// No existing shape
			if controlPoints.value.count == 0 {
				
				switch selectedGeoType.value {
				case .Path:
					toolTip.text = "Tap the hand icon to freehand draw any path."
				case .Polygon:
					toolTip.text = "Tap the hand icon to freehand draw any area."
				case .Point:
					toolTip.text = "Drag the center point to position your flight area."
				}
				actionButton.setImage(drawIcon, forState: .Normal)
				actionButton.setImage(drawIconSelected, forState: .Highlighted)
				actionButton.setImage(drawIconSelected, forState: .Selected)
				actionButton.addTarget(self, action: #selector(toggleDrawing), forControlEvents: .TouchUpInside)
				
			// Has existing shape
			} else {
				
				let coordinates = controlPoints.value
					.filter { $0.type == .Vertex }
					.map { $0.coordinate }
				
				let validation = geometryValidation(selectedGeoType.value, coordinates: coordinates)

				if validation.kinks?.features.count > 0 {
					toolTip.text = "Invalid flight area. Adjust flight area so that it does not overlap with itself."
					toolTip.superview?.backgroundColor = UIColor.airMapRed().colorWithAlphaComponent(0.50)
				} else {
					toolTip.text = "Drag any point to move. Drag any midpoint to add a new point."
				}

				actionButton.setImage(trashIcon, forState: .Normal)
				actionButton.setImage(trashIconHighlighted, forState: .Highlighted)
				actionButton.setImage(trashIconSelected, forState: .Selected)
				actionButton.addTarget(self, action: #selector(deleteShape), forControlEvents: .TouchUpInside)
			}
			actionButton.selected = false
			actionButton.highlighted = false
			
			mapView.userInteractionEnabled = true
			drawingOverlayView.hidden = true
			editingOverlayView.clearPath()
			
			if selectedGeoType.value != .Point {
				mapView.hideControlPoints(false)
			}

		case .Drawing:
			
			switch selectedGeoType.value {
			case .Path:
				toolTip.text = "Draw a freehand path"
				drawingOverlayView.tolerance = 8
			case .Polygon:
				toolTip.text = "Draw a freehand area"
				drawingOverlayView.tolerance = 11
			case .Point:
				fatalError()
			}
			
			actionButton.setImage(drawIcon, forState: .Normal)
			actionButton.setImage(drawIconSelected, forState: .Highlighted)
			actionButton.setImage(drawIconSelected, forState: .Selected)
			actionButton.selected = true
			actionButton.highlighted = false
			actionButton.addTarget(self, action: #selector(toggleDrawing), forControlEvents: .TouchUpInside)
		
			mapView.userInteractionEnabled = false
			drawingOverlayView.hidden = false
		
		case .Editing(let controlPoint):
			
			if canDelete(controlPoint) {
				toolTip.text = "Drag point to trash to delete"
			}
			actionButton.setImage(trashIcon, forState: .Normal)
			actionButton.setImage(trashIconHighlighted, forState: .Highlighted)
			actionButton.setImage(trashIconSelected, forState: .Selected)
			actionButton.addTarget(self, action: #selector(deleteShape), forControlEvents: .TouchUpInside)
			
			mapView.userInteractionEnabled = true
			drawingOverlayView.hidden = true
			if selectedGeoType.value != .Point {
				mapView.hideControlPoints(true)
			}
		}
		
		mapView.hideObscuredMidPointControls()
	}
	
	private func sliderValueToBuffer(sliderValue: Float) -> (buffer: Meters, displayString: String) {
		
		let formatter = AirMapCreateFlightTypeViewController.bufferFormatter
		
		let ramp = Config.Maps.bufferSliderLinearity
		var sliderValue = pow(Double(sliderValue), ramp)

		let usesMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)!.boolValue!
		let distancePerStep: Double
		
		if usesMetric {

			let minRadius = 5.0
			let maxRadius = 1000.0
			var meters = (sliderValue * (maxRadius - minRadius)) + minRadius
			switch meters {
			case 50..<200:
				distancePerStep = 10
			case 200..<750:
				distancePerStep = 50
			case 750..<1000:
				distancePerStep = 100
			default:
				distancePerStep = 5
			}
			meters = ceil(meters / distancePerStep) * distancePerStep
		
			return (meters, formatter.stringFromNumber(meters)! + " m")

		} else {
			
			let minRadius = 25.0 / Config.Maps.feetPerMeters
			let maxRadius = 3000.0 / Config.Maps.feetPerMeters
			var meters = (sliderValue * (maxRadius - minRadius)) + minRadius
			var feet = meters * Config.Maps.feetPerMeters
			switch feet {
			case 200..<500:
				distancePerStep = 50
			case 500..<1000:
				distancePerStep = 100
			case 1000..<2000:
				distancePerStep = 250
			case 2000..<3000:
				distancePerStep = 500
			default:
				distancePerStep = 25
			}
			feet = ceil(feet / distancePerStep) * distancePerStep
			meters = feet / Config.Maps.feetPerMeters
			
			return (meters, formatter.stringFromNumber(feet)! + " ft")
		}
	}
	
	// MARK: Actions

	@IBAction func selectFlightMode(_ button: AirMapFlightTypeButton) {
		
		flightTypeButtons.forEach { $0.selected = false }
		button.selected = true
		
		let index = flightTypeButtons.indexOf(button)!
		let geoType = geoTypes[index]
		
		switch geoType {
		case .Point:
			bufferSlider.value = 0.5667
		case .Path:
			bufferSlider.value = 20/1000
		default:
			break
		}
		
		bufferSlider.sendActionsForControlEvents(.ValueChanged)
		self.selectedGeoType.value = geoType
	}
	
	@objc private func toggleDrawing() {
		
		switch state.value {
		case .Drawing:
			state.value = .Panning
		default:
			state.value = .Drawing
		}
	}

	@IBAction func deleteShape() {
		
		controlPoints.value = []
		state.value = .Panning
		(navigationController as! AirMapFlightPlanNavigationController).status.value = nil
	}
		
	@IBAction func dismiss() {
		dismissViewControllerAnimated(true, completion: nil)
	}

	// MARK: Getters
	
	private func midPointControlPoints(from controlPoints: [ControlPoint]) -> [ControlPoint] {
		
		let midPointCoordinates: [CLLocationCoordinate2D] = controlPoints.enumerate().flatMap { index, controlPoint in
			
			let lCoord = controlPoint.coordinate
			let rCoord: CLLocationCoordinate2D
			if index == controlPoints.endIndex-1 {
				rCoord = controlPoints[controlPoints.startIndex].coordinate
			} else {
				rCoord = controlPoints[index+1].coordinate
			}
			
			let lPoint = mapView.convertCoordinate(lCoord, toPointToView: mapView)
			let rPoint = mapView.convertCoordinate(rCoord, toPointToView: mapView)
			
			let midPoint = CGPoint(x: (lPoint.x + rPoint.x)/2, y: (lPoint.y + rPoint.y)/2)
			
			return mapView.convertPoint(midPoint, toCoordinateFromView: mapView)
		}
		
		var midPointControlPoints: [ControlPoint] = midPointCoordinates.map {
			ControlPoint(type: .MidPoint, coordinate: $0)
		}
		
		if selectedGeoType.value == .Path {
			midPointControlPoints.removeLast()
		}
		
		return midPointControlPoints
	}
	
	private func neighbors(of controlPoint: ControlPoint, distance: Int) -> (prev: ControlPoint?, next: ControlPoint?) {
		
		let index = controlPoints.value.indexOf(controlPoint)! + controlPoints.value.endIndex // add endIndex to enable wrapping
		
		let prevIndex = (index-distance) % controlPoints.value.endIndex
		let nextIndex = (index+distance) % controlPoints.value.endIndex
		
		let prevPoint = controlPoints.value[prevIndex]
		let nextPoint = controlPoints.value[nextIndex]

		if selectedGeoType.value == .Path {
			switch controlPoint {
			case controlPoints.value.first!:
				return (nil, nextPoint)
			case controlPoints.value.last!:
				return (prevPoint, nil)
			default:
				return (prevPoint, nextPoint)
			}
		} else {
			return (prevPoint, nextPoint)
		}
	}

	private func canDelete(controlPoint: ControlPoint) -> Bool {

		let isVertex = controlPoint.type == .Vertex
		let vertexCount = controlPoints.value.filter{ $0.type == .Vertex }.count
		
		switch selectedGeoType.value {
		case .Point:
			return false
		case .Path:
			return isVertex && vertexCount > 2
		case .Polygon:
			return isVertex && vertexCount > 3
		}
	}
	
	private func geometryValidation(geoType: AirMapFlight.FlightGeometryType, coordinates: [CLLocationCoordinate2D]) -> (valid: Bool, kinks: FeatureCollection?) {
		
		switch geoType {
		case .Point:
			return (coordinates.count == 1, nil)
		case .Polygon:
			guard coordinates.count >= 3 else { return (false, nil) }
			let polygon = Polygon(geometry: [coordinates + [coordinates.first!]])
			let kinks = SwiftTurf.kinks(polygon)!
			return (coordinates.count >= 3 && kinks.features.count == 0, kinks)
		case .Path:
			return (coordinates.count >= 2, nil)
		}
	}
	
	// MARK: Status
	
	private func getStatus(type: AirMapFlight.FlightGeometryType, coordinates: [CLLocationCoordinate2D], buffer: Meters = 0, validation: (isValid: Bool, kinks: FeatureCollection?)) -> Observable<AirMapStatus> {
		
		switch type {
		case .Point:
			return AirMap.rx_checkCoordinate(coordinates.first!, buffer: buffer)
		case .Polygon:
			return AirMap.rx_checkPolygon(coordinates, takeOffPoint: coordinates.first!)
		case .Path:
			return AirMap.rx_checkFlightPath(coordinates, buffer: Int(round(buffer)), takeOffPoint: coordinates.first!)
		}
	}
	
	private func applyAdvisoryColorToNextButton(advisoryColor: AirMapStatus.StatusColor) {
		
		switch advisoryColor {
		case .Red, .Gray:
			inputViewContainer.backgroundColor = advisoryColor.colorRepresentation
			inputViewContainer.tintColor = .whiteColor()
		case .Yellow, .Green:
			inputViewContainer.backgroundColor = advisoryColor.colorRepresentation
			inputViewContainer.tintColor = .airMapGray()
		}
		nextButton.setTitleColor(nextButton.tintColor.colorWithAlphaComponent(0.5), forState: .Disabled)
	}
	
	// MARK: Drawing
	
	private func drawControlPoints(points: [ControlPoint]) {
		
		let existingControlPoints = mapView.annotations?.filter { $0 is ControlPoint } ?? []
		mapView.removeAnnotations(existingControlPoints)
		mapView.addAnnotations(points)
	}
	
	private func drawNewProposedRadius(radius: Meters = 0) {
		
		guard controlPoints.value.count > 0 else { return }
		
		switch self.selectedGeoType.value {
			
		case .Point:
			let centerPoint = controlPoints.value.first!
			state.value = .Editing(centerPoint)
			let point = Point(geometry: centerPoint.coordinate)
			let bufferedPoint = SwiftTurf.buffer(point, distance: radius, units: .Meters)
			var proposedCoords = bufferedPoint?.geometry.first ?? []
			let proposedPoints = proposedCoords.map { mapView.convertCoordinate($0, toPointToView: mapView) }
			editingOverlayView.drawProposedPath(along: [proposedPoints])
			
		case .Path:
			let pathCoordinates = controlPoints.value.map { $0.coordinate }
			let lineString = LineString(geometry: pathCoordinates)
			guard let bufferedPath = SwiftTurf.buffer(lineString, distance: radius / 2) else { return }
			let proposedPoints = bufferedPath.geometry.map {
				$0.map { mapView.convertCoordinate($0, toPointToView: mapView)
				}
			}
			editingOverlayView.drawProposedPath(along: proposedPoints)
			
		case .Polygon:
			// Polygons don't support a buffer -- yet
			break
		}
	}
	
	private func drawFlightArea(geoType: AirMapFlight.FlightGeometryType, coordinates: [CLLocationCoordinate2D], buffer: Meters = 0, validation: (valid: Bool, kinks: FeatureCollection?)) {
		
		controlPointsHidden.value = false

		mapView.annotations?
			.filter { ($0 is MGLPolygon || $0 is MGLPolyline || $0 is InvalidIntersection) && !($0 is RedAdvisory) }
			.forEach { mapView.removeAnnotation($0) }
		
		switch geoType {
			
		case .Point:
			guard coordinates.count == 1 else { return }

			let point = AirMapPoint()
			point.coordinate = coordinates.first!
			
			flight.geometry = point
			flight.coordinate = point.coordinate
			flight.buffer = buffer
			
			if let annotations = flight.annotationRepresentations() {
				mapView.addAnnotations(annotations)
			}
			
		case .Path:
			guard coordinates.count >= 2 else { return }
			
			let pathGeometry = AirMapPath()
			pathGeometry.coordinates = coordinates
			
			flight.geometry = pathGeometry
			flight.coordinate = coordinates.first!
			flight.buffer = buffer / 2
			
			if let annotations = flight.annotationRepresentations() {
				mapView.addAnnotations(annotations)
			}
			
		case .Polygon:
			guard coordinates.count >= 3 else { return }
			
			let polygonGeometry = AirMapPolygon()
			polygonGeometry.coordinates = coordinates
			
			flight.geometry = polygonGeometry
			flight.coordinate = coordinates.first!
			flight.buffer = buffer

			if let annotations = flight.annotationRepresentations() {
				mapView.addAnnotations(annotations)
			}
			drawInvalidIntersections(validation.kinks)
		}

		state.value = .Panning
	}
	
	private func drawInvalidIntersections(kinks: FeatureCollection?) {
		
		guard let kinks = kinks else { return }
		
		for kink in kinks.features.flatMap({ $0 as? Point }) {
			let invalidIntersection = InvalidIntersection(coordinate: kink.geometry)
			mapView.addAnnotation(invalidIntersection)
		}
	}
	
	private func drawRedAdvisoryAirspaces(airspaces: [AirMapAirspace]) {
		
		let existingRedAdvisories = mapView.annotations?.flatMap { $0 as? RedAdvisory} ?? []
		mapView.removeOverlays(existingRedAdvisories)
		
		let redGeometries: [RedAdvisory] = airspaces
			.flatMap { $0.propertyBoundary as? AirMapPolygon }
			.map { polygon in
				var coords = polygon.coordinates as [CLLocationCoordinate2D]
				return RedAdvisory(coordinates: &coords, count: UInt(coords.count))
			}
		
		mapView.addOverlays(redGeometries)
	}
	
	private func centerFlightPlan() {
		if let annotations = mapView.annotations?.filter( { !($0 is RedAdvisory) }) {
			
			let insets: UIEdgeInsets
			switch selectedGeoType.value {
			case .Path:
				insets = UIEdgeInsetsMake(80, 45, 70, 45)
			case .Polygon:
				insets = UIEdgeInsetsMake(80, 45, 20, 45)
			case .Point:
				insets = UIEdgeInsetsMake(10, 45, 60, 45)
			}
			
			mapView.showAnnotations(annotations, edgePadding: insets, animated: true)
		}
	}
	
	private func position(midControlPoint: ControlPoint, between controlpoints: (prev: ControlPoint?, next: ControlPoint?)) {
		
		guard let prev = controlpoints.prev, let next = controlpoints.next else { return }

		let prevCoord = prev.coordinate
		let nextCoord = next.coordinate
		
		let prevPoint = mapView.convertCoordinate(prevCoord, toPointToView: mapView)
		let nextPoint = mapView.convertCoordinate(nextCoord, toPointToView: mapView)
		
		let midPoint = CGPoint(x: (prevPoint.x + nextPoint.x)/2, y: (prevPoint.y + nextPoint.y)/2)
		
		midControlPoint.coordinate = mapView.convertPoint(midPoint, toCoordinateFromView: mapView)
	}
}

extension AirMapCreateFlightTypeViewController: DrawingOverlayDelegate {
	
	func overlayDidDraw(geometry: [CGPoint]) {
		
		let bottomPadding: CGFloat
		
		let coordinates = geometry.map { point in
			mapView.convertPoint(point, toCoordinateFromView: drawingOverlayView)
		}

		// Validate drawn input
		// Discard shapes not meeting minimum/maximum number of points
		switch selectedGeoType.value {
		case .Path:
			guard coordinates.count > 1 && coordinates.count <= 25 else { return }
		case .Polygon:
			guard coordinates.count > 2 else { return }
			// Discard polygons with too many self-intersections
			let polygon = Polygon(geometry: [coordinates])
			guard SwiftTurf.kinks(polygon)?.features.count <= 5 else { return }
		case .Point:
			fatalError("Point-based shapes don't draw freehand geometry")
		}
		
		let vertexControlPoints: [ControlPoint] = coordinates.map {
			ControlPoint(type: .Vertex, coordinate: $0)
		}
		let midPointControlPoints = self.midPointControlPoints(from: vertexControlPoints)
		var controlPoints = zip(vertexControlPoints, midPointControlPoints).flatMap { [$0.0, $0.1] }
		
		if selectedGeoType.value == .Path {
			controlPoints.append(vertexControlPoints.last!)
		}
		
		self.controlPoints.value = controlPoints
		
		state.value = .Panning

		centerFlightPlan()
	}
}

extension AirMapCreateFlightTypeViewController: ControlPointDelegate {
	
	func didStartDragging(controlPoint: ControlPointView) {
		
		mapView.hideControlPoints(true)
	}
	
	func didDrag(controlPointView: ControlPointView, to point: CGPoint) {
		
		guard let controlPoint = controlPointView.controlPoint else { return }
		let controlPointCoordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)
		
		state.value = .Editing(controlPoint)
		
		// shrink the control point so that the drag can break out sooner
		UIView.performWithoutAnimation { 
			controlPointView.transform = CGAffineTransformMakeScale(0.1, 0.1)
		}
		
		switch selectedGeoType.value {
		
		case .Point:

			let point = Point(geometry: controlPointCoordinate)
			let bufferedPoint = SwiftTurf.buffer(point, distance: buffer.value, units: .Meters)
			let coordinates = bufferedPoint?.geometry.first ?? []
			let points = coordinates.map { mapView.convertCoordinate($0, toPointToView: mapView) }
			editingOverlayView.drawProposedPath(along: [points])

		case .Polygon, .Path:
			
			let distance = controlPoint.type == .MidPoint ? 1 : 2
			let neighbors = self.neighbors(of: controlPoint, distance: distance)
			let points = [neighbors.prev, ControlPoint(coordinate: controlPointCoordinate), neighbors.next]
				.flatMap { $0 }
				.map { mapView.convertCoordinate($0.coordinate, toPointToView: mapView) }
			
			editingOverlayView.drawProposedPath(along: [points])
			
			if canDelete(controlPoint) {
				actionButton.highlighted = true
				if actionButton.bounds.contains(point) {
					actionButton.highlighted = false
					actionButton.selected = true
				}
			}
		}
	}
	
	func didEndDragging(controlPointView: ControlPointView) {
		
		controlPointView.transform = CGAffineTransformIdentity

		guard let controlPoint = controlPointView.controlPoint else { return }
		
		switch selectedGeoType.value {
		
		case .Path, .Polygon:
		
			let isPath = selectedGeoType.value == .Path
			let hitPoint = mapView.convertCoordinate(controlPoint.coordinate, toPointToView: mapView)
			let shouldDeletePoint = canDelete(controlPoint) && actionButton.bounds.contains(hitPoint)

			switch controlPoint.type {
				
			case .Vertex:

				let midPoints = neighbors(of: controlPoint, distance: 1)
				if shouldDeletePoint {
					let controlPointsToDelete: [ControlPoint]
					if controlPoint == controlPoints.value.first {
						controlPointsToDelete = [controlPoint, midPoints.next].flatMap { $0 }
					} else {
						controlPointsToDelete = [controlPoint, midPoints.prev].flatMap { $0 }
					}
					controlPoints.value.removeObjectsInArray(controlPointsToDelete)
					mapView.annotations?
						.flatMap { $0 as? ControlPoint }
						.filter { $0.type == .MidPoint }
						.forEach { midPoint in
							let vertices = neighbors(of: midPoint, distance: 1)
							position(midPoint, between: vertices)
					}
				} else {
					for midPoint in [midPoints.prev, midPoints.next].flatMap({$0}) {
						let vertices = neighbors(of: midPoint, distance: 1)
						position(midPoint, between: vertices)
					}
				}
				
			case .MidPoint:
				
				controlPoint.type = .Vertex
				
				let left = ControlPoint(type: .MidPoint)
				let right = ControlPoint(type: .MidPoint)
				
				let index = controlPoints.value.indexOf(controlPoint)!
				controlPoints.value.insert(left, atIndex: index)
				controlPoints.value.insert(right, atIndex: index+2)
				
				position(left, between: neighbors(of: left, distance: 1))
				position(right, between: neighbors(of: right, distance: 1))
			}

		case .Point:
			break
		}
		
		controlPoints.value = controlPoints.value
		editingOverlayView.clearPath()
		state.value = .Panning
	}

}
