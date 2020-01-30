//
//  AirMap+SystemStatus.swift
//  AirMapSDK
//
//  Created by Michael Odere on 1/30/20.
//

import Foundation

public protocol AirMapSystemStatusDelegate {
	func airMapSystemStatusUpdate(_ status: AirMapSystemStatus)
}

extension AirMap {
	public static var systemStatusDelegate: AirMapSystemStatusDelegate? {
		didSet { systemStatusService.delegate = systemStatusDelegate }
	}

	/// Suspend all active status alerts
	/// Typically called when the app enters the background.
	public static func suspendSystemStatus() {
//		systemStatusService.disconnect()
	}

	/// Resume all active status alerts
	/// Typically called when the app enters the foreground.
	public static func resumeSystemStatus() {
//		systemStatusService.connect()
	}
}
