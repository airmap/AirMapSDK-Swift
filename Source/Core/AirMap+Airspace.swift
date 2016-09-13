//
//  AirMap+Airspace.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/29/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

private typealias AirMap_Airspace = AirMap
extension AirMap_Airspace {

	public typealias AirMapAirspaceResponseHandler = (AirMapAirspace?, NSError?) -> Void
	
	/**
	
	Get extended details about an `AirMapAirspace` by id
	
	- parameter modelId: `String`  The id of the airspace
	- parameter handler: `(AirMapAirspace?, NSError?) -> Void`
	
	*/
	public class func getAirspace(airspaceId: String, handler: AirMapAirspaceResponseHandler) {
		airspaceClient.getAirspace(airspaceId).subscribe(handler)
	}

}
