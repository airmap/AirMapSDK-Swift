//
//  FlightClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
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

internal class ArchiveClient: HTTPClient {

	init() {
		super.init(basePath: Constants.Api.archiveUrl)
	}

	func queryFlightTelemetry(for flightId: AirMapFlightId, from: Date?, to: Date?, sampleRate: SampleRate?) -> Observable<ArchivedTelemetry> {

		AirMap.logger.debug("Query Flight Telemetry", flightId as Any, from as Any, to as Any, sampleRate as Any)

		var params = [String : Any]()
		params["flight_id"] = flightId.rawValue
		params["start"] = from?.iso8601String()
		params["end"] = to?.iso8601String()
		params["rate"] = sampleRate

		return withCredentials().flatMap { (credentials) -> Observable<ArchivedTelemetry> in
			return self.perform(method: .get, path:"/telemetry/position", params: params, auth: credentials)
		}
	}
}

