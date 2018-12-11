//
//  AuthClient.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 8/9/16.
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

#if os(iOS) || os(tvOS)
    import UIKit.UIDevice
#endif

import Foundation
import RxSwift

internal class Auth0Client: HTTPClient {

	init() {
		super.init(basePath: "https://" + AirMap.configuration.auth0Host)
	}

	func refreshAccessToken() -> Observable<AirMapToken> {
		AirMap.logger.debug("Refresh Access Token")

		guard let refreshToken = AirMap.authSession.getRefreshToken() else {
			return Observable.error(AirMapError.unauthorized)
		}

		var params = [String: Any]()
		params["grant_type"] = Constants.Auth.grantType
		params["client_id"] = AirMap.configuration.auth0ClientId
		params["api_type"] = "app"
		params["refresh_token"] = refreshToken
		params["scope"] = Constants.Auth.scope

		return perform(method: .post, path:"/delegation", params: params, keyPath: nil)
			.do(onNext: { token in
				AirMap.authToken = token.authToken
			}, onError: { error in
				AirMap.logger.debug("ERROR: \(error)")
			})
    }
	
    func startPasswordlessLogin(with phoneNumber: String) -> Observable<Void> {
		
		var params = [String: Any]()
		params["phone_number"] = phoneNumber
		params["client_id"] = AirMap.configuration.auth0ClientId
		params["connection"] = "sms"
		params["send"] = "code"
		
        return perform(method: .post, path:"/passwordless/start", params: params, keyPath: nil)
    }
    
    func verifyPasswordlessLogin(with phoneNumber: String, code: String) -> Observable<Auth0Credentials> {
		
		let deviceId: String
		
		#if os(iOS) || os(tvOS)
            deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        #elseif os(OSX)
            deviceId = "macOS-" + UUID().uuidString
		#endif
		
		var params = [String: Any]()
		params["username"] = phoneNumber
		params["password"] = code
		params["client_id"] = AirMap.configuration.auth0ClientId
		params["connection"] = "sms"
		params["grant_type"] = "password"
		params["device"] = deviceId
		params["scope"] = Constants.Auth.scope
        
        return perform(method: .post, path:"/oauth/ro", params: params, keyPath: nil)
            .do(onNext: { credentials in
                AirMap.authSession.authToken = credentials.idToken
                AirMap.authSession.refreshToken = credentials.refreshToken
            }, onError: { error in
                AirMap.logger.debug("ERROR: \(error)")
            })
    }
    
}
