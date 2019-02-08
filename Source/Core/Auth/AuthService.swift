//
//  AuthService.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 2/1/19.
//  Copyright 2019 AirMap, Inc.
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
import AppAuth
import SimpleKeychain
import RxSwift

class AuthService: NSObject {

	weak var delegate: AirMapAuthSessionDelegate?

	var isAuthorized: Bool {
		switch authState {
		case .loggedOut:
			return false
		case .anonymous(let token):
			return OIDIDToken(idTokenString: token.idToken)?.expiresAt ?? .distantPast > Date()
		case .authenticated(let state):
			return state.isAuthorized
		}
	}

	var authToken: String? {
		switch authState {
		case .loggedOut:
			return nil
		case .anonymous(let token):
			return token.idToken
		case .authenticated(let state):
			return state.lastTokenResponse?.accessToken
		}
	}

	override init() {
		super.init()
		authState = AuthService.persistedState()
	}

	func login(from viewController: UIViewController) -> Observable<Void> {

		assertValidConfiguration()

		return .create() { (observer) -> Disposable in
			let issuer = URL(string: Constants.Auth.identityProvider)!
			OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { [unowned self] (config, error) in
				if let error = error {
					return observer.onError(AirMapError.unknown(underlying: error))
				}
				if let config = config {
					let request = OIDAuthorizationRequest(from: config)
					self.activeFlow = OIDAuthState.authState(byPresenting: request, presenting: viewController) { state, error in
						if let state = state {
							self.authState = .authenticated(state)
							self.activeFlow = nil
							observer.onNext(())
							observer.onCompleted()
						}
					}
				}
			}
			return Disposables.create {
				self.activeFlow?.cancel()
				self.activeFlow = nil
			}
		}
	}

	func resumeLogin(with callback: URL) -> Bool {
		return activeFlow?.resumeExternalUserAgentFlow(with: callback) ?? false
	}

	func loginAnonymously(withForeign id: String) -> Observable<Void> {
		return AirMap.authClient.performAnonymousLogin(withForeign: id)
			.do(onNext: { [unowned self] (token) in
				self.authState = .anonymous(token)
			})
			.mapToVoid()
	}

	func logout()  {
		A0SimpleKeychain().deleteEntry(forKey: Constants.Auth.keychainAuthState)
		self.authState = .loggedOut
	}

	struct Credentials {
		let token: String
		let pilot: AirMapPilotId
	}

	func performWithCredentials() -> Observable<Credentials> {

		return .create { [unowned self] (observer) -> Disposable in

			switch self.authState {

			case .loggedOut:
				observer.onError(AirMapError.unauthorized)

			case .anonymous(let token):
				guard let idToken = OIDIDToken(idTokenString: token.idToken) else {
					observer.onError(AirMapError.unauthorized)
					break
				}
				guard idToken.expiresAt > Date() else {
					observer.onError(AirMapError.unauthorized)
					break
				}
				let pilot = AirMapPilotId(rawValue: idToken.subject)
				let creds = Credentials(token: token.idToken, pilot: pilot)
				observer.onNext(creds)
				observer.onCompleted()

			case .authenticated(let auth):
				auth.performAction { (accessToken, idToken, error) in
					if let error = error {
						return observer.onError(error)
					}
					guard let tokenString = idToken, let token = OIDIDToken(idTokenString: tokenString) else {
						return observer.onError(AirMapError.unauthorized)
					}
					let pilot = AirMapPilotId(rawValue: token.subject)
					let creds = Credentials(token: tokenString, pilot: pilot)
					observer.onNext(creds)
					observer.onCompleted()
				}
			}
			return Disposables.create()
		}
	}

	// MARK: - Private

	enum AuthState {
		case loggedOut
		case anonymous(AirMapToken)
		case authenticated(OIDAuthState)
	}

	private var authState: AuthState = .loggedOut {
		didSet {
			if case let .authenticated(state) = authState {
				state.stateChangeDelegate = self
				state.errorDelegate = self
			}
			AuthService.persist(authState)
		}
	}

	private var activeFlow: OIDExternalUserAgentSession?

	private func assertValidConfiguration() {

		// Verify that the custom url schemes have configured in your app's Info.plist
		guard let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [Any], urlTypes.count > 0 else {
			return assertionFailure("No url types has been configured for your project.")
		}

		var urlSchemes = [String]()

		for urlType in urlTypes {
			guard let items = urlType as? [String: Any] else {
				continue
			}
			guard let schemes = items["CFBundleURLSchemes"] as? [String] else {
				continue
			}
			urlSchemes += schemes
		}

		assert(urlSchemes.contains(Bundle.main.bundleIdentifier!.lowercased()),
			   "Configure a URI scheme in your Info.plist (URL Types -> Item 0 -> URL Schemes -> Item 0) " +
			"with a scheme matching your *lowercased* bundle identifier. e.g. 'com.mycompany.myapp' instead of 'com.MyCompany.MyApp'"
		)
	}

	private static func persist(_ authState: AuthState) {
		if case let .authenticated(state) = authState {
			let archivedState = NSKeyedArchiver.archivedData(withRootObject: state)
			A0SimpleKeychain().setData(archivedState, forKey: Constants.Auth.keychainAuthState)
		} else {
			A0SimpleKeychain().deleteEntry(forKey: Constants.Auth.keychainAuthState)
		}
	}

	private static func persistedState() -> AuthState {
		guard let data = A0SimpleKeychain().data(forKey: Constants.Auth.keychainAuthState) else {
			return .loggedOut
		}
		guard let persistedState = NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState else {
			return .loggedOut
		}
		guard persistedState.isAuthorized else {
			return .loggedOut
		}
		return .authenticated(persistedState)
	}
}

extension AuthService: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {

	func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
		AirMap.authSessionDelegate?.airMapAuthSessionAuthenticationDidFail(error)
	}

	func didChange(_ state: OIDAuthState) {
		if case let .authenticated(currentState) = authState, state == currentState  {
			return
		}
		if state.isAuthorized {
			authState = .authenticated(state)
		} else {
			authState = .loggedOut
			AirMap.authSessionDelegate?.airmapSessionShouldAuthenticate()
		}
	}
}
