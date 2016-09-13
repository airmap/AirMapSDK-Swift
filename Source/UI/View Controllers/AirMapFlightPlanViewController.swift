//
//  AirMapFlightPlanViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Mapbox
import RxSwift
import RxCocoa
import RxDataSources
import RxSwiftExt

protocol TableRow {}

protocol TableSection {
	var title: String? { get }
	var rows: [TableRow] { get }
}

struct DataSection: TableSection {
	var title: String?
	var rows: [TableRow]
}

struct AssociatedObjectsSection: TableSection {
	var title: String?
	var rows: [TableRow]
}

struct SocialSection: TableSection {
	var title: String?
	var rows: [TableRow]
}

struct FlightPlanDataTableRow<T>: TableRow {
	typealias ValueType = T
	var title: Variable<String>
	var value: Variable<T>
	var values: [(title: String, value: Double)]?
}

struct AssociatedPilotModelRow: TableRow {
	var title: Variable<String>
	var value: Variable<AirMapPilot?>
}

struct AssociatedAircraftModelRow: TableRow {
	var title: Variable<String>
	var value: Variable<AirMapAircraft?>
}

struct SocialSharingRow: TableRow {
	var logo: UIImage
	var value: Variable<Bool>
}

class AirMapFlightPlanViewController: UIViewController {

	var location: Variable<CLLocationCoordinate2D>!

	@IBOutlet weak var mapView: AirMapMapView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var nextButton: UIButton!
	
	private let altitude = Variable(UIConstants.defaultAltitudePreset.value)
	private var startsAt = Variable(nil as NSDate?)
	private let duration = Variable(UIConstants.defaultDurationPreset.value)
	private let pilot    = Variable(nil as AirMapPilot?)
	private let aircraft = Variable(nil as AirMapAircraft?)

	private var sections = [TableSection]()
	private let disposeBag = DisposeBag()
	private let activityIndicator = ActivityIndicator()
	
	private let mapViewDelegate = AirMapMapboxMapViewDelegate()

	override var navigationController: AirMapFlightPlanNavigationController? {
		return super.navigationController as? AirMapFlightPlanNavigationController
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		setupTable()
		setupMap()
		setupBindings()

		AirMap.rx_getAuthenticatedPilot()
			.trackActivity(activityIndicator)
			.asOptional()
			.doOnNext { [weak self] pilot in
				self?.navigationController?.flight.value.pilot = pilot
			}
			.bindTo(pilot)
			.addDisposableTo(disposeBag)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let identifier = segue.identifier else { return }

		switch identifier {

		case "modalAircraft":
			let cell = sender as! AirMapFlightAircraftCell
			let nav = segue.destinationViewController as! UINavigationController
			let aircraftVC = nav.viewControllers.last as! AirMapAircraftViewController
			let selectedAircraft = aircraftVC.selectedAircraft.asObservable()
			selectedAircraft.delaySubscription(1.0, scheduler: MainScheduler.instance).bindTo(cell.aircraft).addDisposableTo(disposeBag)
			selectedAircraft.bindTo(aircraft).addDisposableTo(disposeBag)
			aircraftVC.selectedAircraft.value = aircraft.value

		case "modalProfile":
			let nav = segue.destinationViewController as! UINavigationController
			let profileVC = nav.viewControllers.last as! AirMapPilotProfileViewController
			profileVC.pilot = pilot

		case "modalFAQ":
			let nav = segue.destinationViewController as! UINavigationController
			let faqVC = nav.viewControllers.last as! AirMapFAQViewController
			faqVC.section = .LetOthersKnow

		default:
			break
		}
	}

	@IBAction func unwindToFlightPlan(segue: UIStoryboardSegue) { /* unwind segue hook; keep */ }

	private func setupTable() {

		let flightDataSection =  DataSection(title: "Flight", rows: [
			FlightPlanDataTableRow(title: Variable("Altitude"), value: altitude, values: UIConstants.altitudePresets),
			])
		sections.append(flightDataSection)

		let flightTimeSection =  DataSection(title: "Date & Time", rows: [
			FlightPlanDataTableRow(title: Variable("Starts"), value: startsAt, values: nil),
			FlightPlanDataTableRow(title: Variable("Duration"), value: duration, values: UIConstants.durationPresets)
			])
		sections.append(flightTimeSection)

		let associatedModels = AssociatedObjectsSection(title: "Pilot & Aircraft", rows: [
			AssociatedPilotModelRow(title: Variable("Select Pilot Profile"), value: pilot),
			AssociatedAircraftModelRow(title: Variable("Select Aircraft"), value: aircraft)
			]
		)
		sections.append(associatedModels)

		let bundle = NSBundle(forClass: AirMap.self)
		let image = UIImage(named: "airmap_share_logo", inBundle: bundle, compatibleWithTraitCollection: nil)

		let shareSection = SocialSection(title: "Share My Flight", rows: [
			SocialSharingRow(logo: image!, value: navigationController!.shareFlight)
			])
		sections.append(shareSection)
	}
	
