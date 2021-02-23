//
//  AirMapAircraftViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright 2018 AirMap, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import RxSwift
import RxCocoa

public class AirMapAircraftViewController: UITableViewController, AnalyticsTrackable {
	
	public var screenName = "List Aircraft"
	
	public let selectedAircraft = BehaviorRelay(value: nil as AirMapAircraft?)
	
	fileprivate let activityIndicator = ActivityTracker()
	fileprivate let aircraft = BehaviorRelay(value: [AirMapAircraft]())
	fileprivate let disposeBag = DisposeBag()
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		title = LocalizedStrings.Aircraft.selectAircraft
		setupBindings()
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		trackView()
		
		AirMap
			.rx.listAircraft()
			.trackActivity(activityIndicator)
			.bind(to: aircraft)
			.disposed(by: disposeBag)
	}
	
	@IBAction func dismiss() {
		self.dismiss(animated: true, completion: nil)
	}
	
	fileprivate func setupBindings() {
	
		tableView.dataSource = nil
		tableView.delegate = nil
		
		aircraft
			.asObservable()
			.bind(to: tableView.rx.items(cellIdentifier: "aircraftCell")) {
				(index, aircraft, cell) in
				cell.textLabel?.text = aircraft.nickname
				cell.detailTextLabel?.text = [aircraft.model.manufacturer.name, aircraft.model.name]
					.compactMap {$0}.joined(separator: " ")
			}
			.disposed(by: disposeBag)
		
		tableView.rx.modelSelected(AirMapAircraft.self)
			.do(onNext: { [weak self] _ in
				self?.dismiss(animated: true, completion: nil)
			})
			.asOptional()
			.bind(to: selectedAircraft)
			.disposed(by: disposeBag)
		
		tableView
			.rx.itemDeleted
			.do(
				onNext: { [unowned self] _ in
					self.trackEvent(.swipe, label: "Delete")
			})
			.map(tableView.rx.model)
			.flatMap { aircraft in
				AirMap.rx.deleteAircraft(aircraft)
					.do(onError: { [unowned self] error throws in
						self.trackEvent(.delete, label: "Error", value: (error as NSError).code as NSNumber?)
					}, onCompleted: { [unowned self] () throws in
						self.trackEvent(.delete, label: "Success")
					})
			}
			.flatMap(AirMap.rx.listAircraft)
			.do(onError: {
				AirMap.logger.error("Failed to list aircraft", metadata: ["error": .stringConvertible($0.localizedDescription)])
			})
			.ignoreErrors()
			.bind(to: aircraft)
			.disposed(by: disposeBag)
		
		activityIndicator.asObservable()
			.throttle(.milliseconds(250), scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bind(to: rx_loading)
			.disposed(by: disposeBag)
	}
	
	public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let identifier = segue.identifier else { return }
		
		switch identifier {
			
		case "createAircraft":
			trackEvent(.tap, label: "New Aircraft Button")
			let nav = segue.destination as! AirMapAircraftNavController
			nav.aircraftDelegate = self
			
		case "editAircraft":
			trackEvent(.tap, label: "Edit Aircraft Button")
			let cell = sender as! UITableViewCell
			let indexPath = tableView.indexPath(for: cell)!
			let aircraft = try! tableView.rx.model(at: indexPath) as AirMapAircraft
			let nav = segue.destination as! AirMapAircraftNavController
			nav.aircraftDelegate = self
			let aircraftVC = nav.viewControllers.last as! AirMapCreateAircraftViewController
			aircraftVC.aircraft = aircraft
			
		default:
			break
		}
	}
	
	@IBAction func unwindToAircraft(_ segue: UIStoryboardSegue) { /* unwind hook; keep */ }
}

extension AirMapAircraftViewController: AirMapAircraftNavControllerDelegate {
	
	public func aircraftNavController(_ navController: AirMapAircraftNavController, didCreateOrModify aircraft: AirMapAircraft) {
		selectedAircraft.accept(aircraft)
		navigationController?.dismiss(animated: true, completion: nil)
	}
}
