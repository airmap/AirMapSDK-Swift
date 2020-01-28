//
//  SystemStatus.swift
//  AirMapSDK
//
//  Created by Michael Odere on 1/27/20.
//

import ObjectMapper

public struct SystemStatus {
	public let level: SystemStatus.Level
	public let message: String

	public enum Level: String {
		case unkown
		case normal
		case maintenance
		case degraded
		case failed
	}

}


extension SystemStatus: ImmutableMappable {
	public init(map: Map) throws {
		do {
			level       = try map.value("level", using: SystemStatusLevelTransform())
			message     =  try map.value("message")
		}
		catch {
			AirMap.logger.error("Failed to parse SystemStatus", metadata: ["error": .string(error.localizedDescription)])
			throw error
		}
	}
}

class SystemStatusLevelTransform: TransformType {

	typealias Object = SystemStatus.Level
	typealias JSON = String

	func transformFromJSON(_ value: Any?) -> SystemStatus.Level? {
		if let string = value as? String {
			return SystemStatus.Level(rawValue: string)
		}
		return nil
	}

	func transformToJSON(_ value: SystemStatus.Level?) -> String? {
		if let level = value {
			return level.rawValue
		}
		return nil
	}
}
