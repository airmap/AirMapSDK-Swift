//
//  Report.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/11/19.
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

public struct ArchivedTelemetry {

	public struct Report {
		public let timestamp: Date
		public let coordinate: Coordinate2D
		public let altitude: Altitude
	}

	public let reports: [Report]
}

public struct Altitude {

	public let height: Meters
	public let reference: Reference

	public enum Reference: String {
		/// An unknown reference.
		case unknown   = "UNKNOWN"
		/// The hypothetical equipotential gravitational surface. (WGS84)
		case ellipsoid = "ELLIPSOID"
		/// Approximates the mean sea level.
		case geoid     = "GEOID"
		/// The physical surface beneath the measurement.
		case surface   = "SURFACE"
		/// An external measurement or estimate. (e.g. Barometric)
		case external  = "EXTERNAL"
	}
}
