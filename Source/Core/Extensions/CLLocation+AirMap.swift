//
//  CLLocation+AirMap.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/2/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import CoreLocation
import SwiftTurf

extension CLLocation {
	
	func initialDirectionToLocation(location: CLLocation) -> String {
		
		let bearing = self.initialBearingToLocation(location)
		let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
		let index = Int((bearing/22.5) + 0.5) % 16
		return directions[index]
	}
	
}
