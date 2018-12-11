//
//  AirspaceClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/30/16.
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

internal class AirspaceClient: HTTPClient {
	
	init() {
		super.init(basePath: Constants.Api.airspaceUrl)
	}
	
	func getAirspace(_ airspaceId: AirMapAirspaceId) -> Observable<AirMapAirspace> {
		AirMap.logger.debug("Get Airspace", airspaceId)
		return perform(method: .get, path:"/\(airspaceId)")
	}

	func listAirspace(_ airspaceIds: [AirMapAirspaceId]) -> Observable<[AirMapAirspace]> {
		AirMap.logger.debug("Get Airspace", airspaceIds)
		let params = [
			"ids": airspaceIds.csv
		]
		return perform(method: .get, path:"/list", params: params)
	}

}
