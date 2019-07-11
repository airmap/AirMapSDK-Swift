//
//  AirMap+FlightPlans.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/24/17.
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
	
	// MARK: - Flight Plans

	/// Create a new flight plan
	///
	/// - Parameters:
	///   - flightPlan: The flight plan to create
	///   - completion: A completion handler with the flight plan result
	public static func createFlightPlan(_ flightPlan: AirMapFlightPlan, completion: @escaping (Result<AirMapFlightPlan>) -> Void) {
		rx.createFlightPlan(flightPlan).thenSubscribe(completion)
	}
	
	/// Update an existing flight plan
	///
	/// - Parameters:
	///   - flightPlan: The flight plan to update
	///   - completion: A completion handler to call with the updated flight plan result
	public static func updateFlightPlan(_ flightPlan: AirMapFlightPlan, completion: @escaping (Result<AirMapFlightPlan>) -> Void) {
		rx.updateFlightPlan(flightPlan).thenSubscribe(completion)
	}
	
	/// Get a flight plan by its identifier
	///
	/// - Parameters:
	///   - flightPlanId: The identifier for the flight plan
	///   - completion: A completion handler with the flight plan result
	public static func getFlightPlan(_ flightPlanId: AirMapFlightPlanId, completion: @escaping (Result<AirMapFlightPlan>) -> Void) {
		rx.getFlightPlan(flightPlanId).thenSubscribe(completion)
	}
	
	/// Get a briefing for a given flight plan identifier
	///
	/// - Parameters:
	///   - flightPlanId: The identifier of the flight plan for which to retrieve a briefing
	///   - completion: A completion handler to call with the flight plan briefing result
	public static func getFlightBriefing(_ flightPlanId: AirMapFlightPlanId, completion: @escaping (Result<AirMapFlightBriefing>) -> Void) {
		rx.getFlightBriefing(flightPlanId).thenSubscribe(completion)
	}

	/// Get authorizations by flight plan ids
	///
	/// - Parameters:
	///   - ids: The flight plan ids of the authorizations you'd like to get
	public static func getFlightPlanAuthorizationsByFlightPlanIds(_ ids: [AirMapFlightPlanId], completion: @escaping (Result<[AirMapFlightPlanAuthorizations]>) -> Void) {
		rx.getFlightPlanAuthorizationsByFlightPlanIds(ids).thenSubscribe(completion)
	}

	/// Submit a flight plan
	///
	/// - Parameters:
	///   - flightPlan: The flight plan to submit (must already have been created)
	///   - makeFlightPublic: Makes the resulting flight publicly visible on the AirMap platform
	///   - completion: A completion handler to call with the flight plan result
	public static func submitFlightPlan(_ flightPlan: AirMapFlightPlan, makeFlightPublic: Bool = true, completion: @escaping (Result<AirMapFlightPlan>) -> Void) {
		rx.submitFlightPlan(flightPlan, makeFlightPublic: makeFlightPublic).thenSubscribe(completion)
	}

	/// Delete a flight plan
	///
	/// - Parameters:
	///   - flightPlanId: The identifier of the flight plan to delete
	///   - completion: A completion handler to call with the flight plan deletion result
	public static func deleteFlightPlan(_ flightPlanId: AirMapFlightPlanId, completion: @escaping (Result<Void>) -> Void) {
		rx.deleteFlightPlan(flightPlanId).thenSubscribe(completion)
	}
	
}
