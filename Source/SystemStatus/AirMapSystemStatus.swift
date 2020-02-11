//
//  AirMapSystemStatus.swift
//  AirMapSDK
//
//  Created by Michael Odere on 1/27/20.
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

public struct AirMapSystemStatus {
	public let level: AirMapSystemStatus.Level
	public let message: String?

	public enum Level: String {
		case normal
		case maintenance
		case degraded
		case failed
		case unknown

		public var description: String {
			let localized = LocalizedStrings.SystemStatus.self
			switch self {
			case .degraded:
				return localized.degradedLevel
			case .failed:
				return localized.failedLevel
			case .maintenance:
				return localized.maintenanceLevel
			case .normal:
				return localized.normalLevel
			case .unknown:
				return localized.unknownLevel
			}
		}
	}
}

extension AirMapSystemStatus: ImmutableMappable {
	public init(map: Map) throws {
		level       = (try? map.value("level")) ?? .unknown
		message     = try? map.value("message")
	}
}
