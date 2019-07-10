//
//  AirMapPilotProfileViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/21/16.
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
import RxDataSources

open class AirMapPilotProfileField {
	
	public enum FieldType {
		case text
		case email
		case phoneNumber
		
		var type: String {
			switch self {
			case .text: return "text"
			case .email: return "email"
			case .phoneNumber: return "phone"
			}
		}
	}
	
	let label: String
	let key: String
	
	internal let rx_value = PublishSubject<String?>()
	
	open var type: FieldType = .text
	
	public init(label: String, key: String, type: FieldType = .text) {
		self.label = label
		self.type = type
		self.key = key
	}
}


class AirMapFormTextField: UITableViewCell {
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var label: UILabel!

	override func awakeFromNib() {
		label.textColor = .highlight
	}
}

public class AirMapPilotProfileViewController: UITableViewController, AnalyticsTrackable {
	
	public var screenName = "Pilot Profile"
	
	var customFields = [AirMapPilotProfileField]()

	public var pilot: Variable<AirMapPilot?>!
	
	@IBOutlet weak var fullName: UILabel!
	@IBOutlet weak var statisticsLabel: UILabel!
	@IBOutlet var saveButton: UIButton!
	
	fileprivate typealias Model = SectionModel<String,AirMapPilotProfileField>
	fileprivate var dataSource: RxTableViewSectionedReloadDataSource<Model>!
	fileprivate let activityIndicator = ActivityTracker()
	fileprivate let disposeBag = DisposeBag()
	
	enum Section: Int {
		case pilotInfo
		case customInfo
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.dataSource = nil
		tableView.delegate = nil
		
		setupTableView()
		setupBindings()
		setupBranding()
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		AirMap.rx.getAuthenticatedPilot().asOptional()
			.trackActivity(activityIndicator)
			.bind(to: pilot)
			.disposed(by: disposeBag)
		
		trackView()
	}
	
	public override var canBecomeFirstResponder : Bool {
		return true
	}
	
	public override var inputAccessoryView: UIView? {
		return saveButton
	}
	
	fileprivate func sectionModel(_ pilot: AirMapPilot) -> [Model] {
		
		let localized = LocalizedStrings.PilotProfile.self
		
		let firstNameField = AirMapPilotProfileField(label: localized.firstNameLabel, key: "firstName")
		let lastNameField  = AirMapPilotProfileField(label: localized.lastNameLabel, key: "lastName")
		let usernameField  = AirMapPilotProfileField(label: localized.usernameLabel, key: "username")
		let emailField     = AirMapPilotProfileField(label: localized.emailLabel, key: "email", type: .email)
		let phoneField     = AirMapPilotProfileField(label: localized.phoneLabel, key: "phone", type: .phoneNumber)
		
		let pilotFields: [AirMapPilotProfileField]
		
		// TODO: Find a generalized way to do this
		// If the locale is Japan, order lastName before firstName
		if Locale.current.identifier.hasPrefix("ja") {
			pilotFields = [lastNameField, firstNameField, usernameField, emailField, phoneField]
		} else {
			pilotFields = [firstNameField, lastNameField, usernameField, emailField, phoneField]
		}

		pilotFields.forEach { field in
			
			field.rx_value.skip(1).asDriver(onErrorJustReturn: nil)
				.drive(onNext: { text in
					switch field.key {
					case "firstName":
						pilot.firstName = text
					case "lastName":
						pilot.lastName = text
					case "username":
						pilot.username = text
					case "email":
						pilot.email = text
					case "phone":
						pilot.phone = text
					default:
						assertionFailure()
					}
				})
				.disposed(by: disposeBag)
		}
		
		customFields.forEach { customField in

			customField.rx_value.skip(1).asDriver(onErrorJustReturn: nil)
				.drive(onNext: { text in pilot.setAppMetadata(value: text, forKey: customField.key) })
				.disposed(by: disposeBag)
		}
		
        Driver
            .combineLatest(
                firstNameField.rx_value.asDriver(onErrorJustReturn: nil),
                lastNameField.rx_value.asDriver(onErrorJustReturn: nil),
                resultSelector: fullNameString)
			.drive(fullName.rx.text)
			.disposed(by: disposeBag)
		
		return [
			Model(model: localized.sectionHeaderPersonal, items: pilotFields)
		]
	}
	
