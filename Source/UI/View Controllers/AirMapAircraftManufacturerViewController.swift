//
//  AirMapAircraftManufacturerViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/27/16.
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

import RxSwift
import RxCocoa
import RxDataSources

class AirMapAircraftManufacturerViewController: UITableViewController, AnalyticsTrackable {
	
	var screenName = "Create Aircraft - Manufacturers"
	
	fileprivate let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.dataSource = nil
		
		AirMap
			.rx.listManufacturers()
			.map { $0.sorted { $0.name.lowercased() < $1.name.lowercased() } }
			.bind(to: tableView.rx.items(cellIdentifier: "Cell")) { index, manufacturer, cell in
				cell.textLabel?.text = manufacturer.name
			}
			.disposed(by: disposeBag)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		trackView()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "pushModel" {
			trackEvent(.tap, label: "Select Manufacturer")
			let cell = sender as! UITableViewCell
			let indexPath = tableView.indexPath(for: cell)!
			let modelVC = segue.destination as! AirMapAircraftModelViewController
			modelVC.manufacturer = try! tableView.rx.model(at: indexPath)
		}
	}
	
	@IBAction func cancel() {
		let nav = navigationController as! AirMapAircraftModelNavController
		nav.aircraftModelSelectionDelegate?.didSelectAircraftModel(nil)
	}
	
}
