//
//  AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 5/26/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

/// An wrapper enum that encapsulates all responses from the AirMapSDK returning only one of two cases: value or error
///
/// - value: The requested value
/// - error: An error describing the failure
public enum Result<T> {
	case value(T)
	case error(AirMapError)
}

/// The pricipal AirMapSDK class that is extended by individual services such as Status, Flight, Pilot, Rules, etc.
public class AirMap {
	
	// The current environment settings and configuration of the AirMap SDK
    private static var customConfiguration: AirMapConfiguration?

    public static var configuration: AirMapConfiguration {
        get {
            if customConfiguration == nil {
                customConfiguration = .default
            }
            return customConfiguration!
        }

        set {
            customConfiguration = newValue
        }
    }

	/// A JWT auth token that identifies the logged in user accessing the service. Required for all authenticated endpoints.
	public static var authToken: String? {
		didSet { authSession.authToken = authToken }
	}

	/// A Boolean value, if true, will use pinned certificates to validate the AirMap server trust.  Defaults to false.
	public static var pinCertificates: Bool = false {
		didSet { authSession.enableCertificatePinning = pinCertificates }
	}

	/// Suspend all active realtime services, including traffic alerts and telemetry updates
	/// Typically called when the app enters the background.
	public static func suspend() {
		#if AIRMAP_TRAFFIC
			trafficService.disconnect()
		#endif
	}

	/// Resume all available realtime services, including traffic alerts and telemetry updates
	/// Typically called when the app enters the foreground.
	public static func resume() {
		#if AIRMAP_TRAFFIC
			trafficService.connect()
		#endif
	}
	
	private init() {}
}
