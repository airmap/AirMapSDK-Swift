//
//  AirMap+AuthSession.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/22/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

@objc public protocol AirMapAuthSessionDelegate {
	func airmapSessionShouldAuthenticate()
	optional func airMapAuthSessionDidAuthenticate(pilot: AirMapPilot)
	func airMapAuthSessionAuthenticationDidFail(error: NSError)
}

private typealias AirMap_AuthSession = AirMap
extension AirMap_AuthSession {

	/**

	Setting the auth session delegate automatically

	*/
	public static var authSessionDelegate: AirMapAuthSessionDelegate? {
		didSet { authSession.delegate = authSessionDelegate }
	}

	/**

	Refreshes the `AirMap Access Token` and notifies the AirMapAuthSessionDelegate upon completion

	*/
	public static func refreshAuthToken(handler: AirMapErrorHandler) {
		authClient.refreshAccessToken().subscribe(handler)
	}
	
	/**
	
	Makes a GET call to the resendLink, which re-sends a verification email form to the users email address.
	
	*/
	public static func resendEmailVerificationLink(resendLink:String?){
		authClient.resendEmailVerification(resendLink)
	}

}
