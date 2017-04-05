//
//  AirMapStatusWeather.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

open class AirMapStatusWeather : NSObject {

	open var condition: String!
	open var wind: AirMapStatusWeatherWind!
	open var humidity: Double!
	open var visibility: Double!
	open var precipitation: Double!
	open var temperature: Celcius!
	open var icon: String!
	
	#if os(iOS) || os(tvOS) || os(watchOS)
	open lazy var iconImage: UIImage? = {
		return AirMapImage.image(named: self.icon)
	}()
	#elseif os(OSX)
	public lazy var iconImage: NSImage? = {
		return AirMapImage.image(named: self.icon)
	}()
	#endif

	public required init?(map: Map) {}
}

extension AirMapStatusWeather: Mappable {

	public func mapping(map: Map) {
		condition     <- map["condition"]
		wind          <- map["wind"]
		humidity      <- map["humidity"]
		visibility    <- map["visibility"]
		precipitation <- map["precipitation"]
		temperature   <- map["temperature"]
		icon		  <- map["icon"]
	}
}
