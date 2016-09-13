//
//  AirMap+UI.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift

private typealias AirMap_UI = AirMap
extension AirMap_UI {
	
	/**
	
	Creates an AirMap pilot phone verification view controller
	
	- parameter airMapAuthDelegate: The delegate to be notified when authentication succeeds or fails
	
	*/
	public class func phoneVerificationViewController(pilot: AirMapPilot, phoneVerificationDelegate: AirMapPhoneVerificationDelegate) -> AirMapPhoneVerificationNavController {
		
		let storyboard = UIStoryboard(name: "AirMapUI", bundle: NSBundle(forClass: AirMap.self))
		let nav = storyboard.instantiateViewControllerWithIdentifier("VerifyPhoneNumber") as! AirMapPhoneVerificationNavController
		nav.phoneVerificationDelegate = phoneVerificationDelegate
		let phoneVerificationVC = nav.viewControllers.first as! AirMapPhoneVerificationViewController
		phoneVerificationVC.pilot = pilot
		
		return nav
	}
	
	/**
	
	Creates a flight plan creation view controller that can be presented to the user based on a specified location. Airspace status, advisories, permiting, and digital notice are handled within the flow.

	- parameter location: The lat/lon origin of the flight
	- parameter flightPlanDelegate: The delegate that is notified of the new AirMapFlight after completion of flow

	- returns: An AirMapFlightPlanNavigationController if Pilot is Authenticated, otherwise nil.

	*/
	public class func flightPlanViewController(location location: CLLocationCoordinate2D, flightPlanDelegate: AirMapFlightPlanDelegate) -> AirMapFlightPlanNavigationController? {

		// FIXME:
		guard AirMap.authSession.hasValidCredentials() else { return nil }

		let storyboard = UIStoryboard(name: "AirMapUI", bundle: NSBundle(forClass: AirMap.self))

		let flightPlanNav = storyboard.instantiateInitialViewController() as! AirMapFlightPlanNavigationController
		flightPlanNav.flightPlanDelegate = flightPlanDelegate

		let flightVC = flightPlanNav.viewControllers.first as! AirMapCreateFlightTypeViewController
		flightPlanNav.flight.value.coordinate = location

		return flightPlanNav
	}
	
	/**
	
	Creates a flight plan creation view controller that can be presented to the user based on a specified location. Airspace status, advisories, permiting, and digital notice are handled within the flow.
	
	- parameter location: The lat/lon origin of the flight
	- parameter flightPlanDelegate: The delegate that is notified of the new AirMapFlight after completion of flow
	
	- returns: An AirMapFlightPlanNavigationController if Pilot is Authenticated, otherwise nil.
	
	*/
	public class func flightPlanViewController(flight: AirMapFlight) -> UINavigationController? {
		
		guard AirMap.authSession.hasValidCredentials() else { return nil }
		
		let storyboard = UIStoryboard(name: "AirMapUI", bundle: NSBundle(forClass: AirMap.self))
		let aircraftVC = storyboard.instantiateViewControllerWithIdentifier(String(AirMapReviewFlightPlanViewController)) as! AirMapReviewFlightPlanViewController
		aircraftVC.existingFlight = Variable(flight)
		
		let nav = UINavigationController(navigationBarClass: AirMapNavBar.self, toolbarClass: nil)
		nav.viewControllers = [aircraftVC]
		
		return nav
	}
	
	/**
	
	Returns a navigation controller that creates or modifies an AirMapAircraft
	
	- parameter aircraft: The aircraft to modify. Pass nil to create a new AirMapAircraft
	- parameter delegate: The delegate to be notified on completion of the new or modified AirMapAircraft
	
	- returns: An AirMapAircraftModelNavController if Pilot is Authenticated, otherwise nil.
	
	*/
	public class func aircraftNavController(aircraft: AirMapAircraft?, delegate: AirMapAircraftNavControllerDelegate) -> AirMapAircraftNavController? {
		
		guard AirMap.authSession.hasValidCredentials() else {
			AirMap.logger.error(AirMap.self, "Cannot create or modify aicraft; user not authenticated")
			return nil
		}
		
		let storyboard = UIStoryboard(name: "AirMapUI", bundle: NSBundle(forClass: AirMap.self))
		
		let aircraftNav = storyboard.instantiateViewControllerWithIdentifier(String(AirMapAircraftNavController)) as! AirMapAircraftNavController
		aircraftNav.aircraftDelegate = delegate
		
		let aircraftVC = aircraftNav.viewControllers.first as! AirMapCreateAircraftViewController
		aircraftVC.aircraft = aircraft ?? AirMapAircraft()
		
		return aircraftNav
	}
	
	/**
	
	Returns an aircraft manufacturer and model selection view controller

	- parameter aircraftSelectionDelegate: The delegate to be notified of the selected AirMapAircraftModel on completion

	- returns: An AirMapAircraftModelNavController if Pilot is Authenticated, otherwise nil.

	*/
	public class func aircraftModelViewController(aircraftSelectionDelegate: AirMapAircraftModelSelectionDelegate) -> AirMapAircraftModelNavController? {

		guard AirMap.authSession.hasValidCredentials() else {
			return nil
		}

		let storyboard = UIStoryboard(name: "AirMapUI", bundle: NSBundle(forClass: AirMap.self))

		let aircraftNav = storyboard.instantiateViewControllerWithIdentifier(String(AirMapAircraftModelNavController)) as! AirMapAircraftModelNavController
		aircraftNav.aircraftModelSelectionDelegate = aircraftSelectionDelegate

		return aircraftNav
	}
	
	/**
	
	Creates an AirMapAuthViewController that can be presented to the user.
	
	- parameter authHandler: The block that is called upon completion of login flow
	
	- returns: An AirMapAuthViewController
	
	*/
	
	public class func authViewController(authHandler: AirMapAuthHandler) -> AirMapAuthViewController {
		let authController = AirMapAuthViewController(authHandler: authHandler)
		return authController
	}

}
