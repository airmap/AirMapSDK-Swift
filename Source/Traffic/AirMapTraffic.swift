//
//  AirMapTraffic.swift
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

import ObjectMapper
import CoreLocation

public class AirMapTraffic: NSObject {

	public enum TrafficType: Int {
		case alert
		case situationalAwareness
	}

	@objc public var id: String!
	@objc public var direction: Double = 0
	@objc public var altitude: Double = 0
	@objc public var groundSpeed: Knots = 0
	@objc public var trueHeading: Int = 0
	@objc public var timestamp: Date = Date()
	@objc public var recordedTime: Date = Date()
	@objc public var properties = AirMapTrafficProperties()
	@objc public var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	@objc public var initialCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	@objc public var createdAt: Date = Date()
	
	public var trafficType = TrafficType.situationalAwareness {
		willSet {
			trafficTypeDidChangeToAlert = trafficType == .situationalAwareness && newValue == .alert
		}
	}
	public var trafficTypeDidChangeToAlert = false

	public override init() {
		super.init()
		
	}

	public required init?(map: Map) {}

	public func isExpired() -> Bool {
		let expirationInterval = Constants.Traffic.expirationInterval
		return createdAt.addingTimeInterval(expirationInterval) < Date()
	}

	public override func isEqual(_ object: Any?) -> Bool {
		if let object = object as? AirMapTraffic {
			return object.properties.aircraftId == self.properties.aircraftId
		} else {
			return false
		}
	}
}

extension AirMapTraffic: Mappable {

	public func mapping(map: Map) {

		id            <-  map["id"]
		direction     <- (map["direction"], StringToDoubleTransform())
		altitude      <- (map["altitude"], StringToDoubleTransform())
		groundSpeed   <- (map["ground_speed_kts"], StringToDoubleTransform())
		trueHeading   <- (map["true_heading"], StringToIntTransform())
		properties    <-  map["properties"]
		timestamp     <- (map["timestamp"], Constants.Api.dateTransform)
		recordedTime  <- (map["recorded_time"], Constants.Api.dateTransform)

		var latitude: String!
		var longitude: String!
		latitude      <-  map["latitude"]
		longitude     <-  map["longitude"]

		if let lat = Double(latitude), let lng = Double(longitude) {
			initialCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
			coordinate = initialCoordinate
		}
	}
}

extension AirMapTraffic {

	public override var description: String {
		
		let lengthFormatter = LengthFormatter()
		lengthFormatter.unitStyle = .medium
		lengthFormatter.numberFormatter.maximumFractionDigits = 0

		let timeFormatter = DateComponentsFormatter()
		timeFormatter.allowsFractionalUnits = false
		timeFormatter.allowedUnits = [.minute, .second]
		timeFormatter.unitsStyle = .abbreviated
		
		let speedFormatter = NumberFormatter()
		speedFormatter.maximumFractionDigits = 0
		
		let altitudeString: String
		let localizedGroundSpeedString: String

		let localizedUnits = LocalizedStrings.Units.self

		lengthFormatter.numberFormatter.roundingIncrement = 50
		switch AirMap.configuration.distanceUnits {
		case .metric:
			let meters = altitude.meters
			let groundSpeedMpsString = speedFormatter.string(from: NSNumber(value: groundSpeed.metersPerSecond))!
			localizedGroundSpeedString = String(format: localizedUnits.speedFormatMetersPerSecond, groundSpeedMpsString)
			altitudeString = lengthFormatter.string(fromValue: meters, unit: .meter)
		case .imperial:
			let feet = altitude
			let groundSpeedKnotsString = speedFormatter.string(from: NSNumber(value: groundSpeed))!
			localizedGroundSpeedString = String(format: localizedUnits.speedFormatKnots, groundSpeedKnotsString)
			altitudeString = lengthFormatter.string(fromValue: feet, unit: .foot)
		}
		
		let aircraftId = properties.aircraftId ?? ""

		if let flightLocation = AirMap.trafficService.currentFlightLocation() {

			let trafficLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
			let direction = flightLocation.initialDirectionToLocation(trafficLocation)
			
			let distance = trafficLocation.distance(from: flightLocation)
			let distanceString: String

			switch AirMap.configuration.distanceUnits {
			case .metric:
				if distance < 950 {
					lengthFormatter.numberFormatter.roundingIncrement = 100
					lengthFormatter.numberFormatter.maximumFractionDigits = 0
					distanceString = lengthFormatter.string(fromValue: distance, unit: .meter)
				} else {
					lengthFormatter.numberFormatter.roundingIncrement = 0.5
					lengthFormatter.numberFormatter.maximumFractionDigits = 1
					distanceString = lengthFormatter.string(fromValue: distance/1000, unit: .kilometer)
				}
			case .imperial:
				lengthFormatter.numberFormatter.roundingIncrement = 0.5
				lengthFormatter.numberFormatter.maximumFractionDigits = 1
				let miles = distance.nauticalMiles
				distanceString = lengthFormatter.string(fromValue: miles, unit: .mile)
			}

			// Set timeString to an empty value
			var timeString = ""
			
			// GroundSpeed must be grater than zero when calculating secondsFromDistanceAndSpeed
			if groundSpeed > 0 {
				let seconds = Int(AirMapTrafficServiceUtils.secondsFromDistanceAndSpeed(distance, speedInKts: groundSpeed))
				timeString = timeFormatter.string(from: DateComponents(second: seconds))!
			}
			
			let alertFormat = LocalizedStrings.Traffic.alertWithAircraftIdAndDistanceFormat
			return String(format: alertFormat, aircraftId, altitudeString, distanceString, direction, timeString)
			
		} else {

			let alertFormat = LocalizedStrings.Traffic.alertWithAircraftIdFormat
			return String(format: alertFormat, aircraftId, altitudeString, localizedGroundSpeedString)
		}
	}
}
