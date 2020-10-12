//
//  AirMapIdentifier.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 12/13/17.
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

public protocol AirMapIdentifier: RawRepresentable, CustomStringConvertible, Hashable where RawValue: Hashable & Equatable {}

extension AirMapIdentifier {
	
	public var hashValue: Int {
		return rawValue.hashValue
	}
	
	public static func ==(lhs: Self, rhs: Self) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}

public protocol AirMapStringIdentifierType: ExpressibleByStringLiteral, AirMapIdentifier where RawValue == String {}

public struct AirMapStringIdentifier<Object>: AirMapStringIdentifierType {
	
	public typealias RawValue = String
	public typealias StringLiteralType = String

	public let rawValue: RawValue
	
	public init(rawValue: RawValue) {
		self.rawValue = rawValue
	}
	
	public init(stringLiteral: StringLiteralType) {
		self.rawValue = stringLiteral
	}

    public var description: String {
        return rawValue.description
    }
}

public protocol AirMapIntegerIdentifierType: ExpressibleByIntegerLiteral, AirMapIdentifier where RawValue == Int {}

public struct AirMapIntegerIdentifier<Object>: AirMapIntegerIdentifierType {
	
	public typealias RawValue = Int
	public typealias IntegerLiteralType = Int
	
	public let rawValue: RawValue
	
	public init(rawValue: RawValue) {
		self.rawValue = rawValue
	}
	
	public init(integerLiteral: IntegerLiteralType) {
		self.rawValue = integerLiteral
	}

    public var description: String {
        return rawValue.description
    }
}

// Type-safe aliases for string identifiers specific to AirMap objects
public typealias AirMapAdvisoryId              = AirMapStringIdentifier<AirMapAdvisory>
public typealias AirMapAgreementId             = AirMapStringIdentifier<AirMapAgreement>
public typealias AirMapAircraftId              = AirMapStringIdentifier<AirMapAircraft>
public typealias AirMapAircraftManufacturerId  = AirMapStringIdentifier<AirMapAircraftManufacturer>
public typealias AirMapAircraftModelId         = AirMapStringIdentifier<AirMapAircraftModel>
public typealias AirMapFlightId                = AirMapStringIdentifier<AirMapFlight>
public typealias AirMapAuthorityId             = AirMapStringIdentifier<AirMapAuthority>
public typealias AirMapRulesetId               = AirMapStringIdentifier<AirMapRuleset>
public typealias AirMapFlightFeatureId         = AirMapStringIdentifier<AirMapFlightFeature>
public typealias AirMapPilotId                 = AirMapStringIdentifier<AirMapPilot>
public typealias AirMapFlightPlanId            = AirMapStringIdentifier<AirMapFlightPlan>

internal typealias AirMapAirspaceId            = AirMapStringIdentifier<AirMapAirspace>

// Type-safe aliases for integer identifiers specific to AirMap objects
public typealias AirMapJurisdictionId = AirMapIntegerIdentifier<AirMapJurisdiction>

import ObjectMapper

// Transform from typed ids to raw value
class AirMapIdTransform<T: AirMapIdentifier>: TransformType {
	
	typealias Object = T
	typealias JSON = T.RawValue
	
	func transformFromJSON(_ value: Any?) -> T? {
		if let value = value as? T.RawValue {
			return T(rawValue: value)
		}
		return nil
	}
	
	func transformToJSON(_ value: T?) -> T.RawValue? {
		if let id = value {
			return id.rawValue
		}
		return nil
	}
}

class AirMapIdDictionaryTransform<T: AirMapIdentifier>: TransformType {
	
	typealias Object = [T: Any]
	typealias JSON = [T.RawValue: Any]
	
	func transformFromJSON(_ value: Any?) -> [T : Any]? {
		
		guard let rawDict = value as? [T.RawValue: Any] else { return nil }
		
		let idKeyValues = rawDict.map { (key, value) in
			(T(rawValue: key)!, value)
		}
		return Dictionary.init(uniqueKeysWithValues: idKeyValues)
	}
	
	func transformToJSON(_ value: [T : Any]?) -> [T.RawValue : Any]? {
		guard let value = value else { return nil }
		let rawKeyValues = value.map({ (key, value) in
			(key.rawValue, value)
		})
		return Dictionary.init(uniqueKeysWithValues: rawKeyValues)
	}
}
