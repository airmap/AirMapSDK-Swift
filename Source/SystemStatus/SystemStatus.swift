//
//  SystemStatus.swift
//  AirMapSDK
//
//  Created by Michael Odere on 1/27/20.
//

import ObjectMapper

public enum SystemStatusLevel: String {
	case normal = "LEVEL_NORMAL"
	case downgraded = "LEVEL_DEGRADED"
	case unrecognized
}

public struct SystemStatus {
	public let level: SystemStatusLevel
	public let message: String
	public let generatedAt: Date
	public let submittedAt: Date
}


extension SystemStatus: ImmutableMappable {

	public init(map: Map) throws {
		do {
			level       = try map.value("level", using: SystemStatusLevelTransform())
			message     =  try map.value("message")
			generatedAt =  try map.value("generated_at", using: DateTransform())
			submittedAt =  try map.value("submitted_at", using: DateTransform())
		}
		catch {
			AirMap.logger.error("Failed to parse SystemStatus", metadata: ["error": .string(error.localizedDescription)])
			throw error
		}
	}
}

class SystemStatusLevelTransform: TransformType {

	typealias Object = SystemStatusLevel
	typealias JSON = String

	func transformFromJSON(_ value: Any?) -> SystemStatusLevel? {
		if let string = value as? String {
			return SystemStatusLevel(rawValue: string)
		}
		return nil
	}

	func transformToJSON(_ value: SystemStatusLevel?) -> String? {
		if let level = value {
			return level.rawValue
		}
		return nil
	}
}
