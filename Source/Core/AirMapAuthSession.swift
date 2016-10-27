//
//  AirMapAuthSession.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import JWTDecode
import RxSwift
import RxSwiftExt
import SimpleKeychain

class AirMapAuthSession {

	var authToken: String? {
		didSet {
			if let authToken = authToken {
				decodeToken(authToken)
			} else {
				userId = ""
			}
		}
	}

	var tokenType: String = "Bearer"
	var enableCertificatePinning: Bool = false
	var userId: String = ""
	var expiresAt: NSDate!
	weak var delegate: AirMapAuthSessionDelegate?

	private let disposeBag = DisposeBag()

	init() {
		setupBindings()
	}

	private func setupBindings() {

		let expiredDateInterval = Observable<Int>
			.interval(60, scheduler: MainScheduler.instance)
			.mapToVoid()

		expiredDateInterval
			.subscribeNext(unowned(self, AirMapAuthSession.verifyAuthentication))
			.addDisposableTo(disposeBag)
	}

	/**
	Decodes a JWT token and sets the userId and expiresAt properties

	- parameter jwt: The JWT Token to decode

	*/
	private func decodeToken(jwt: String) {

		if jwt.isEmpty {
			self.authToken = nil
			self.userId = ""
		}

		guard let decoded = try? JWTDecode.decode(jwt) else {
			delegate?.airmapSessionShouldAuthenticate()
			return
		}

		expiresAt = decoded.expiresAt
		userId = decoded.subject ?? ""

		AirMap.logger.debug("Decoded Token User Id", userId)
	}

	/**

	If token is expired then ask the delegate for a new Auth Token

	*/
	private func verifyAuthentication() {

		guard let expiresAt = expiresAt else { return }

		if !hasValidCredentials() {

			if NSDate().greaterThanDate(expiresAt.dateBySubtractingTimeInterval(60*5)) {
				self.expiresAt = nil
			}

			delegate?.airmapSessionShouldAuthenticate()
		}
	}

	/// Checks for an expired token and returns a Boolean
	private func tokenIsExpired() -> Bool {
		guard let expiresAt = expiresAt else { return true }
		return NSDate().greaterThanDate(expiresAt)
	}

	/// Validates the credentials and returns a Bool
	func hasValidCredentials() -> Bool {
		return authToken != nil && !authToken!.isEmpty && !tokenIsExpired()
	}

	func saveRefreshToken(token: String?) {
		if let token = token {
			A0SimpleKeychain().setString(token, forKey: Config.AirMapApi.Auth.keychainKeyRefreshToken)
		} else {
			A0SimpleKeychain().deleteEntryForKey(Config.AirMapApi.Auth.keychainKeyRefreshToken)
		}
	}

	func getRefreshToken() -> String? {
		return A0SimpleKeychain().stringForKey(Config.AirMapApi.Auth.keychainKeyRefreshToken)
	}
}
