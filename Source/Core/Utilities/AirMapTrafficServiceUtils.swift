//
//  AirMapTrafficService+Utils.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/2/16.
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

open class AirMapTrafficServiceUtils {
	
    public static func directionFromBearing(_ bearing: Double, localized: Bool = true) -> String {
		let index = Int((bearing/22.5) + 0.5) % 16
		let directions = self.compassDirections(localized: localized)
		return directions[index]
	}
	
	static func compassDirections(localized: Bool = true) -> [String] {
		
		let localizedStrings = LocalizedStrings.CardinalDirection.self
		
		if localized {
			return [
				localizedStrings.N,
				localizedStrings.NNE,
				localizedStrings.NE,
				localizedStrings.ENE,
				localizedStrings.E,
				localizedStrings.ESE,
				localizedStrings.SE,
				localizedStrings.SSE,
				localizedStrings.S,
				localizedStrings.SSW,
				localizedStrings.SW,
				localizedStrings.WSW,
				localizedStrings.W,
				localizedStrings.WNW,
				localizedStrings.NW,
				localizedStrings.NNW
			]
		} else {
			return [
				"N",
				"NNE",
				"NE",
				"ENE",
				"E",
				"ESE",
				"SE",
				"SSE",
				"S",
				"SSW",
				"SW",
				"WSW",
				"W",
				"WNW",
				"NW",
				"NNW"
			]
		}
	}
	
	static func secondsFromDistanceAndSpeed(_ distance: Meters, speedInKts: Double) -> TimeInterval {
		
		return distance / (speedInKts*1852) * 3600
	}
	
}
