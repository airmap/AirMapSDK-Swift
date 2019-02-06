//
//  AirMap+Auth.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/22/16.
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

import Foundation

// MARK: - Auth Delegate

/// Protocol for handling AirMap authentication state changes
public protocol AirMapAuthSessionDelegate: class {
	func airmapSessionShouldAuthenticate()
	func airMapAuthSessionAuthenticationDidFail(_ error: Error)
}

public typealias AirMapAuthHandler = (Result<AirMapPilot>) -> Void

extension AirMap {
	
	// MARK: - Auth

	/// Returns the user authorization status
	public static var isAuthorized: Bool {
		return authService.isAuthorized
	}

	/// A JWT auth token that identifies the logged-in user.
	public static var authToken: String? {
		return authService.authToken
	}

	/// Setting the auth session delegate automatically calls the delegate should a pilot
	/// need to re-authenticate after a refresh token expiration or invalidation
	public static var authSessionDelegate: AirMapAuthSessionDelegate? {
		didSet { authService.delegate = authSessionDelegate }
	}

	/// Authenticates an Anonymous User associated with the Developer API Key.
	///
	/// - Parameters:
	///   - userId: a third-party, non-AirMap user id
	///   - completion: A completion handler to call with the Result
	public static func performAnonymousLogin(userId: String, completion: @escaping (Result<Void>) -> Void) {
		rx.performAnonymousLogin(userId: userId).thenSubscribe(completion)
	}

	/// Log out the currently authenticated pilot
	public static func logout() {
		authService.logout()
	}

	/// Presents a login view for the user to authenticate with the AirMap platform
	///
	/// - Parameters:
	///   - viewController: The viewController from which to present the login view
	///   - authHandler: The block that is called upon completion of login flow
	public static func login(from viewController: UIViewController, with authHandler: @escaping AirMapAuthHandler) {
		authService.login(from: viewController)
			.flatMap(AirMap.rx.getAuthenticatedPilot)
			.thenSubscribe(authHandler)
	}

	/// Resumes the login flow by handling a callback url
	///
	/// - Parameter url: The URL with which the application was called
	/// - Returns: A boolean indicating that the handler was able to handle the request
	public static func resumeLogin(with callback: URL) -> Bool {
		return authService.resumeLogin(with: callback)
	}
}
