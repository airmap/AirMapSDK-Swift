//
//  OpenIdClient.swift
//  AirMapSDK
//
//  Created by Michael Odere on 2/11/19.
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
import RxSwift
import AppAuth
import Alamofire

internal class OpenIdClient: HTTPClient {
	
	init() {
		super.init(basePath: Constants.Auth.identityProvider)
	}
	
 	func performLogout() -> Observable<Void> {
		guard let refreshToken = AirMap.authService.refreshToken,
			  let clientId = AirMapConfiguration.custom?.clientId
		else { return Observable.of(Void()) }

		let params = ["refresh_token":  refreshToken, "client_id": clientId]

		return withCredentials().flatMap { (credentials) -> Observable<Void> in
			return self.perform(method: .post, customEncoding: URLEncoding.httpBody, path: "protocol/openid-connect/logout", params: params, auth: credentials)
		}
	}
}
