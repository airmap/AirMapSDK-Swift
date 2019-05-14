//
//  AirMap+Traffic.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
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

@objc public protocol AirMapTrafficObserver: class {
	func airMapTrafficServiceDidAdd(_ traffic: [AirMapTraffic])
	func airMapTrafficServiceDidUpdate(_ traffic: [AirMapTraffic])
	func airMapTrafficServiceDidRemove(_ traffic: [AirMapTraffic])
	@objc optional func airMapTrafficServiceDidConnect()
	@objc optional func airMapTrafficServiceDidDisconnect()
	@objc optional func airMapTrafficServiceDidReceive(_ message: String)
}

extension AirMap {
	
	public static var trafficDelegate: AirMapTrafficObserver? {
		didSet { trafficService.delegate = trafficDelegate }
	}
	
	/// Suspend all active traffic alerts
	/// Typically called when the app enters the background.
	public static func suspendTraffic() {
		trafficService.disconnect()
	}
	
	/// Resume all active traffic alerts
	/// Typically called when the app enters the foreground.
	public static func resumeTraffic() {
		trafficService.connect()
	}

	/// Start observing traffic from a flight immediately
	/// Typically called when a creating a new flight.
	public static func startObservingTraffic(for flight: AirMapFlight) {
		trafficService.startObservingTraffic(for: flight)
	}

}