	fileprivate func setupTableView() {
		
		tableView.estimatedRowHeight = 50
		tableView.rowHeight = UITableView.automaticDimension
		
		dataSource = RxTableViewSectionedReloadDataSource<Model>(
			
			configureCell: { [unowned self] dataSource, tableView, indexPath, field in
				let cell: AirMapFormTextField
				
				let cellIdentifier: String
				switch field.type  {
				case .text:
					cellIdentifier = "TextCell"
				case .email:
					cellIdentifier = "EmailCell"
				case .phoneNumber:
					cellIdentifier = "PhoneCell"
				}
				
				cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! AirMapFormTextField
				cell.label.text = field.label
				
				let pilot = self.pilot.value
				
				switch Section(rawValue: indexPath.section)! {
					
				case .pilotInfo:
					
					var value: String?
					switch field.key {
					case "firstName":
						value = pilot?.firstName
					case "lastName":
						value = pilot?.lastName
					case "username":
						value = pilot?.username
					case "email":
						value = pilot?.email
					case "phone":
						value = pilot?.phone
					default:
						assertionFailure()
					}
					
					if let value = value {
						cell.textField.rx.text.onNext(value)
					}
					
				case .customInfo:
					if let value = pilot?.appMetadata()[field.key] as? String {
						cell.textField.rx.text.onNext(value)
					}
				}
				
				cell.textField.rx.text
					.bind(to: field.rx_value)
					.disposed(by: self.disposeBag)
				
				return cell
			},
			
			titleForHeaderInSection: { dataSource, index in
				dataSource.sectionModels[index].model
			}
		)
	}
	
	fileprivate func setupBindings() {
		
		pilot.asObservable()
			.unwrap()
			.map(sectionModel)
			.observeOn(MainScheduler.instance)
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
		
		pilot.asObservable()
			.unwrap()
			.observeOn(MainScheduler.instance)
			.subscribeNext(weak: self, AirMapPilotProfileViewController.configureStats)
			.disposed(by: disposeBag)
		
		activityIndicator.asObservable()
			.throttle(0.25, scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bind(to: rx_loading)
			.disposed(by: disposeBag)
	}
	
	fileprivate func setupBranding() {
		saveButton.backgroundColor = .primary
	}

	@IBAction func savePilot() {
		
		trackEvent(.tap, label: "Save")

		guard let pilot = pilot.value else { return }

		AirMap.rx.updatePilot(pilot)
			.trackActivity(activityIndicator)
			.do(onError: { error in
				self.trackEvent(.save, label: "Error", value: NSNumber(value: (error as NSError).code))
			}, onCompleted: { [unowned self] in
				self.view.endEditing(true)
				self.dismiss(animated: true, completion: nil)
				self.trackEvent(.save, label: "Success")
			})
			.asOptional()
			.bind(to: self.pilot)
			.disposed(by: disposeBag)
	}
	
	public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "modalUpdatePhoneNumber" {
			let nav = segue.destination as! AirMapPhoneVerificationNavController
			nav.phoneVerificationDelegate = self
			let phoneVC = nav.viewControllers.first as! AirMapPhoneVerificationViewController
			phoneVC.pilot = pilot.value
		}
	}
	
    fileprivate func fullNameString(firstName: String?, lastName: String?) -> String {
        return String(format: LocalizedStrings.PilotProfile.fullNameFormat, firstName ?? "", lastName ?? "")
            .trimmingCharacters(in: .whitespaces)
	}
	
	fileprivate func configureStats(_ pilot: AirMapPilot) {
		guard let stats = pilot.statistics else { return }
		let statsFormat = LocalizedStrings.PilotProfile.statisticsFormat
		statisticsLabel.text = String(format: statsFormat, stats.totalAircraft.description, stats.totalFlights.description)
	}
	
	@IBAction func dismiss() {
		
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func unwindToPilotProfile(_ segue: UIStoryboardSegue) { /* Interface Builder hook; keep */ }

}

extension AirMapPilotProfileViewController: AirMapPhoneVerificationDelegate {
	
	public func phoneVerificationDidVerifyPhoneNumber(verifiedPhoneNumber:String?) {
		dismiss(animated: true, completion: nil)
	}
}
