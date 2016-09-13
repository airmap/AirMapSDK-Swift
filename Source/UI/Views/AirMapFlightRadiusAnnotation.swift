//
//  AirMapFlightRadiusAnnotation.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Mapbox
import CoreLocation
import SwiftTurf

class AirMapFlightRadiusAnnotation: MGLPolygon {
	
	class func polygon(location: CLLocationCoordinate2D, radius: CLLocationDistance) -> MGLPolygon {
		
		let point = Point(geometry: location)
		let bufferedPoint = SwiftTurf.buffer(point, distance: radius, units: .Meters)

		var coordinates = bufferedPoint?.geometry.first ?? []
		return MGLPolygon(coordinates: &coordinates, count: UInt(coordinates.count))
	}
	
}
