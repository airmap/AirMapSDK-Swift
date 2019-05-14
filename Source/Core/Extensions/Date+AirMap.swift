//
//  Date+AirMap.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 5/26/16.
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

public extension Date {
	
    func iso8601String() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		dateFormatter.dateFormat = Constants.Api.dateFormat
		return dateFormatter.string(from: self)
	}
	
	func isInFuture() -> Bool {
		return self > Date()
	}
	
	func isInPast() -> Bool {
		return self < Date()
	}
}

extension TimeInterval {
	
	var milliseconds: UInt64 {
		return UInt64(self * 1000)
	}
}
