//
//  AirMap+UI.swift
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

import RxSwift

extension AirMap {
	
	// MARK: - UI

	/// Creates an AirMap pilot phone verification view controller
	///
	/// - Parameters:
	///   - pilot: The pilot to verify
	///   - phoneVerificationDelegate: A delegate to notify of verification progress
	/// - Returns: A view controller that can be presented
	public class func phoneVerificationViewController(_ pilot: AirMapPilot, phoneVerificationDelegate: AirMapPhoneVerificationDelegate) -> AirMapPhoneVerificationNavController {
		
		let storyboard = UIStoryboard(name: "AirMapUI", bundle: AirMapBundle.ui)
		let phoneNav = storyboard.instantiateViewController(withIdentifier: "VerifyPhoneNumber") as! AirMapPhoneVerificationNavController
		phoneNav.phoneVerificationDelegate = phoneVerificationDelegate

		let phoneVerificationVC = phoneNav.viewControllers.first as! AirMapPhoneVerificationViewController
		phoneVerificationVC.pilot = pilot
		
		return phoneNav
	}
	
	/// Returns a navigation controller that creates or modifies an AirMapAircraft
	///
	/// - Parameters:
	///   - aircraft: The aircraft to modify. Pass nil to create a new AirMapAircraft
	///   - delegate: The delegate to be notified on completion of the new or modified AirMapAircraft
	/// - Returns: An AirMapAircraftModelNavController if Pilot is Authenticated, otherwise nil
	public class func aircraftNavController(_ aircraft: AirMapAircraft?, delegate: AirMapAircraftNavControllerDelegate) -> AirMapAircraftNavController? {
		
		guard AirMap.authService.isAuthorized else {
			AirMap.logger.error(AirMap.self, "Cannot create or modify aicraft; user not authenticated")
			return nil
		}
		
		let storyboard = UIStoryboard(name: "AirMapUI", bundle: AirMapBundle.ui)
		
		let aircraftNav = storyboard.instantiateViewController(withIdentifier: String(describing: AirMapAircraftNavController.self)) as! AirMapAircraftNavController
		aircraftNav.aircraftDelegate = delegate
		
		let aircraftVC = aircraftNav.viewControllers.first as! AirMapCreateAircraftViewController
		aircraftVC.aircraft = aircraft
		
		return aircraftNav
	}
	
	/// Returns an aircraft manufacturer and model selection view controller
	///
	/// - Parameter aircraftSelectionDelegate: The delegate to be notified of the selected AirMapAircraftModel on completion
	/// - Returns: An AirMapAircraftModelNavController if Pilot is Authenticated, otherwise nil.
	public class func aircraftModelViewController(_ aircraftSelectionDelegate: AirMapAircraftModelSelectionDelegate) -> AirMapAircraftModelNavController? {

		guard AirMap.authService.isAuthorized else {
			return nil
		}

		let storyboard = UIStoryboard(name: "AirMapUI", bundle: AirMapBundle.ui)

		let aircraftNav = storyboard.instantiateViewController(withIdentifier: String(describing: AirMapAircraftModelNavController.self)) as! AirMapAircraftModelNavController
		aircraftNav.aircraftModelSelectionDelegate = aircraftSelectionDelegate

		return aircraftNav
	}
	
}
