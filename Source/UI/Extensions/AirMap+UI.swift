//
//  AirMap+UI.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Lock
import RxSwift
import RxCocoa

public typealias AirMapLoginHandler = (AirMapPilot?, NSError?) -> Void

private typealias AirMap_UI = AirMap
extension AirMap_UI {
	
	/**
	
	Creates an Auth0 Lock login view controller that can be presented to the user.
	
	- parameter loginHandler: The block that is called upon completion of login flow

	- returns: An A0LockViewController
	
	*/
	public class func loginViewController(loginHandler: AirMapLoginHandler) -> A0LockViewController {
		
		let lock = A0Lock.init(clientId: AirMap.configuration.auth0ClientId, domain: "sso.airmap.io", configurationDomain: "sso.airmap.io")
		
		let theme = A0Theme()
		theme.registerImageWithName("lock_login_image", bundle: NSBundle(forClass: AirMap.self), forKey: A0ThemeIconImageName)
		theme.registerColor(UIColor.airMapGray(), forKey: A0ThemePrimaryButtonNormalColor)
		theme.registerColor(UIColor.airMapGray(), forKey: A0ThemePrimaryButtonHighlightedColor)
		A0Theme.sharedInstance().registerTheme(theme)

		let lockController = A0LockViewController(lock: lock)
		lockController.loginAfterSignUp = true
		lockController.closable = true
		lockController.onAuthenticationBlock = { profile, token in
			guard let authToken = token else {
				AirMap.logger.error("Unexpectedly failed to acquire token after login"); return
			}
			AirMap.authToken = authToken.idToken
			AirMap.authSession.saveRefreshToken(authToken.refreshToken)
			AirMap.rx_getAuthenticatedPilot().subscribe(loginHandler)
		}
		
		let errorSubscription = NSNotificationCenter.defaultCenter()
			.rx_notification(A0LockNotificationSignUpFailed)
			.doOnNext { notification in
				if let errorData = notification
					.userInfo?[A0LockNotificationErrorParameterKey]?
					.userInfo?[A0JSONResponseSerializerErrorDataKey] {
					print(errorData)
					// TODO: check if presented view is AlertViewController
					lockController.dismissViewControllerAnimated(true, completion: nil)
				}
			}
			.subscribe()
		
		lockController.onUserDismissBlock = { _ in
			errorSubscription.dispose()
		}
		
		return lockController
	}
	
	/**
	
	Creates a flight plan creation view controller that can be presented to the user based on a specified location. Airspace status, advisories, permiting, and digital notice are handled within the flow.

	- parameter location: The lat/lon origin of the flight
	- parameter flightPlanDelegate: The delegate that is notified of the new AirMapFlight after completion of flow

	- returns: An AirMapFlightPlanNavigationController if Pilot is Authenticated, otherwise nil.

	*/
	public class func flightPlanViewController(location location: CLLocationCoordinate2D, flightPlanDelegate: AirMapFlightPlanDelegate) -> AirMapFlightPlanNavigationController? {

		guard AirMap.authSession.hasValidCredentials() else { return nil }

		let storyboard = UIStoryboard(name: "AirMapUI", bundle: NSBundle(forClass: AirMap.self))

		let flightPlanNav = storyboard.instantiateInitialViewController() as! AirMapFlightPlanNavigationController
		flightPlanNav.flightPlanDelegate = flightPlanDelegate

		let flightVC = flightPlanNav.viewControllers.first as! AirMapFlightPlanViewController
		flightVC.location = Variable(location)

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

	Creates an AirMap authentication view controller

	- parameter airMapAuthDelegate: The delegate to be notified when authentication succeeds or fails

	*/
	public class func authViewController(airMapAuthSessionDelegate airMapAuthSessionDelegate: AirMapAuthSessionDelegate) -> AirMapAuthViewController {

		let storyboard = UIStoryboard(name: "AirMapUI", bundle: NSBundle(forClass: AirMap.self))

		let authController = storyboard.instantiateViewControllerWithIdentifier(String(AirMapAuthViewController)) as! AirMapAuthViewController
		authController.authSessionDelegate = airMapAuthSessionDelegate

		return authController
	}

}
