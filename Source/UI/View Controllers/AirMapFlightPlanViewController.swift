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

class AirMapFlightPlanViewController: UIViewController, AnalyticsTrackable {

	var screenName = "Create Flight - Details"
	var location: Variable<CLLocationCoordinate2D>!

	@IBOutlet weak var mapView: AirMapMapView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var nextButton: UIButton!
	
	fileprivate let altitude = Variable(0 as Double)
	fileprivate var startsAt = Variable(nil as Date?)
	fileprivate let duration = Variable(UIConstants.defaultDurationPreset.value)
	fileprivate let pilot    = Variable(nil as AirMapPilot?)
	fileprivate let aircraft = Variable(nil as AirMapAircraft?)

	fileprivate var sections = [TableSection]()
	fileprivate let disposeBag = DisposeBag()
	fileprivate let activityIndicator = ActivityIndicator()
	
	fileprivate let mapViewDelegate = AirMapMapboxMapViewDelegate()

	override var navigationController: AirMapFlightPlanNavigationController? {
		return super.navigationController as? AirMapFlightPlanNavigationController
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		switch AirMap.configuration.distanceUnits {
		case .metric:
			altitude.value = UIConstants.defaultAltitudePresetMeters.value
		case .imperial:
			altitude.value = UIConstants.defaultAltitudePresetFeet.value
		}
		
		setupTable()
		setupMap()
		setupBindings()

		AirMap.rx.getAuthenticatedPilot()
			.trackActivity(activityIndicator)
			.asOptional()
			.do( onNext: { [weak self] pilot in
				self?.navigationController?.flight.value.pilot = pilot
			})
			.bindTo(pilot)
			.disposed(by: disposeBag)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		trackView()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let identifier = segue.identifier else { return }

		switch identifier {

		case "modalAircraft":
			let cell = sender as! AirMapFlightAircraftCell
			let nav = segue.destination as! UINavigationController
			let aircraftVC = nav.viewControllers.last as! AirMapAircraftViewController
			let selectedAircraft = aircraftVC.selectedAircraft.asObservable()
			selectedAircraft.delaySubscription(1.0, scheduler: MainScheduler.instance).bindTo(cell.aircraft).disposed(by: disposeBag)
			selectedAircraft.bindTo(aircraft).disposed(by: disposeBag)
			aircraftVC.selectedAircraft.value = aircraft.value
			trackEvent(.tap, label: "Select Aircraft")

		case "modalProfile":
			let nav = segue.destination as! UINavigationController
			let profileVC = nav.viewControllers.last as! AirMapPilotProfileViewController
			profileVC.pilot = pilot
			trackEvent(.tap, label: "Select Pilot")

		case "modalFAQ":
			let nav = segue.destination as! UINavigationController
			let faqVC = nav.viewControllers.last as! AirMapFAQViewController
			faqVC.section = .LetOthersKnow
			
		default:
			break
		}
	}

	@IBAction func unwindToFlightPlan(_ segue: UIStoryboardSegue) { /* unwind segue hook; keep */ }

