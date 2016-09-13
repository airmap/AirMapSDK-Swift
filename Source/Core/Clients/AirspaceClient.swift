//
//  AirspaceClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/30/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift

internal class AirspaceClient: HTTPClient {
	
	init() {
		super.init(Config.AirMapApi.airspaceUrl)
	}
	
	func getAirspace(airspaceId: String) -> Observable<AirMapAirspace> {
		AirMap.logger.debug("Get Airspace", airspaceId)
		return call(.GET, url:"/\(airspaceId)")
	}

	func listAirspace(airspaceIds: [String]) -> Observable<[AirMapAirspace]> {
		AirMap.logger.debug("Get Airspace", airspaceIds)
		let params = [
			"ids": airspaceIds.joinWithSeparator(",")
		]
		return call(.GET, url:"/list", params: params)
	}

}
