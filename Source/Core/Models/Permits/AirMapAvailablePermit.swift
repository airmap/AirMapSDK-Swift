//
//  AirMapAvailablePermit.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapAvailablePermit: NSObject {

	public internal(set) var id = ""
	public fileprivate(set) var name = ""
	public fileprivate(set) var info = ""
	public fileprivate(set) var infoUrl = ""
	public fileprivate(set) var singleUse: Bool = false
	public fileprivate(set) var validForInMinutes: Int?
	public fileprivate(set) var validUntil: Date?
	public internal(set) var customProperties = [AirMapPilotPermitCustomProperty]()
	public internal(set) var organizationId = ""
	
	internal override init() {}
	public required init?(map: Map) {}
	
	fileprivate static let validityFormatter: DateComponentsFormatter = {
		let f = DateComponentsFormatter()
		f.allowedUnits = [.year, .month, .day, .hour, .minute]
		f.zeroFormattingBehavior = .dropAll
		f.allowsFractionalUnits = false
		f.unitsStyle = .full
		return f
	}()

	public func validityString() -> String? {
		guard let minutes = validForInMinutes else { return nil }
		return AirMapAvailablePermit.validityFormatter.string(from: TimeInterval(minutes * 60))
	}
	
	public override var hashValue: Int {
		return id.hashValue
	}
}

extension AirMapAvailablePermit: Mappable {

	public func mapping(map: Map) {

		let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)

		id                  <-  map["id"]
		organizationId      <-  map["organization_id"]
		name                <-  map["name"]
		info                <-  map["description"]
		infoUrl             <-  map["description_url"]
		singleUse           <-  map["single_use"]
		validForInMinutes   <-  map["valid_for"]
		validUntil          <- (map["valid_until"], dateTransform)
		customProperties    <-  map["custom_properties"]
	}
	
	public func params() -> [String: Any] {
		
		return [
			"id": id,
			"custom_properties": customProperties.map { $0.params() }
		]
	}
}

public func ==(lhs: AirMapAvailablePermit, rhs: AirMapAvailablePermit) -> Bool {
	return lhs.id == rhs.id
}

