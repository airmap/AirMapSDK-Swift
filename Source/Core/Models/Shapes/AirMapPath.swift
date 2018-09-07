//
//  AirMapApiData.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/20/16.
/*
Copyright 2018 AirMap, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
//

import Foundation

public class AirMapPath: AirMapGeometry {

	public var coordinates: [Coordinate2D]!
	
	public var type: AirMapFlightGeometryType {
		return .path
	}
	
	public init(coordinates: [Coordinate2D]) {
		self.coordinates = coordinates
	}

	public func params() -> [String: Any] {
		
		return [
			"type": "LineString",
			"coordinates": coordinates?.map({ [$0.longitude, $0.latitude] }) as Any
		]
	}
}
