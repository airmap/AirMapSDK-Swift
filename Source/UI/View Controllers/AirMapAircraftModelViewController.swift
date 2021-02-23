//
//  AirMapAircraftModelViewController.swift
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

import UIKit
import RxSwift
import RxCocoa

class AirMapAircraftModelViewController: UITableViewController, AnalyticsTrackable {
	
	var screenName = "Create Aircraft - Models"
	
	var manufacturer: AirMapAircraftManufacturer!
	
	fileprivate let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		title = LocalizedStrings.Model.title		
		tableView.dataSource = nil
		
		AirMap
			.rx.listModels(by: manufacturer.id)
			.map { models in
				models.sorted { $0.name < $1.name }
			}
			.bind(to: tableView.rx.items(cellIdentifier: "Cell")) { index, model, cell in
				cell.textLabel?.text = model.name
			}
			.disposed(by: disposeBag)
		
		tableView.rx.itemSelected
			.map(tableView.rx.model)
			.subscribeNext(weak: self, AirMapAircraftModelViewController.notifyDelegateOfSelection)
			.disposed(by: disposeBag)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		trackView()
	}
	
	fileprivate func notifyDelegateOfSelection(_ model: AirMapAircraftModel) {
		
		trackEvent(.tap, label: "Select Model")
		let nav = navigationController as! AirMapAircraftModelNavController
		nav.aircraftModelSelectionDelegate?.didSelectAircraftModel(model)
	}
	
}
