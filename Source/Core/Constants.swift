//
//  Config.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/24/16.
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

#if os(iOS) || os(tvOS)
import UIKit.UIDevice
#endif

import ObjectMapper
import AppAuth
import RxSwift

struct Constants {

	struct Api {

		static var advisoryUrl: String {
			return url(for: "advisory", v: 1)
		}
		static var aircraftUrl: String {
			return url(for: "aircraft", v: 2)
		}
		static var airspaceUrl: String {
			return url(for: "airspace", v: 2)
		}
		static var archiveUrl: String {
			return url(for: "archive", v: 1)
		}
		static var authUrl: String {
			return url(for: "auth", v: 1)
		}
		static var flightUrl: String {
			return url(for: "flight", v: 2)
		}
		static var jurisdictionsUrl: String {
			return Constants.Api.tileDataUrl + "/base-jurisdiction/{z}/{x}/{y}"
		}
		static var pilotUrl: String {
			return url(for: "pilot", v: 2)
		}
		static var rulesUrl: String {
			return url(for: "rules", v: 1)
		}
		static var systemUrl: String {
			return url(for: "system", v: 1)
		}
		static var tileDataUrl: String {
			return url(for: "tiledata", v: 1)
		}

		static func url(for resource: String, v version: Int) -> String {
			if let override = AirMap.configuration.override(for: resource) {
				return override
			}
			var comps = URLComponents()
			comps.scheme = "https"
			comps.host = AirMap.configuration.host(for: "api")
			comps.path = "/" + [resource, "v\(version)"].joined(separator: "/")
			return comps.string!
		}

		// Used only for API date formatting
		static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Ex: 2016-06-30T16:54:17.606Z
		static let dateTransform = CustomDateFormatTransform(formatString: dateFormat)

		static let smsCodeLength = 6
	}

	struct Auth {
		static let identityProvider = "https://\(AirMap.configuration.host(for: "auth"))/realms/airmap/"
		static let scopes = [OIDScopeOpenID, OIDScopeEmail, "airmap-api", "offline_access"]
		static let keychainAuthState = "com.airmap.airmapsdk.auth_state"
		static let termsOfServiceUrl = "https://www.\(AirMap.configuration.domain)/terms"
		static let privacyPolicyUrl = "https://www.\(AirMap.configuration.domain)/privacy"
	}

	struct Telemetry {
		static var host: String {
			if let override = AirMap.configuration.override(for: "telemetry_host") {
				return override
			}
			return AirMap.configuration.host(for: "telemetry")
		}
		
		static var port: UInt16 {
			if let override = AirMap.configuration.override(for: "telemetry_port"), let port = UInt16(override) {
				return port
			}
			return 16060
		}
		
		struct SampleRate {
			static let position:  RxTimeInterval = .milliseconds(200)
			static let attitude:  RxTimeInterval = .milliseconds(200)
			static let speed:     RxTimeInterval = .milliseconds(200)
			static let barometer: RxTimeInterval = .seconds(20)
		}
	}

	struct SystemStatus {
		static let timeout: TimeInterval = 5.0
	}

	struct Traffic {
		static var host: String {
			if let override = AirMap.configuration.override(for: "traffic_host") {
				return override
			}
			return AirMap.configuration.host(for: "mqtt")
		}
		static let port = UInt16(8883)
		static let keepAlive = UInt16(15)
		static let expirationInterval = TimeInterval(30)
		static let alertTopic = "uav/traffic/alert/"
		static let awarenessTopic = "uav/traffic/sa/"
		#if os(OSX)
		static let clientId = UUID().uuidString
		#else
		static let clientId = UIDevice.current.identifierForVendor!.uuidString
		#endif
	}

	struct Maps {
		static let jurisdictionsTileSourceId = "jurisdictions"
		static let jurisdictionsSourceLayerId = "jurisdictions"
		static let jurisdictionsStyleLayerId = "jurisdictions"
		static let backgroundStyleLayerId = "background"
		static let jurisdictionFeatureAttributesKey = "jurisdiction"
		static let airmapLayerPrefix = "airmap"
		static let rulesetSourcePrefix = "airmap_ruleset_"
		static let tileMinimumZoomLevel = 7
		static let tileMaximumZoomLevel = 12
		static let temporalLayerRefreshInterval: RxTimeInterval = .seconds(20)
		static let futureTemporalWindow: TimeInterval = 4*60*60 // 4 hours
		
		static var styleUrl: URL {
			return AirMap.configuration.mapStyle ??
				URL(string: "https://cdn.airmap.com/static/map-styles/0.11.3/")!
		}
	}
}
