//
//  AirMapStatusWeatherWind.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

open class AirMapStatusWeatherWind : NSObject {
	
	open var heading: Int = 0
	open var speed: Int = 0 // km/h
	open var gusting: Int = 0
	
	public required init?(map: Map) {}
}

extension AirMapStatusWeatherWind: Mappable {
	
	public func mapping(map: Map) {
		heading  <- map["heading"]
		speed    <- map["speed"]
		gusting  <- map["gusting"]
	}
}
