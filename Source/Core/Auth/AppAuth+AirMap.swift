//
//  AppAuth+AirMap.swift
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

extension OIDAuthorizationRequest {

	convenience init(from configuration: OIDServiceConfiguration) {

		let redirectScheme = Bundle.main.bundleIdentifier!.lowercased()
		let redirectUrl = URL(string: "\(redirectScheme)://oauth2/airmap")!
		let clientId = AirMap.configuration.clientId
		let scopes = Constants.Auth.scopes

		self.init(
			configuration: configuration, clientId: clientId, clientSecret: nil, scopes: scopes,
			redirectURL: redirectUrl, responseType: OIDResponseTypeCode, additionalParameters: ["prompt": "login"]
		)
	}
}
