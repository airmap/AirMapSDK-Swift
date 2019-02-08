//
//  LoginExampleViewController.swift
//  AirMapSDK-Example-iOS
//
//  Created by Adolfo Martinelli on 9/8/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import UIKit
import AirMap

class LoginExampleViewController: UIViewController {
	
	/// The uses cases available for this view controller
	///
	/// - anonymous: Perform anonymous login for a user that does not have an AirMap account
	/// - existing: Display a UI to login a known AirMap user
	enum UseCase {
		case anonymousUser
		case airMapUser
	}

	var useCase: UseCase!

	// MARK: - IBOutlets

	@IBOutlet var pilotInfo: UILabel!
	@IBOutlet var loginButton: UIButton!
	
	// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		assert(Bundle.main.bundleIdentifier! != "com.airmap.AirMapSDK-Example-iOS",
		 		"In order to test Login you must update the bundle Id " +
			"to match with the corresponding clients bundle Id found in the dev portal. " +
			"See documentation for more info."
		)
		
		switch useCase! {
		case .anonymousUser:
			navigationItem.title = "Anonymous Login"
		case .airMapUser:
			navigationItem.title = "AirMap Login"
		}
	}
	
	// MARK: - IBActions

	/// Action called when the user taps the 'Login' button
	@IBAction func login() {
		
		switch useCase! {
		case .anonymousUser:
			performAnonymousLogin()
		case .airMapUser:
			performAirMapLogin()
		}
	}
	
	// MARK: - Private Methods
	
	/// Login anonymously without the need for an AirMap user account
	private func performAnonymousLogin() {
		
		// Login as an anonymous user. The userId parameter here is a unique third-party identifier for the user
		// on your platform, not AirMap. It may be used at a future date if a user wishes to create an AirMap account
		// and associate any previously anonymous flights, telemetry, etc. with that account.
		AirMap.performAnonymousLogin(userId: "abc123") { (result) in

			switch result {

			// Handle the error case
			case .error(let error):
				self.handle(error)

			// Handle the success case
			case .value:
				// Since we are anonymous, configure view with a nil AirMapPilot
				self.configureView(with: nil)
			}
		}
	}
	
	/// Present a modal UI that allows the user to login to the AirMap platform with existing AirMap credentials or by signing up
	private func performAirMapLogin() {
		
		// Present a login UI from the current view controller
		AirMap.login(from: self) { (result: Result<AirMapPilot>) in
			
			switch result {
				
			// Handle the error case
			case .error(let error):
				self.handle(error)
				
			// Handle the success case
			case .value(let pilot):
				self.configureView(with: pilot)
			}
		}
	}
	
	/// Configure the user interface with a given AirMapPilot
	///
	/// - Parameter pilot: The pilot object from which to source user details. Pass nil for anonymous.
	private func configureView(with pilot: AirMapPilot?) {
		
		let info: [(key: String, value: String?)]

		if let pilot = pilot {
			info = [
				("First Name", pilot.firstName),
				("Last Name", pilot.lastName),
				("Username", pilot.username),
				("Email", pilot.email),
				("Email verified", pilot.emailVerified.description),
				("Phone", pilot.phone),
				("Phone verified", pilot.phoneVerified.description),
				("Total flights", pilot.statistics?.totalFlights.description),
				("Total aircraft", pilot.statistics?.totalAircraft.description),
				("Pilot ID", pilot.id.rawValue)
			]
		} else {
			info = [
				("Pilot", "anonymous"),
				("Auth Token", AirMap.authToken)
			]
		}
		
		// Define text style attributes
		let keyAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)]
		let valueAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)]
		
		// Apply the styling to the text and construct a single attributed string
		let attributedInfo = info
			.reduce(NSMutableAttributedString(), { (total, next) -> NSMutableAttributedString in
				total.append(NSAttributedString(string: next.key.uppercased(), attributes: keyAttributes))
				total.append(NSAttributedString(string: "\n"))
				total.append(NSAttributedString(string: next.value ?? "none", attributes: valueAttributes))
				total.append(NSAttributedString(string: "\n\n"))
				return total
			})
		
		pilotInfo.attributedText = attributedInfo
		loginButton.isHidden = true
	}

	/// Handle an error by presenting a modal alert
	///
	/// - Parameter error: The error object to display
	private func handle(_ error: Error) {
		
		let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
		let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) in
			self.dismiss(animated: true, completion: nil)
		}
		alert.addAction(dismiss)
		present(alert, animated: true, completion: nil)
	}

}
