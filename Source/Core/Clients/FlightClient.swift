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

internal class FlightClient: HTTPClient {
	
	enum FlightClientError: Error {
		case FlightDoesNotExist
	}

	init() {
		super.init(basePath: Constants.Api.flightUrl)
	}

	#if AIRMAP_TELEMETRY
	/// Get a communications encryption key for a given flight
	///
	/// - Parameter flightId: The flight identifier for which to request an encryption key
	/// - Returns: A comm key Observable
	func getCommKey(by flightId: AirMapFlightId) -> Observable<CommKey> {
		return perform(method: .post, path: "/\(flightId.rawValue)/start-comm")
	}

	/// Called when a device no longer wants to receive push notifications for traffic alerts
	///
	/// - Parameter flight: The flight for which to request an encryption key
	/// - Returns: A Void Observable
	func clearCommKey(flight: AirMapFlight) -> Observable<Void> {
		return perform(method: .post, path: "/\(flight.id!)/end-comm")
	}
	#endif

	func list(limit: Int? = nil,
	          pilotId: AirMapPilotId? = nil,
	          startAfter: Date? = nil,
	          startAfterNow: Bool = false,
	          startBefore: Date? = nil,
	          startBeforeNow: Bool = false,
	          endAfter: Date? = nil,
	          endAfterNow: Bool = false,
	          endBefore: Date? = nil,
	          endBeforeNow: Bool = false,
	          city: String? = nil,
	          state: String? = nil,
	          country: String? = nil,
	          within geometry: AirMapGeometry? = nil,
	          enhanced: Bool? = true,
	          checkAuth: Bool? = false) -> Observable<[AirMapFlight]> {
		
		var params = [String : Any]()

		params["limit"       ] = limit
		params["pilot_id"    ] = pilotId?.rawValue.isEmpty ?? true ? nil : pilotId
		params["start_after" ] = startAfterNow ? "now" : startAfter?.iso8601String()
		params["start_before"] = startBeforeNow ? "now" : startBefore?.iso8601String()
		params["end_after"   ] = endAfterNow ? "now" : endAfter?.iso8601String()
		params["end_before"  ] = endBeforeNow ? "now" : endBefore?.iso8601String()
		params["city"        ] = city
		params["state"       ] = state
		params["country"     ] = country
		params["enhance"     ] = String(enhanced ?? false)
		params["geometry"    ] = geometry?.params()

		AirMap.logger.debug("Get Flights", params)
        return perform(method: .get, params: params, keyPath: "data.results", checkAuth: checkAuth ?? false)
	}

	func listPublicFlights(from fromDate: Date? = nil, to toDate: Date? = nil, limit: Int? = nil, within geometry: AirMapGeometry? = nil) -> Observable<[AirMapFlight]> {

		let endAfterNow = fromDate == nil
		let endAfter = fromDate
		let startBeforeNow = toDate == nil
		let startBefore = toDate

		AirMap.logger.debug("Get Public Flights", endAfterNow as Any, endAfter as Any, startBefore as Any, startBeforeNow as Any)

		return list(limit: limit, startBefore: startBefore, startBeforeNow: startBeforeNow, endAfter: endAfter, endAfterNow: endAfterNow, within: geometry)
	}

	func get(_ flightId: AirMapFlightId) -> Observable<AirMapFlight> {
		AirMap.logger.debug("Get flight", flightId)
		var params = [String : Any]()
		params["enhance"] = String(true) as AnyObject?
		return perform(method: .get, path:"/\(flightId)", params: params)
	}

	func create(_ flight: AirMapFlight) -> Observable<AirMapFlight> {
		AirMap.logger.debug("Create flight", flight)
		let type: AirMapFlightGeometryType = flight.geometry?.type ?? .point
		return perform(method: .post, path:"/\(type.rawValue)", params: flight.params(), update: flight)
	}

	func end(_ flight: AirMapFlight) -> Observable<AirMapFlight> {
		AirMap.logger.debug("End flight", flight)
		guard let flightId = flight.id else {
			AirMap.logger.error(self, FlightClientError.FlightDoesNotExist)
			return .error(FlightClientError.FlightDoesNotExist)
		}
		return perform(method: .post, path:"/\(flightId)/end", update: flight)
	}
	
	func end(_ flightId: AirMapFlightId) -> Observable<Void> {
		AirMap.logger.debug("End flight", flightId)
		return perform(method: .post, path:"/\(flightId)/end")
	}

	func delete(_ flight: AirMapFlight) -> Observable<Void> {
		AirMap.logger.debug("Delete flight", flight)
		guard let flightId = flight.id else {
			AirMap.logger.error(self, FlightClientError.FlightDoesNotExist)
			return .error(FlightClientError.FlightDoesNotExist)
		}
		return perform(method: .post, path:"/\(flightId)/delete")
	}
	
	func getFlightPlanByFlightId(_ id: AirMapFlightId) -> Observable<AirMapFlightPlan> {
		AirMap.logger.debug("Get FlightPlan for Flight id", id)
		return perform(method: .get, path:"/\(id)/plan")
	}
	
}
