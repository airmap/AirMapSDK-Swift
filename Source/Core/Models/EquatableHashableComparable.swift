//
//  EquatableHashable.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/6/17.
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

// INTERNAL: Extends object for Hashable, Equatable, and/or Comparable Protocol Conformance

extension AirMapRuleset: Hashable, Equatable, Comparable {
	
	internal var order: Int {
		return [.pickOne, .optional, .required].index(of: type)!
	}
	
	public func hash(into hasher: inout Hasher) {
		return hasher.combine(id.hashValue)
	}

	public static func ==(lhs: AirMapRuleset, rhs: AirMapRuleset) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
	
	public static func <(lhs: AirMapRuleset, rhs: AirMapRuleset) -> Bool {
		return lhs.order < rhs.order && lhs.name < rhs.name
	}
}

extension AirMapAdvisory: Equatable, Hashable {
	
	public func hash(into hasher: inout Hasher) {
		return hasher.combine(id.hashValue)
	}

	public static func ==(lhs: AirMapAdvisory, rhs: AirMapAdvisory) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}

extension AirMapAdvisory.Color: Comparable {
	
	public static var all: [AirMapAdvisory.Color] {
		return [.red, .orange, .yellow, .green]
	}
	
	public var order: Int {
		return AirMapAdvisory.Color.all.index(of: self)!
	}
	
	public static func <(lhs: AirMapAdvisory.Color, rhs: AirMapAdvisory.Color) -> Bool {
		return lhs.order < rhs.order
	}
}

extension AirMapAircraft: Equatable, Hashable {
	
	public static func ==(lhs: AirMapAircraft, rhs: AirMapAircraft) -> Bool {
		return lhs.id == rhs.id
	}
	
	public func hash(into hasher: inout Hasher) {
		return hasher.combine(id?.hashValue ?? model.id.hashValue)
	}

}

extension AirMapAircraftManufacturer: Equatable, Hashable {
	
	public static func ==(lhs: AirMapAircraftManufacturer, rhs: AirMapAircraftManufacturer) -> Bool {
		return lhs.id == rhs.id
	}
	
	public func hash(into hasher: inout Hasher) {
		return hasher.combine(id.hashValue)
	}
}

extension AirMapAircraftModel: Equatable, Hashable {
	
	public static func ==(lhs: AirMapAircraftModel, rhs: AirMapAircraftModel) -> Bool {
		return lhs.id == rhs.id
	}
	
	public func hash(into hasher: inout Hasher) {
		return hasher.combine(id.hashValue)
	}
}

extension AirMapAirspace: Equatable, Hashable {
	
	static func ==(lhs: AirMapAirspace, rhs: AirMapAirspace) -> Bool {
		return lhs.id == rhs.id
	}
	
	public func hash(into hasher: inout Hasher) {
		return hasher.combine(id.hashValue)
	}
}

extension AirMapFlight: Equatable, Hashable {
	
	public func hash(into hasher: inout Hasher) {
		return hasher.combine(id?.rawValue.hashValue ?? createdAt.hashValue)
	}

	static public func ==(lhs: AirMapFlight, rhs: AirMapFlight) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}

extension AirMapJurisdiction: Hashable, Equatable, Comparable {
	
	public static func ==(lhs: AirMapJurisdiction, rhs: AirMapJurisdiction) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
	
	public func hash(into hasher: inout Hasher) {
		return hasher.combine(id.hashValue)
	}
	
	public static func <(lhs: AirMapJurisdiction, rhs: AirMapJurisdiction) -> Bool {
		return lhs.region.order < rhs.region.order
	}
}

extension AirMapJurisdiction.Region {
	
	var order: Int {
		return [.federal, .federalBackup, .federalStructureBackup, .state, .county, .city, .local].index(of: self)!
	}
}

extension AirMapFlightFeature: Hashable, Equatable {
	
	public func hash(into hasher: inout Hasher) {
		return hasher.combine(id.hashValue)
	}

	public static func ==(lhs: AirMapFlightFeature, rhs: AirMapFlightFeature) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}

extension AirMapFlightFeature.Status: Comparable {
	
	var order: Int {
		return [.conflicting, .missingInfo, .informational, .notConflicting, .unevaluated].index(of: self)!
	}
	
	public static func <(lhs: AirMapFlightFeature.Status, rhs: AirMapFlightFeature.Status) -> Bool {
		return lhs.order < rhs.order
	}
}
