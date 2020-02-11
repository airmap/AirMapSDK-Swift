//
//  AirMap+SystemStatus.swift
//  AirMapSDK
//
//  Created by Michael Odere on 1/30/20.
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

public protocol AirMapSystemStatusDelegate: class {
	func airMapSystemStatusDidUpdate(_ status: AirMapSystemStatus)
	func airMapSystemStatusDidConnect()
	func airMapSystemStatusDidDisconnect(error: Error?)
}

extension AirMap {
	public static var systemStatusDelegate: AirMapSystemStatusDelegate? {
		get { return systemStatusService.delegate }
		set { systemStatusService.delegate = newValue }
	}

	/// Suspend all active status alerts
	/// Typically called when the app enters the background or the user logs out.
	public static func suspendSystemStatus() {
		systemStatusService.disconnect()
	}

	/// Resume all active status alerts
	/// Typically called when the app enters the foreground or the user logs in.
	public static func resumeSystemStatus() {
		systemStatusService.connect()
	}
}
