//
//  AirMap+Traffic.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

@objc public protocol AirMapTrafficObserver: class {
	func airMapTrafficServiceDidAdd(traffic: [AirMapTraffic])
	func airMapTrafficServiceDidUpdate(traffic: [AirMapTraffic])
	func airMapTrafficServiceDidRemove(traffic: [AirMapTraffic])
	optional func airMapTrafficServiceDidConnect()
	optional func airMapTrafficServiceDidDisconnect()
	optional func airMapTrafficServiceDidReceive(message: String)
}

private typealias AirMapTrafficServices = AirMap
extension AirMapTrafficServices {
	
	/**
	
	Setting the traffic delegate automatically
	
	*/
	public static var trafficDelegate: AirMapTrafficObserver? {
		didSet { trafficService.delegate = trafficDelegate }
	}
	
}
