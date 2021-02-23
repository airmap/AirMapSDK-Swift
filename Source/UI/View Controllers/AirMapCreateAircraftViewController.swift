//
//  AirMapCreateAircraftViewController.swift
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
import RxRelay

class AirMapCreateAircraftViewController: UITableViewController {
	
	var aircraft: AirMapAircraft!
	
	@IBOutlet var saveButton: UIButton!
	@IBOutlet weak var nickname: UITextField!
	@IBOutlet weak var makeAndModel: UILabel!
	@IBOutlet weak var makeAndModelCell: UITableViewCell!
	
	fileprivate enum UseCase {
		case create
		case update
	}
	
	fileprivate var mode: UseCase {
		return aircraft?.id == nil ? .create : .update
	}
	
	fileprivate var model = BehaviorRelay(value: nil as AirMapAircraftModel?)
	
	private let activityIndicator = ActivityTracker()
	private let disposeBag = DisposeBag()
	
	override var navigationController: AirMapAircraftNavController? {
		return super.navigationController as? AirMapAircraftNavController
	}
	
	// MARK: - View Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let localized = LocalizedStrings.Aircraft.self
		switch mode {
		case .create:
			navigationItem.title = localized.titleCreate
			
		case .update:
			navigationItem.title = localized.titleUpdate

			tableView.allowsSelection = false
			nickname.text = aircraft.nickname
			model.accept(aircraft.model)
			makeAndModelCell.accessoryType = .none
			makeAndModelCell.textLabel?.alpha = 0.5
		}

		nickname.text = localized.nickname
		makeAndModel.text = localized.makeAndModel
		saveButton.setTitle(localized.save, for: .normal)

		setupBindings()
		setupBranding()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		trackView()
		
		if ((nickname.text ?? "").isEmpty) || (mode == .update) {
			nickname.becomeFirstResponder()
		} else {
			self.becomeFirstResponder()
		}
	}
	
	override var canBecomeFirstResponder : Bool {
		return true
	}
	
	override var inputAccessoryView: UIView? {
		return saveButton
	}
	
	// MARK: - Setup

	fileprivate func setupBindings() {

		let nickNameObs = nickname.rx.text.asObservable()
		let modelObs = model.asObservable()
		
		Observable.combineLatest(nickNameObs, modelObs) { ($0, $1) }
			.subscribe(onNext: { [unowned self] nickname, model in
				switch self.mode {
				case .create:
					guard let nickname = nickname, let model = model else { return }
					self.aircraft = AirMapAircraft(model: model, nickname: nickname)
				case .update:
					guard let nickname = nickname else { return }
					self.aircraft.nickname = nickname
				}
			})
			.disposed(by: disposeBag)
		
		model.asObservable()
			.unwrap()
			.map { [$0.manufacturer.name, $0.name].compactMap { $0 }.joined(separator: " ") }
			.bind(to: makeAndModel.rx.text)
			.disposed(by: disposeBag)
		
		Observable
			.combineLatest(modelObs, nickNameObs) { (model: $0, nickName: $1) }
			.map { $0.model != nil && !($0.nickName ?? "").isEmpty }
			.bind(to: saveButton.rx.isEnabled)
			.disposed(by: disposeBag)
		
		activityIndicator.asObservable()
			.throttle(.milliseconds(250), scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bind(to: rx_loading)
			.disposed(by: disposeBag)
	}
	
	fileprivate func setupBranding() {
		saveButton.backgroundColor = .primary
	}

	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "modalModel" {
			trackEvent(.tap, label: "Make & Model")
			let nav = segue.destination as! AirMapAircraftModelNavController
			nav.aircraftModelSelectionDelegate = self
		}

		if let indexPath = tableView.indexPathForSelectedRow {
			tableView.deselectRow(at: indexPath, animated: true)
		}
	}
	
	@IBAction func unwindToCreateAircraft(_ segue: UIStoryboardSegue) { /* Interface Builder hook; keep */ }
	
	// MARK: - Actions
	
	@IBAction func save() {
		
		trackEvent(.tap, label: "Save Button")

		let action: Observable<AirMapAircraft>
		switch mode {
		case .create:
			action = AirMap.rx.createAircraft(aircraft).trackActivity(activityIndicator)
		case .update:
			action = AirMap.rx.updateAircraft(aircraft).trackActivity(activityIndicator)
		}

		action
			.do(onCompleted: { [weak self] () throws in
				self?.resignFirstResponder()
				self?.navigationController?.aircraftDelegate?
					.aircraftNavController(self!.navigationController!, didCreateOrModify: self!.aircraft)
			})
			.subscribe()
			.disposed(by: disposeBag)
	}
}

extension AirMapCreateAircraftViewController: AirMapAircraftModelSelectionDelegate {
	
	func didSelectAircraftModel(_ model: AirMapAircraftModel?) {
		self.model.accept(model)
		dismiss(animated: true, completion: nil)
	}

}

extension AirMapCreateAircraftViewController: AnalyticsTrackable {
	
	var screenName: String {
		switch mode {
		case .create:
			return "Create Aircraft"
		case .update:
			return "Update Aircraft"
		}
	}
}
