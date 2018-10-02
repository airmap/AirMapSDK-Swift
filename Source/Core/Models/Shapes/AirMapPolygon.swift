//
//  AirMapPolygon.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/20/16.
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
public class AirMapPolygon: AirMapGeometry {
	
	public var coordinates: [[Coordinate2D]]
	
	public var type: AirMapFlightGeometryType {
		return .polygon
	}
	
	public init(coordinates: [[Coordinate2D]]) {
		self.coordinates = coordinates
	}
	
	public func params() -> [String: Any] {
		
		var params = [String: Any]()
		
		if coordinates.count >= 1 {
			
			let coordinates = self.coordinates.map { (coordinates) -> [Coordinate2D] in
				coordinates.reduce([Coordinate2D]()) { (result, next) -> [Coordinate2D] in
					var result = result
					if result.last != next {
						result.append(next)
					}
					return result
				}
			}
			
			params["type"] = "Polygon"
			params["coordinates"] = coordinates
				.map { coordinates in
					return coordinates.map { coordinate in
						[coordinate.longitude, coordinate.latitude]
					}
				} as [[[Double]]] as AnyObject?
		}
		
		return params
	}
}

