//
//  AirMapConfiguration.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/10/16.
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

/// Configuration class for the AirMap SDK. May be initialized programmatically or from an airmap.config.json file.
public struct AirMapConfiguration {
		
	/// The AirMap API key that was used to initialize the SDK. Required.
	public let apiKey: String

	/// Designated initializer when not providing an airmap.config.json file at the root of the project
	///
	/// - SeeAlso: https://developers.airmap.com/docs/getting-started-ios
	/// - Parameters:
	///   - apiKey: The AirMap API key to use with the AirMap API
	///   - clientId: A client ID used for user/pilot authentication with AirMap
	///   - mapboxAccessToken: An optional access token used to configure any map UI elements
	public init(apiKey: String, clientId: String, mapboxAccessToken: String? = nil) {

		try! self.init(JSON: [
			"airmap": [ "api_key": apiKey, "client_id": clientId],
			"mapbox": [ "access_token": mapboxAccessToken as Any]
			])
	}
	
	/// System used for displaying distance values
	public var distanceUnits: DistanceUnits = .metric
	
	/// Units used for displaying temperature values
	public var temperatureUnits: TemperatureUnits = .celcius

	public var apiHost: String {
		return host(for: "api")
	}

	public let domain: String
	let apiOverrides: [String: String]?
	let environment: String?
	let pinCertificates: Bool
	let mapStyle: URL?
	let clientId: String

	/// An optional string for identifying the configuration used.
	public let name: String?

	/// An optional Mapbox access token to use with any map UI elements.
	public let mapboxAccessToken: String?
}

extension AirMapConfiguration {
	
	// A custom configuration manually set at runtime
	static var custom: AirMapConfiguration?

	// The default configuration loaded from a JSON configuration file
	static var json: AirMapConfiguration = {
		
		#if os(Linux)
			let configPath = "./airmap.config.json"
		#else
			let configPath = Bundle.main.path(forResource: "airmap.config", ofType: "json") ?? "missing"
		#endif
		
		do {
			let jsonString = try String(contentsOfFile: configPath)
			return try AirMapConfiguration(JSONString: jsonString)
		}
		catch {
			fatalError(
				"The `airmap.config.json` file required to configure the AirMapSDK is missing. " +
					"Please reference the documentation for more information. " +
				"https://developers.airmap.com/docs/getting-started-ios"
			)
		}
	}()
}

extension AirMapConfiguration {

	func host(for resource: String) -> String {
		return [environment, resource, domain]
			.compactMap({ $0 })
			.joined(separator: ".")
	}

	func override(for resource: String) -> String? {
		return apiOverrides?[resource]
	}
}

// MARK: - JSON Serialization

import ObjectMapper

extension AirMapConfiguration: ImmutableMappable {
	
	public init(map: Map) throws {

		do {
			// Required AirMap SDK configuration values
			apiKey   = try map.value("airmap.api_key")
			clientId = try map.value("airmap.client_id")

			// Optional AirMap SDK configuration values
			name            =  try? map.value("name")
			domain          = (try? map.value("airmap.domain")) ?? "airmap.com"
			environment     =  try? map.value("airmap.environment")
			apiOverrides    =  try? map.value("airmap.api_overrides")
			mapStyle        =  try? map.value("airmap.map_style", using: URLTransform())
			pinCertificates = (try? map.value("airmap.pin_certificates")) ?? false

			// Third-party configuration values
			mapboxAccessToken = try? map.value("mapbox.access_token")
		}

		catch let error as MapError {
			fatalError(
				"Configuration is missing the required \(error.key!) key and value. If you have recently updated " +
				"this SDK, you may need to visit the AirMap developer portal at https://dashboard.airmap.io/developer/ " +
				"for an updated airmap.config.json file."
			)
		}
		
		#if !os(Linux)
			if Locale.current.usesMetricSystem {
				temperatureUnits = .celcius
				distanceUnits = .metric
			} else {
				temperatureUnits = .fahrenheit
				distanceUnits = .imperial
			}
		#endif
	}
}
