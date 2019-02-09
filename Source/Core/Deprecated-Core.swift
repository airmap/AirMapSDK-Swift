//
//  Deprecated-Core.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/25/17.
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

extension AirMapAdvisory {
	
	@available(*, unavailable, message: "Removed")
	public var distance: Meters {
		return 0
	}
}

extension AirMap {

	@available(*, unavailable, message: "Removed now that SDK manages refreshing access tokens")
	public static func refreshAuthToken(_ completion: @escaping (Result<AirMapToken>) -> Void) {}

	@available(*, unavailable, message: "Use Result<Void> instead of Result<AirMapToken>")
	public static func performAnonymousLogin(userId: String, completion: @escaping (Result<AirMapToken>) -> Void) {}
}
