//
//  Message+AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 12/5/16.
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

import SwiftProtobuf

enum MessageType: UInt16 {
	case position  = 1
	case speed     = 2
	case attitude  = 3
	case barometer = 4
}

extension Message {

	var messageType: MessageType {
		switch self {
		case is Telemetry_Position:
			return .position
		case is Telemetry_Attitude:
			return .attitude
		case is Telemetry_Speed:
			return .speed
		case is Telemetry_Barometer:
			return .barometer
		default:
			fatalError("Unsupported Message Type")
		}
	}
	
	func telemetryBytes() throws -> [UInt8] {

		let data = try serializedData()

		var bytes = [UInt8]()
		bytes += messageType.rawValue.bigEndian.bytes
		bytes += UInt16(data.count).bigEndian.bytes
		bytes += data.bytes
		
		return bytes
	}
	
}
