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
	public let airMapApiKey: String
	
	/// An optional Mapbox access token to use with any map UI elements.
	public let mapboxAccessToken: String?
	
	/// Designated initializer when not providing an airmap.config.json file at the root of the project
	///
	/// - SeeAlso: https://developers.airmap.com/docs/getting-started-ios
	/// - Parameters:
	///   - apiKey: The AirMap API key to use with the AirMap API
	///   - auth0ClientId: A client ID used for user/pilot authentication with AirMap
	///   - mapboxAccessToken: An optional access token used to configure any map UI elements
	public init(apiKey: String, auth0ClientId: String, mapboxAccessToken: String? = nil) {
		
		let config = [
			"airmap": ["api_key": apiKey],
			"auth0":  ["client_id": auth0ClientId],
			"mapbox": ["access_token": mapboxAccessToken as Any]
		]
		
		try! self.init(JSON: config)
	}
	
	/// System used for displaying distance values
	public var distanceUnits: DistanceUnits = .metric
	
	/// Units used for displaying temperature values
	public var temperatureUnits: TemperatureUnits = .celcius

	public var airMapApiDomain: String {
		return host(for: "api")
	}

	public let auth0Host: String
	public let auth0ClientId: String
	public let auth0Scope: String

	let airMapDomain: String
	let airMapApiOverrides: [String: String]?
	let airMapEnvironment: String?
	let airMapPinCertificates: Bool
	let airMapMapStyle: URL?
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
		return [airMapEnvironment, resource, airMapDomain]
			.compactMap({ $0 })
			.joined(separator: ".")
	}

	func override(for resource: String) -> String? {
		return airMapApiOverrides?[resource]
	}
}

// MARK: - JSON Serialization

import ObjectMapper

extension AirMapConfiguration: ImmutableMappable {
	
	public init(map: Map) throws {

		do {
			// Required configuration values
			airMapApiKey          =  try  map.value("airmap.api_key")
			auth0ClientId         =  try  map.value("auth0.client_id")

			// Optional configuration values
			mapboxAccessToken     =  try? map.value("mapbox.access_token")
			auth0Host             = (try? map.value("auth0.host")) ?? "sso.airmap.io"
			auth0Scope            = (try? map.value("auth0.scope")) ?? "openid offline_access"
			airMapDomain          = (try? map.value("airmap.domain")) ?? "airmap.com"
			airMapEnvironment     =  try? map.value("airmap.environment")
			airMapApiOverrides    =  try? map.value("airmap.api_overrides")
			airMapMapStyle        =  try? map.value("airmap.map_style", using: URLTransform())
			airMapPinCertificates = (try? map.value("airmap.pin_certificates")) ?? false
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
