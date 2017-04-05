//
//  AirMapStatus.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

/// A list of all airspace objects intersecting with the proposed area. Includes status color and distance.
@objc
open class AirMapStatus : NSObject {

	public enum StatusColor: String {
		case red
		case yellow
		case green
		case gray
		
		public static var allColors: [StatusColor] {
			return [.red, .yellow, .green, .gray]
		}
		
		public var description: String {
			
			let localized = LocalizedStrings.Status.self
			
			switch self {
			case .red:
				return localized.redDescription
			case .yellow:
				return localized.yellowDescription
			case .green, .gray:
				return localized.greenDescription
			}
		}
	}
	
	@objc public enum AirMapStatusColor: Int, RawRepresentable {
		case red
		case yellow
		case green
		case gray
		
		public typealias RawValue = String

		public var rawValue: RawValue {
			switch self {
				case .red:
					return StatusColor.red.rawValue
				case .yellow:
					return StatusColor.yellow.rawValue
				case .green:
					return StatusColor.green.rawValue
				case .gray:
					return StatusColor.gray.rawValue;
			}
		}
		
		public init?(rawValue: RawValue) {
			switch rawValue {
				case "red":
					self = .red
				case "yellow":
					self = .yellow
				case "green":
					self = .green
				case "gray":
					self = .gray
				default:
					self = .gray
			}
		}
	}

	public fileprivate(set) var maxSafeDistance: Meters = 0
	public fileprivate(set) var advisoryColor = StatusColor.gray
	public fileprivate(set) var advisories = [AirMapStatusAdvisory]()
	public fileprivate(set) var applicablePermits = [AirMapAvailablePermit]()
	public fileprivate(set) var organizations = [AirMapOrganization]()
	public fileprivate(set) var weather: AirMapStatusWeather?
	
	public required init(map: Map) {}

	public var requiresPermits: Bool {
		return availablePermits.count > 0
	}
	
	public var supportsDigitalNotice: Bool {
        return advisories
			.filter { $0.requirements?.notice?.digital == true }
            .flatMap { $0.requirements?.notice }
            .count > 0
	}
    
    public var supportsNotice: Bool {
        return advisories
            .filter { $0.requirements?.notice != nil }
            .flatMap { $0.requirements?.notice }
            .count > 0
    }
	
	public var color: AirMapStatusColor {
		return AirMapStatusColor(rawValue: advisoryColor.rawValue)!
	}
	
	internal var availablePermits: [AirMapAvailablePermit] {
		return Array(Set(advisories.flatMap { $0.availablePermits }))
	}
	
	internal func availablePermitsFor(_ organization: AirMapOrganization) -> [AirMapAvailablePermit] {
		return availablePermits.filter {
			$0.organizationId == organization.id
		}
	}
	
	internal func applicablePermitsFor(_ organization: AirMapOrganization) -> [AirMapAvailablePermit] {
		return applicablePermits.filter {
			$0.organizationId == organization.id
		}
	}
}

extension AirMapStatus: Mappable {

	public func mapping(map: Map) {
		
		organizations     <- map["organizations"]
		maxSafeDistance   <- map["max_safe_distance"]
		advisories        <- map["advisories"]
		weather           <- map["weather"]
		advisoryColor     <- map["advisory_color"]
		applicablePermits <- map["applicable_permits"]
		
		advisories.forEach { advisory in
			advisory.organization = organizations.filter { $0.id == advisory.organizationId }.first
			advisory.availablePermits.forEach { permit in
				permit.organizationId = advisory.organizationId!
			}
		}
	}
	
}
