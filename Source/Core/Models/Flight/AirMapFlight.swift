//
//  AirMapFlight.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 4/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import CoreLocation
import ObjectMapper

@objc public class AirMapFlight: NSObject {

	public enum FlightGeometryType {
		case Point
		case Path
		case Polygon

		public var value: String {
			switch self {
			case .Point:
				return "point"
			case .Path:
				return "path"
			case .Polygon:
				return "polygon"
			}
		}
	}

	public enum FlightType {
		case Past
		case Active
		case Future
	}

	public var flightId: String!
	public var createdAt: NSDate = NSDate()
	public var startTime: NSDate?
	public var endTime: NSDate? {
		return startTime?.dateByAddingTimeInterval(duration)
	}
	public var duration: NSTimeInterval = 60*60 // 1 hour
	public var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	public var maxAltitude: Double?
	public var city: String!
	public var state: String!
	public var country: String!
	public var notify: Bool = true
	public var permitsIds = [String]()
	public var pilotId: String!
	public var pilot: AirMapPilot? {
		didSet { pilotId = pilot?.pilotId }
	}
	public var aircraft: AirMapAircraft? {
		didSet { aircraftId = aircraft?.aircraftId }
	}
	public var aircraftId: String!
	public var statuses = [AirMapFlightStatus]()
	public var buffer: Double?
	public var isPublic: Bool = false
	public var geometry: AirMapGeometry?
	
	public required init?(_ map: Map) {}

	public override init() {
		super.init()
	}
	
	public func flightType() -> FlightType {
		guard let startTime = startTime, endTime = endTime else { return .Future }
		switch (startTime, endTime) {
		case let (start, end) where start.isInPast() && end.isInFuture():
			return .Active
		case let (start, end) where start.isInFuture() && end.isInFuture():
			return .Future
		default:
			return .Past
		}
	}

}

extension AirMapFlight: Mappable {

	public func mapping(map: Map) {

		var lat: Double?
		var lng: Double?

		lat <- map["latitude"]
		lng <- map["longitude"]

		if let lat = lat, lng = lng {
			coordinate.latitude = lat
			coordinate.longitude = lng
		}

		let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)

		flightId    <-  map["id"]
		createdAt   <- (map["creation_date"], dateTransform)
		startTime   <- (map["start_time"], dateTransform)
		maxAltitude <-  map["max_altitude"]
		city        <-  map["city"]
		state       <-  map["state"]
		country     <-  map["country"]
		notify      <-  map["notify"]
		pilotId     <-  map["pilot_id"]
		pilot       <-  map["pilot"]
		aircraft    <-  map["aircraft"]
		aircraftId  <-  map["aircraft_id"]
		isPublic    <-  map["public"]
		statuses    <-  map["statuses"]
		permitsIds  <-  map["permits"]
		buffer      <-  map["buffer"]
		geometry    <- (map["geometry"], GeoJSONToAirMapGeometryTransform())
		
		var endTime: NSDate?
		endTime     <- (map["end_time"], dateTransform)
		
		if let startTime = startTime, endTime = endTime {
			duration = endTime.timeIntervalSinceDate(startTime)
		}
	}

	/**
	
	Returns key value parameters

	- returns: [String: AnyObject]
	
	*/
	func params() -> [String: AnyObject] {

		var params = [String: AnyObject]()

		params["latitude"    ] = coordinate.latitude
		params["longitude"   ] = coordinate.longitude
		params["max_altitude"] = maxAltitude
		params["aircraft_id" ] = aircraftId
		params["public"      ] = isPublic
		params["notify"      ] = notify
		params["geometry"    ] = geometry?.params()
		params["buffer"      ] = buffer ?? 0
		params["permits"     ] = permitsIds

		if let startTime = startTime, endTime = endTime {
			params["start_time"] = startTime.ISO8601String()
			params["end_time"  ] = endTime.ISO8601String()
		} else {
			let now = NSDate()
			params["start_time"] = now.ISO8601String()
			params["end_time"  ] = now.dateByAddingTimeInterval(duration).ISO8601String()
		}
		
		return params
	}

	public func geometryType() -> FlightGeometryType {
		switch geometry {
		case is AirMapPath:     return .Path
		case is AirMapPolygon:  return .Polygon
		default:                return .Point
		}
 	}

	private func polygonStringFromCoordinates(coordinates: [CLLocationCoordinate2D]) -> String {
		let polygonString = coordinates.flatMap {"\($0.latitude) \($0.longitude)"}.joinWithSeparator(", ")
		return "POLYGON(\(polygonString))"
	}

	private func lineStringFromCoordinates(coordinates: [CLLocationCoordinate2D]) -> String {
		let lineString = coordinates.flatMap {"\($0.latitude) \($0.longitude)"}.joinWithSeparator(", ")
		return "LINESTRING(\(lineString))"
	}
	
}

func ==(lhs: AirMapFlight, rhs: AirMapFlight) -> Bool {
	return lhs.flightId == rhs.flightId
}
