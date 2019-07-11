//
//  AirMap+Flights.swift
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

extension AirMap {

	// MARK: - Flights

	/// List all public flights. A user's non-public flights are excluded.
	///
	/// - Parameters:
	///   - fromDate: The start of search window. Optional
	///   - toDate: The end of search window. Optional
	///   - limit: The maximum number of flights to return. Optional
	///   - completion: A completion handler to call with the Result
	public static func listPublicFlights(from fromDate: Date? = nil, to toDate: Date? = nil, limit: Int? = nil, completion: @escaping (Result<[AirMapFlight]>) -> Void) {
		rx.listPublicFlights(from: fromDate, to: toDate, limit: limit).thenSubscribe(completion)
	}

	/// List all flights belonging only to the currently authenticated pilot
	///
	/// - Parameters:
	///   - limit: The maximum number of flights to return. Optional
	///   - completion: A completion handler to call with the Result
	public static func listCurrentAuthenticatedPilotFlights(limit: Int? = 100, completion: @escaping (Result<[AirMapFlight]>) -> Void) {
		rx.listCurrentAuthenticatedPilotFlights(limit: limit).thenSubscribe(completion)
	}
	
	/// Get the current flight belonging to the currently authenticated pilot
	///
	/// - Parameter completion: A completion handler to call with the Result
	public static func getCurrentAuthenticatedPilotFlight(_ completion: @escaping (Result<AirMapFlight?>) -> Void) {
		rx.getCurrentAuthenticatedPilotFlight().thenSubscribe(completion)
	}

	/// Get a flight by its identifer
	///
	/// - Parameters:
	///   - id: The unique identifier associated with the flight
	///   - completion: A completion handler to call with the Result
	public static func getFlight(by id: AirMapFlightId, completion: @escaping (Result<AirMapFlight>) -> Void) {
		rx.getFlight(by: id).thenSubscribe(completion)
	}

	/// Create a new flight for the currently authenticated pilot
	///
	/// - Parameters:
	///   - flight: The flight to create
	///   - completion: A completion handler to call with the Result
	public static func createFlight(_ flight: AirMapFlight, completion: @escaping (Result<AirMapFlight>) -> Void) {
		rx.createFlight(flight).thenSubscribe(completion)
	}

	/// End a flight, setting its `endTime` to now
	///
	/// - Parameters:
	///   - flight: The flight to end
	///   - completion: A completion handler to call with the Result
	public static func endFlight(_ flight: AirMapFlight, completion: @escaping (Result<AirMapFlight>) -> Void) {
		rx.endFlight(flight).thenSubscribe(completion)
	}
	
	/// End a flight, setting its `endTime` to now
	///
	/// - Parameters:
	///   - id: The unique identifier associated with the flight
	///   - completion: A completion handler to call with the Result
	public static func endFlight(by id: AirMapFlightId, completion: @escaping (Result<Void>) -> Void) {
		rx.endFlight(by: id).thenSubscribe(completion)
	}

	/// Delete a flight
	///
	/// - Parameters:
	///   - flight: The flight to delete
	///   - completion: A completion handler to call with the Result
	public static func deleteFlight(_ flight: AirMapFlight, completion: @escaping (Result<Void>) -> Void) {
		rx.deleteFlight(flight).thenSubscribe(completion)
	}
	
	/// Get a flight plan by flight id
	///
	/// - Parameters:
	///   - id: The identifier for the flight
	///   - completion: A completion handler with the flight plan result
	public static func getFlightPlanByFlightId(_ id: AirMapFlightId, completion: @escaping (Result<AirMapFlightPlan>) -> Void) {
		rx.getFlightPlanByFlightId(id).thenSubscribe(completion)
	}
}
