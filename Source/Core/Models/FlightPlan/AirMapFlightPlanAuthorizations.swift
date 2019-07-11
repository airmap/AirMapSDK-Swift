//
//  AirMapFlightPlanAuthorizations.swift
//  AirMapSDK
//
//  Created by Michael Odere on 6/25/19.
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

import ObjectMapper

public struct AirMapFlightPlanAuthorizations: ImmutableMappable {
	
	public let id: AirMapFlightPlanId?

	/// The list of authorizations associated with the flightplan
	public let authorizations: [AirMapFlightBriefing.Authorization]

	// MARK: - JSON Serialization
	
	public init(map: Map) throws {
		id = try? map.value("flight_plan_id")
		authorizations = (try? map.value("authorizations")) ?? []
	}
}
