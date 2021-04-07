//
//  AirMapVerifySMSCodeViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/8/16.
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

class AirMapVerifySMSCodeViewController: UITableViewController, AnalyticsTrackable {
	
	var screenName = "Phone Verification - SMS Code"
	
	@IBOutlet var submitButton: UIButton!
	@IBOutlet weak var header: UILabel!
	@IBOutlet weak var smsCodeTextField: UITextField!

	var phoneNumber:String?
	
	fileprivate let disposeBag = DisposeBag()
	fileprivate let activityIndicator = ActivityTracker()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		setupText()
		setupBindings()
		setupBranding()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		smsCodeTextField.inputAccessoryView = submitButton
		smsCodeTextField.becomeFirstResponder()
		trackView()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		smsCodeTextField.resignFirstResponder()
	}

	override var inputAccessoryView: UIView? {
		return submitButton
	}

	override var canBecomeFirstResponder : Bool {
		return true
	}

	fileprivate func setupText() {
		let localized = LocalizedStrings.PhoneVerificationCode.self
		title = localized.title
		header.text = localized.header
		smsCodeTextField.placeholder = localized.placeholder
		submitButton.setTitle(localized.submit, for: .normal)
	}

	fileprivate func setupBindings() {
		
		smsCodeTextField.rx.text.asObservable()
			.map { $0?.count == Constants.Api.smsCodeLength }
			.bind(to: submitButton.rx.isEnabled)
			.disposed(by: disposeBag)
		
		activityIndicator.asObservable()
			.throttle(.milliseconds(250), scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bind(to: rx_loading)
			.disposed(by: disposeBag)
	}
	
	fileprivate func setupBranding() {
		submitButton.backgroundColor = .primary
	}

	@IBAction func submitSMSCode() {
		
		trackEvent(.tap, label: "Submit Button")
		smsCodeTextField.resignFirstResponder()
		
		AirMap.rx.verifySMS(smsCodeTextField.text!)
			.trackActivity(activityIndicator)
			.map { $0.verified}
			.subscribe(
				onNext: unowned(self, AirMapVerifySMSCodeViewController.didVerifyPhoneNumber),
				onError: { (error) in
					self.trackEvent(.save, label: "Error", value: NSNumber(value: (error as NSError).code))
					if let error = error as? AirMapError {
						self.displayErrorAlert(message: error.description)
					} else {
						self.displayErrorAlert(message: error.localizedDescription)
					}

			}, onCompleted: { [unowned self] in
				self.trackEvent(.save, label: "Success")
			})
			.disposed(by: disposeBag)
	}
	
	fileprivate func displayErrorAlert(message:String) {
		
		let localized = LocalizedStrings.PhoneVerification.self
		
		
		let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

		let tryAgainAction = UIAlertAction(title: localized.tryAgain, style: .cancel)
		let requestTokenAction = UIAlertAction(title: localized.requestNewSMSCode, style: .default) { action in
			_ = self.navigationController?.popViewController(animated: true)
		}
		
		alert.addAction(tryAgainAction)
		alert.addAction(requestTokenAction)
		navigationController?.present(alert, animated: true, completion: nil)
	}
	
	fileprivate func didVerifyPhoneNumber(_ verified: Bool) {
		
		if verified {
			let nav = navigationController as! AirMapPhoneVerificationNavController
			nav.phoneVerificationDelegate?.phoneVerificationDidVerifyPhoneNumber(verifiedPhoneNumber: phoneNumber)
		} else {
			//TODO: Localize
			displayErrorAlert(message: LocalizedStrings.PhoneVerification.verificationFailed)
		}
	}
}
