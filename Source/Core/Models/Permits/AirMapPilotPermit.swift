//
//  AirMapPilotPermit.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/19/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapPilotPermit: NSObject {

	public enum PermitStatus: String {
		case accepted
		case rejected
		case pending
		case expired
	}

	public var id = ""
	public var permitId = ""
	public var status: PermitStatus?
	public var createdAt: Date = Date()
	public var updatedAt: Date!
	public var expiresAt: Date!
	public var customProperties = [AirMapPilotPermitCustomProperty]()
	public var permitDetails: AirMapPilotPermitShortDetails!
	public var organization: AirMapOrganization?

	public override init() {}
	
	public required init?(map: Map) {}
	
	public override var hashValue: Int {
		return id.isEmpty ? permitId.hashValue : id.hashValue
	}
	
}

extension AirMapPilotPermit: Mappable {

	public func mapping(map: Map) {

		let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)

		id                <-  map["id"]
		organization      <-  map["organization"]
		createdAt         <- (map["created_at"], dateTransform)
		updatedAt         <- (map["updated_at"], dateTransform)
		expiresAt         <- (map["expiration"], dateTransform)
		customProperties  <-  map["custom_properties"]
		permitDetails     <-  map["permit"]
		status            <-  map["status"]
		
		if map.JSON.keys.contains("permit") {
			permitId <- map["permit.id"]
		} else {
			permitId <- map["permit_id"]
		}
	}

	func params() -> [String: Any] {

		return [
			"id": id,
			"custom_properties": customProperties.toJSON()
		]
	}

}

public func ==(lhs: AirMapPilotPermit, rhs: AirMapPilotPermit) -> Bool {
	if lhs.id.isEmpty || rhs.id.isEmpty {
		return lhs.permitId == rhs.permitId
	} else {
		return lhs.id == rhs.id
	}
}
