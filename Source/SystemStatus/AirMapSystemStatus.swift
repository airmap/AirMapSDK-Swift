//
//  AirMapSystemStatus.swift
//  AirMapSDK
//
//  Created by Michael Odere on 1/27/20.
//

import ObjectMapper

public struct AirMapSystemStatus {
	public let level: AirMapSystemStatus.Level
	public let message: String

	public enum Level: String, CaseIterable {
		case unkown
		case normal
		case maintenance
		case degraded
		case failed
	}

	init(level: AirMapSystemStatus.Level, message: String) {
		self.level = level
		self.message = message
	}

}

extension AirMapSystemStatus: ImmutableMappable {
	public init(map: Map) throws {
		do {
			level       = try map.value("level", using: AirMapSystemStatusLevelTransform())
			message     = try map.value("message")
		}
		catch {
			AirMap.logger.error("Failed to parse SystemStatus", metadata: ["error": .string(error.localizedDescription)])
			throw error
		}
	}
}

class AirMapSystemStatusLevelTransform: TransformType {

	typealias Object = AirMapSystemStatus.Level
	typealias JSON = String

	func transformFromJSON(_ value: Any?) -> AirMapSystemStatus.Level? {
		if let string = value as? String {
			return AirMapSystemStatus.Level(rawValue: string)
		}
		return nil
	}

	func transformToJSON(_ value: AirMapSystemStatus.Level?) -> String? {
		if let level = value {
			return level.rawValue
		}
		return nil
	}
}
