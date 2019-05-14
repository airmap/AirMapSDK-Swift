//
//  Array+AirMap.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 5/3/16.
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

public extension Array where Element: Equatable {
	
    mutating func removeObject(_ object: Element) {
		if let index = self.index(of: object) {
			self.remove(at: index)
		}
	}
	
    mutating func removeObjectsInArray(_ array: [Element]) {
		for object in array {
			self.removeObject(object)
		}
	}
}

extension Sequence {
	
	public func grouped<T: Hashable>(by criteria: (Element) -> T) -> [T: [Element]] {
		var groups: [T: [Element]] = [:]
		for element in self {
			let key = criteria(element)
			if groups.keys.contains(key) {
				groups[key]!.append(element)
			} else {
				groups[key] = [element]
			}
		}
		return groups
	}
}

extension Collection where Iterator.Element: AirMapStringIdentifierType {
	
	public var csv: String {
		return map { $0.rawValue }.joined(separator: ",")
	}
}
