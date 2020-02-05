//
//  AirMapSystemStatusClient.swift
//  AirMapSDK
//
//  Created by Michael Odere on 2/3/20.
//

import Foundation
import Starscream

internal class AirMapSystemStatusClient: WebSocket {

	init(accessToken: String) {
		var request = URLRequest(url: URL(string: Constants.Api.systemUrl + "/status/monitor")!)
		request.setValue(AirMap.configuration.apiKey, forHTTPHeaderField: HTTPClient.Header.apiKey.rawValue)
		request.setValue("Bearer \(accessToken)", forHTTPHeaderField: HTTPClient.Header.authorization.rawValue)
		request.setValue("string", forHTTPHeaderField: "Accept-Language")
		request.timeoutInterval = 5 // Sets the timeout for the connection

		super.init(request: request)
	}
}

