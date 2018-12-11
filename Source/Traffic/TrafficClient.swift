//
//  TrafficClient.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/2/16.
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

import SwiftMQTT
import ObjectMapper

internal class TrafficClient: MQTTSession {
	
	init() {
		super.init(
			host: Constants.Traffic.host,
			port: Constants.Traffic.port,
			clientID: Constants.Traffic.clientId,
			cleanSession: true,
			keepAlive: Constants.Traffic.keepAlive,
			useSSL: true
		)
	}
	var currentChannels = [String]()
	
	deinit {
		disconnect()
	}
	
}