	fileprivate func setupTable() {
		
		let altitudeValues: [(title: String, value: CLLocationDistance)]
		switch AirMap.configuration.distanceUnits {
		case .metric:
			altitudeValues = UIConstants.altitudePresetsInMeters
		case .imperial:
			altitudeValues = UIConstants.altitudePresetsInFeet
		}

		let flightDataSection =  DataSection(title: "Flight", rows: [
			FlightPlanDataTableRow(title: Variable("Altitude"), value: altitude, values: altitudeValues),
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

		let bundle = AirMapBundle.ui
		let image = UIImage(named: "airmap_share_logo", in: bundle, compatibleWith: nil)

		let shareSection = SocialSection(title: "Share My Flight", rows: [
			SocialSharingRow(logo: image!, value: navigationController!.shareFlight)
			])
		sections.append(shareSection)
	}
	
	fileprivate func setupMap() {
		
		let flight = navigationController!.flight.value
		mapView.configure(layers: navigationController!.mapLayers, theme: navigationController!.mapTheme)
		mapView.delegate = mapViewDelegate
		
		if let annotations = flight.annotationRepresentations() {
			mapView.addAnnotations(annotations)
			DispatchQueue.main.async {
				self.mapView.showAnnotations(annotations, edgePadding: UIEdgeInsetsMake(10, 40, 10, 40), animated: true)
			}
		}
	}

	fileprivate func setupBindings() {
		
		let flight = navigationController!.flight
		let status = navigationController!.status
		let shareFlight = navigationController!.shareFlight

		altitude.asObservable()
			.subscribe(onNext: {
				flight.value.maxAltitude = $0
			})
			.disposed(by: disposeBag)
		
		altitude.asObservable()
			.skip(1)
			.subscribe(onNext: { [unowned self] alt in
				self.trackEvent(.slide, label: "Altitude Slider", value: NSNumber(value: alt))
			})
			.disposed(by: disposeBag)

		aircraft.asObservable()
			.subscribe(onNext: { flight.value.aircraft = $0 })
			.disposed(by: disposeBag)
		
		pilot.asObservable()
			.unwrap()
			.subscribe(onNext: { flight.value.pilotId = $0.pilotId })
			.disposed(by: disposeBag)

		status.asObservable()
			.map {
				let hasNextSteps = $0?.supportsNotice ?? true || $0?.requiresPermits ?? true
				return hasNextSteps ? "Next" : "Save"
			}
			.subscribe(onNext: { [unowned self] title in
				self.nextButton.setTitle(title, for: .normal)
			})
			.disposed(by: disposeBag)

		shareFlight.asObservable()
			.subscribe(onNext: { flight.value.isPublic = $0 })
			.disposed(by: disposeBag)
		
		tableView.rx.itemSelected.subscribe(onNext: { [unowned self] indexPath in
			self.tableView.deselectRow(at: indexPath, animated: true)
			self.tableView.cellForRow(at: indexPath)?.becomeFirstResponder()
			})
			.disposed(by: disposeBag)

		Driver.combineLatest(startsAt.asDriver(), duration.asDriver()) { ($0, $1)}
			.drive(onNext: { start, duration in
				flight.value.startTime = start
				flight.value.duration = duration
			})
			.disposed(by: disposeBag)
		
		activityIndicator.asObservable()
			.throttle(0.25, scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bindTo(rx_loading)
			.disposed(by: disposeBag)
		
		shareFlight.asObservable()
			.skip(1)
			.subscribe(onNext: { [unowned self] bool in
				self.trackEvent(.toggle, label: "AirMap Public Flight", value: NSNumber(value: bool ? 1 : 0))
			})
			.disposed(by: disposeBag)
		
		startsAt.asDriver()
			.skip(1)
			.drive(onNext: { [unowned self] date in
				self.trackEvent(.tap, label: "Flight Start Time")
			})
			.disposed(by: disposeBag)
		
		duration.asDriver()
			.skip(1)
			.drive(onNext: { [unowned self] duration in
				self.trackEvent(.tap, label: "Flight End Time")
			})
			.disposed(by: disposeBag)
	}

	@IBAction func next() {

		trackEvent(.tap, label: "Next Button")

		let status = navigationController!.status.value!

		if status.requiresPermits {
			performSegue(withIdentifier: "pushPermits", sender: self)
		} else if status.supportsNotice {
			performSegue(withIdentifier: "pushNotices", sender: self)
		} else {
			AirMap.rx.createFlight(navigationController!.flight.value)
				.trackActivity(activityIndicator)
				.do(onError: { [weak self] error in
					self?.navigationController!.flightPlanDelegate.airMapFlightPlanDidEncounter(error)
				})
				.subscribe(onNext: navigationController!.flightPlanDelegate.airMapFlightPlanDidCreate)
				.disposed(by: disposeBag)
		}
	}
	
}

extension AirMapFlightPlanViewController: UITableViewDataSource, UITableViewDelegate {

	func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].rows.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let section = sections[indexPath.section]
		let row = section.rows[indexPath.row]

		switch section {

		case is DataSection:

			switch row {
				
			case let doubleRow as FlightPlanDataTableRow<Double>:
				let cell = tableView.dequeueReusableCell(withIdentifier: "flightDataCell", for: indexPath) as! AirMapFlightDataCell
				cell.model = doubleRow
				return cell

			case let dateRow as FlightPlanDataTableRow<Date?>:
				let cell = tableView.dequeueReusableCell(withIdentifier: "startsAtCell", for: indexPath) as! AirMapFlightDataDateCell
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
				cell.aircraft.asObservable().bindTo(aircraft).disposed(by: disposeBag)
				return cell

			default:
				fatalError()
			}

		case is SocialSection:
			
			let cell = tableView.dequeueCell(at: indexPath) as AirMapFlightSocialCell
			let row = row as! SocialSharingRow
			cell.model = row
			cell.toggle.rx.value.asObservable().bindTo(row.value).disposed(by: disposeBag)
			return cell

		default:
			fatalError()
		}
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return sections[section].title == nil ? 0 : 25
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sections[section].title
	}

}
