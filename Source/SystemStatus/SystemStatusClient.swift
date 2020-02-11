//
//  SystemStatusClient.swift
//  AirMapSDK
//
//  Created by Michael Odere on 2/3/20.
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
import Starscream

internal class SystemStatusClient: WebSocket {

	init(accessToken: String?) {
		var request = URLRequest(url: URL(string: Constants.Api.systemUrl + "/status/monitor")!)
		request.setValue(AirMap.configuration.apiKey, forHTTPHeaderField: HTTPClient.Header.apiKey.rawValue)
		request.setValue(Locale.preferredLanguages.first, forHTTPHeaderField: "Accept-Language")
		request.timeoutInterval = Constants.SystemStatus.timeout

		if let accessToken = accessToken {
			request.setValue("Bearer \(accessToken)", forHTTPHeaderField: HTTPClient.Header.authorization.rawValue)
		}

		super.init(request: request)
	}
}

