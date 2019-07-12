//
//  GeneratedMessage+AirMap.swift
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

import ProtocolBuffers

typealias ProtoBufMessage = GeneratedMessage

extension ProtoBufMessage {
	
	enum MessageType: UInt16 {
		case position  = 1
		case speed     = 2
		case attitude  = 3
		case barometer = 4
	}
	
	var messageType: MessageType {
		switch self {
		case is Airmap.Telemetry.Position:
			return .position
		case is Airmap.Telemetry.Attitude:
			return .attitude
		case is Airmap.Telemetry.Speed:
			return .speed
		case is Airmap.Telemetry.Barometer:
			return .barometer
		default:
			fatalError("Unsupported Message Type")
		}
	}
	
	func telemetryBytes() -> [UInt8] {
		
		var bytes = [UInt8]()
		
		bytes += messageType.rawValue.bigEndian.bytes
		bytes += UInt16(serializedSize()).bigEndian.bytes
		bytes += data().bytes
		
		return bytes
	}
	
}