	private func setupMap() {
		
		let flight = navigationController!.flight.value
		mapView.configure(layers: [], theme: .Light)
		mapView.delegate = mapViewDelegate
		
		if let annotations = navigationController?.flight.value.annotationRepresentations() {
			mapView.addAnnotations(annotations)
			dispatch_async(dispatch_get_main_queue()) {
				self.mapView.showAnnotations(annotations, edgePadding: UIEdgeInsetsMake(10, 40, 10, 40), animated: true)
			}
		}
	}

	private func setupBindings() {
		
		let flight = navigationController!.flight
		let status = navigationController!.status
		let shareFlight = navigationController!.shareFlight
		let requiredPermits = navigationController!.requiredPermits

		altitude.asObservable()
			.subscribeNext { flight.value.maxAltitude = $0 }
			.addDisposableTo(disposeBag)

		aircraft.asObservable()
			.subscribeNext { flight.value.aircraft = $0 }
			.addDisposableTo(disposeBag)

		pilot.asObservable()
			.unwrap()
			.subscribeNext { flight.value.pilotId = $0.pilotId }
			.addDisposableTo(disposeBag)

		status.asObservable()
			.map {
				let advisories = $0?.advisories ?? []
				let requirements = advisories.map { $0.requirements }.flatMap { $0 }
				let hasNextSteps = requirements.count > 0
				return hasNextSteps ? "Next" : "Save"
			}
			.subscribeNext { [unowned self] title in
				self.nextButton.setTitle(title, forState: .Normal)
			}
			.addDisposableTo(disposeBag)

		status.asObservable()
			.unwrap()
			.map { $0.advisories
				// Bind all required permits
				.map { $0.requirements?.permitsAvailable }
				.flatMap { $0 }
				.flatMap { $0 } ?? []
			}
			.bindTo(requiredPermits)
			.addDisposableTo(disposeBag)

		shareFlight.asObservable()
			.subscribeNext { flight.value.isPublic = $0 }
			.addDisposableTo(disposeBag)

		tableView.rx_itemSelected.subscribeNext { [unowned self] indexPath in
			self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
			self.tableView.cellForRowAtIndexPath(indexPath)?.becomeFirstResponder()
			}
			.addDisposableTo(disposeBag)

		Observable.combineLatest(startsAt.asObservable(), duration.asObservable()) { ($0, $1)}
			.subscribeNext { start, duration in
				flight.value.startTime = start
				flight.value.duration = duration
			}
			.addDisposableTo(disposeBag)
		
		activityIndicator.asObservable()
			.throttle(0.25, scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bindTo(rx_loading)
			.addDisposableTo(disposeBag)
	}

	@IBAction func next() {

		let status = navigationController!.status.value!

		if status.numberOfRequiredPermits > 0 {
			performSegueWithIdentifier("pushPermits", sender: self)
		} else if status.numberOfNoticesRequired > 0 {
			performSegueWithIdentifier("pushNotices", sender: self)
		} else {
			AirMap.rx_createFlight(navigationController!.flight.value)
				.trackActivity(activityIndicator)
				.doOnError { [weak self] error in
					self?.navigationController!.flightPlanDelegate.airMapFlightPlanDidEncounter(error as! NSError)
				}
				.subscribeNext(navigationController!.flightPlanDelegate.airMapFlightPlanDidCreate)
				.addDisposableTo(disposeBag)
		}
	}
	
}

extension AirMapFlightPlanViewController: UITableViewDataSource, UITableViewDelegate {

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return sections.count
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].rows.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		let section = sections[indexPath.section]
		let row = section.rows[indexPath.row]

		switch section {

		case is DataSection:

			switch row {
				
			case let doubleRow as FlightPlanDataTableRow<Double>:
				let cell = tableView.dequeueReusableCellWithIdentifier("flightDataCell", forIndexPath: indexPath) as! AirMapFlightDataCell
				cell.model = doubleRow
				return cell

			case let dateRow as FlightPlanDataTableRow<NSDate?>:
				let cell = tableView.dequeueReusableCellWithIdentifier("startsAtCell", forIndexPath: indexPath) as! AirMapFlightDataDateCell
				cell.model = dateRow
				return cell
				
			default:
				fatalError()
			}

		case is AssociatedObjectsSection:

			switch row {

			case is AssociatedPilotModelRow:
				let cell = tableView.dequeueCell(at: indexPath) as AirMapFlightPilotCell
				cell.pilot = pilot
				return cell

			case is AssociatedAircraftModelRow:
				let cell = tableView.dequeueCell(at: indexPath) as AirMapFlightAircraftCell
				cell.aircraft.asObservable().bindTo(aircraft).addDisposableTo(disposeBag)
				return cell

			default:
				fatalError()
			}

		case is SocialSection:
			let cell = tableView.dequeueCell(at: indexPath) as AirMapFlightSocialCell
			let row = row as! SocialSharingRow
			cell.model = row
			cell.toggle.rx_value.asObservable().bindTo(row.value).addDisposableTo(disposeBag)
			return cell

		default:
			fatalError()
		}
	}

	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return sections[section].title == nil ? 0 : 25
	}

	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sections[section].title
	}

}
