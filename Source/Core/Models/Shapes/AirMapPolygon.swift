//
//  AirMapApiData.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapPolygon: AirMapGeometry, Mappable {

	public var coordinates: [CLLocationCoordinate2D]!
	
	/**
	Returns key value parameters
	
	- returns: [String: AnyObject]
	*/
	override public func params() -> [String: AnyObject] {
		
		var params = [String: AnyObject]()
		
		if var coords = coordinates where coords.count >= 3 {
			coords.append(coords.first!)
			params["type"] = "Polygon"
			params["coordinates"] = [coords.map { [$0.longitude, $0.latitude] } as [[Double]]]
		}
		
		return params
	}

	public func mapping(map: Map) {
		var coords: [[Double]] = []
		coords      <-  map["coordinates"]
		coordinates = coords
			.map { ($0[1], $0[0]) }
			.map(CLLocationCoordinate2D.init)
	}
	
	public override init() {
		super.init()
	}
	
	required public init?(_ map: Map) {
		super.init()
	}

}
