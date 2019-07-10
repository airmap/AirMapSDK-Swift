//
//  SampleRate.swift
//  AirMapSDK
//
//  Created by Michael Odere on 5/15/19.
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

public enum SampleRate: CustomStringConvertible {
	
	case milliseconds(Int)
	case seconds(Int)
	case minutes(Int)
	
	public var description: String {
		switch self {
		case .milliseconds(let val):
			return "\(val)ms"
		case .seconds(let val):
			return "\(val)s"
		case .minutes(let val):
			return "\(val)m"
		}
	}
}
