//
//  AirMapPilotStats.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/19/16.
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

public struct AirMapPilotStats {
	
	public let totalAircraft: Int
	public let totalFlights: Int
	public let lastFlightTime: Date?
}

extension AirMapPilotStats: ImmutableMappable {
	
	public init(map: Map) throws {
		totalFlights    =  try map.value("flight.total")
		totalAircraft   =  try map.value("aircraft.total")
		lastFlightTime  =  try? map.value("flight.last_flight_time", using: Constants.Api.dateTransform)
	}
	
}
