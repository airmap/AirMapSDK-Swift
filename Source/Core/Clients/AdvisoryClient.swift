//
//  AdvisoryClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/10/17.
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
import SwiftTurf

internal class AdvisoryClient: HTTPClient {
	
	init() {
		super.init(basePath: Constants.Api.advisoryUrl)
	}
	
	enum AdvisoryClientError: Error {
		case invalidGeometry
	}
	
	// MARK: - Advisories

	func getAirspaceStatus(at point: Coordinate2D, buffer: Meters, rulesetIds: [AirMapRulesetId], from start: Date? = nil, to end: Date? = nil) -> Observable<AirMapAirspaceStatus> {
		
		let point = Point(geometry: point)
		guard let polygon = SwiftTurf.buffer(point, distance: buffer) else {
			return .error(AdvisoryClientError.invalidGeometry)
		}
		let geometry = AirMapPolygon(coordinates: polygon.geometry)

		return getAirspaceStatus(within: geometry, under: rulesetIds, from: start, to: end)
	}

	func getAirspaceStatus(along path: AirMapPath, buffer: Meters, rulesetIds: [AirMapRulesetId], from start: Date? = nil, to end: Date? = nil) -> Observable<AirMapAirspaceStatus> {
		
		let lineString = LineString(geometry: path.coordinates)
		guard let polygon = SwiftTurf.buffer(lineString, distance: buffer) else {
			return .error(AdvisoryClientError.invalidGeometry)
		}
		let geometry = AirMapPolygon(coordinates: polygon.geometry)
		
		return getAirspaceStatus(within: geometry, under: rulesetIds, from: start, to: end)
	}

	func getAirspaceStatus(within geometry: AirMapGeometry, under rulesetIds: [AirMapRulesetId], from start: Date? = nil, to end: Date? = nil) -> Observable<AirMapAirspaceStatus> {
		
		AirMap.logger.debug("Get Rules under", rulesetIds)
		var params = [String: Any]()
		params["geometry"] = geometry.params()
		params["rulesets"] = rulesetIds.csv
		params["start"] = start?.iso8601String()
		params["end"] = end?.iso8601String()
		
		return perform(method: .post, path: "/airspace", params: params)
	}
	
	// MARK: - Weather
	
	func getWeatherForecast(at coordinate: Coordinate2D, from: Date?, to: Date?) -> Observable<AirMapWeather> {
		
		AirMap.logger.debug("GET Weather", coordinate)
		var params = [String: Any]()
		params["latitude"] = coordinate.latitude
		params["longitude"] = coordinate.longitude
		params["start"] = from?.iso8601String()
		params["end"] = to?.iso8601String()
		
		return perform(method: .get, path: "/weather", params: params)
	}
}
