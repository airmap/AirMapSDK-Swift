//
//  AirMapOrganization.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 11/10/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

open class AirMapOrganization: NSObject {

	open fileprivate(set) var id: String!
	open fileprivate(set) var name: String = ""
	
	public required init?(map: Map) {}
	
	open override var hashValue: Int {
		return id.hashValue
	}
}

extension AirMapOrganization: Mappable {
	
	public func mapping(map: Map) {
		id       <- map["id"]
		name     <- map["name"]
	}
}

public func ==(lhs: AirMapOrganization, rhs: AirMapOrganization) -> Bool {
	return lhs.id == rhs.id
}
