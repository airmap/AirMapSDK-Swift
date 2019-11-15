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
import KeychainAccess
import RxSwift
import RxCocoa

class AuthService: NSObject {

	weak var delegate: AirMapAuthSessionDelegate?

	var isAuthorized: Bool {
		switch authState.value {
		case .loggedOut:
			return false
		case .anonymous(let token):
			return OIDIDToken(idTokenString: token.idToken)?.expiresAt ?? .distantPast > Date()
		case .authenticated(let state):
			return state.isAuthorized
		}
	}

	var authToken: String? {
		switch authState.value {
		case .loggedOut:
			return nil
		case .anonymous(let token):
			return token.idToken
		case .authenticated(let state):
			return state.lastTokenResponse?.accessToken
		}
	}
	
	var refreshToken: String? {
		switch authState.value {
		case .loggedOut:
			return nil
		case .anonymous:
			return nil
		case .authenticated(let state):
			return state.lastTokenResponse?.refreshToken
		}
	}

	let authState = BehaviorRelay<AuthState>(value: AuthService.persistedState())

	override init() {
		super.init()
		setupBindings()
	}

	static let keychain = Keychain()
		.synchronizable(true)
		.accessibility(.afterFirstUnlock)

	#if os(OSX)
	func login() -> Observable<Void> {

		assertValidConfiguration()

		return .create() { (observer) -> Disposable in
			let issuer = URL(string: Constants.Auth.identityProvider)!
			OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { [unowned self] (config, error) in
				if let error = error {
					return observer.onError(AirMapError.unknown(underlying: error))
				}
				if let config = config {
					let request = OIDAuthorizationRequest(from: config)
					self.activeFlow = OIDAuthState.authState(byPresenting: request) { state, error in
						if let error = error {
							return observer.onError(AirMapError.unknown(underlying: error))
						}
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
	#else
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
						if let error = error {
							return observer.onError(AirMapError.unknown(underlying: error))
						}
						if let state = state {
							self.authState.accept(.authenticated(state))
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
	#endif

	func resumeLogin(with callback: URL) -> Bool {
		return activeFlow?.resumeExternalUserAgentFlow(with: callback) ?? false
	}

	func loginAnonymously(withForeign id: String) -> Observable<Void> {
		return AirMap.authClient.performAnonymousLogin(withForeign: id)
			.do(onNext: { [unowned self] (token) in
				self.authState.accept(.anonymous(token))
			})
			.mapToVoid()
	}

	func logout() -> Observable<Void> {
		return AirMap.openIdClient.performLogout()
			.do(onNext: { [weak self] (_) in
				AuthService.keychain[Constants.Auth.keychainAuthState] = nil
				self?.authState.accept(.loggedOut)
			})
	}

	struct Credentials {
		let token: String
		let pilot: AirMapPilotId
	}

	func performWithCredentials() -> Observable<Credentials> {

		return authState.asObservable()
			.take(1) // Prevent multiple executions when authState updates
			.flatMap { (state) -> Observable<Credentials> in
				switch state {

				case .loggedOut:
					AirMap.logger.error("Failed to get credentials", metadata: ["error": .stringConvertible(AirMapError.unauthorized)])
					throw AirMapError.unauthorized

				case .anonymous(let token):
					guard let idToken = OIDIDToken(idTokenString: token.idToken) else {
						throw AirMapError.unauthorized
					}
					guard idToken.expiresAt > Date() else {
						throw AirMapError.unauthorized
					}
					let pilot = AirMapPilotId(rawValue: idToken.subject)
					let creds = Credentials(token: token.idToken, pilot: pilot)
					return Observable.of(creds)

				case .authenticated(let auth):
					return .create { (observer) -> Disposable in

						auth.performAction { (accessToken, idToken, error) in
							if let error = error {
								return observer.onError(error)
							}
							guard let accessToken = accessToken else {
								return observer.onError(AirMapError.unauthorized)
							}
							guard let idToken = idToken, let id = OIDIDToken(idTokenString: idToken) else {
								return observer.onError(AirMapError.unauthorized)
							}
							let pilot = AirMapPilotId(rawValue: id.subject)
							let creds = Credentials(token: accessToken, pilot: pilot)

							observer.onNext(creds)
							observer.onCompleted()
						}

						return Disposables.create()
					}
				}
			}
	}

	func performWithOptionalCredentials() -> Observable<Credentials?> {
		return authState.asObservable()
			.take(1) // Prevent multiple executions when authState updates
			.flatMap { (state) -> Observable<Credentials?> in
				switch state {
				case .loggedOut:
					return Observable.of(nil)
				default:
					return self.performWithCredentials().asOptional()
				}
			}
	}

	// MARK: - Private

	enum AuthState {
		case loggedOut
		case anonymous(AirMapToken)
		case authenticated(OIDAuthState)
	}
	
	private var activeFlow: OIDExternalUserAgentSession?

	private let disposeBag = DisposeBag()

	private func setupBindings() {
		authState.asObservable()
			.subscribe(onNext: AuthService.persist)
			.disposed(by: disposeBag)
	}

	private func assertValidConfiguration() {

		if #available(iOS 10.0, *) {
			// Register of URL scheme unnecessary after iOS 10
			return
		}

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
			AuthService.keychain[data: Constants.Auth.keychainAuthState] = archivedState
		} else {
			AuthService.keychain[Constants.Auth.keychainAuthState] = nil
		}
	}

	private static func persistedState() -> AuthState {
		guard let data = AuthService.keychain[data: Constants.Auth.keychainAuthState] else {
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
		if case let .authenticated(currentState) = authState.value, state == currentState  {
			return
		}
		if state.isAuthorized {
			authState.accept(AuthState.authenticated(state))
		} else {
			authState.accept(.loggedOut)
			AirMap.authSessionDelegate?.airmapSessionShouldAuthenticate()
		}
	}
}

extension AuthService.AuthState {

	var accessToken: String? {
		switch self {
			case .loggedOut:
				return nil
			case .anonymous(let token):
				return token.idToken
			case .authenticated(let state):
				return state.lastTokenResponse?.accessToken
		}
	}
}
