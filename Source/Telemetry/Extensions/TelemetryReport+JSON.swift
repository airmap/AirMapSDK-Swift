//
//  TelemetryReport+JSON.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/15/19.
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

extension ArchivedTelemetry: ImmutableMappable {

	public init(map: Map) throws {
		let fields  = try map.value("fields") as [String]
		reports     = try map.value("values", using: TelemetryReportTransform(fields: fields))
	}
}

extension ArchivedTelemetry.Report: ImmutableMappable {

	public init(map: Map) throws {
		timestamp = try map.value("timestamp", using: ISO8601DateTransform())

		let lat = try map.value("latitude_degrees") as Double
		let lon = try map.value("longitude_degrees") as Double
		coordinate = Coordinate2D(latitude: lat, longitude: lon)

		let height = try map.value("altitude_meters") as Meters
		altitude = Altitude(height: height, reference: .unknown)
	}
}

struct TelemetryReportTransform: TransformType {

	static let mapper = Mapper<ArchivedTelemetry.Report>()

	typealias Object = ArchivedTelemetry.Report
	typealias JSON = [Any]

	let fields: [String]

	func transformFromJSON(_ values: Any?) -> ArchivedTelemetry.Report? {
		guard let values = values as? [Any] else { return nil }
		var hash = [String: Any]()
		for (key, value) in zip(fields, values) {
			hash[key] = value
		}
		return TelemetryReportTransform.mapper.map(JSON: hash)
	}

	func transformToJSON(_ value: ArchivedTelemetry.Report?) -> [Any]? {
		assertionFailure("Not Implemented")
		return nil
	}
}
