//
//  AirMap+Internal.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift

typealias AirMap_Internal = AirMap
extension AirMap_Internal {

	@nonobjc internal static let aircraftClient = AircraftClient()
	@nonobjc internal static let airspaceClient = AirspaceClient()
	@nonobjc internal static let flightClient = FlightClient()
	@nonobjc internal static let permitClient = PermitClient()
	@nonobjc internal static let pilotClient = PilotClient()
	@nonobjc internal static let statusClient = StatusClient()
	@nonobjc internal static let mappingService = MappingService()
	@nonobjc internal static let authSession = AirMapAuthSession()
	@nonobjc internal static let authClient = AirMapAuthClient()

	#if AIRMAP_TELEMETRY
	@nonobjc internal static let telemetrySocket = TelemetrySocket()
	#endif

	#if AIRMAP_TRAFFIC
	@nonobjc internal static let trafficService  = TrafficService()
	#endif

	@nonobjc internal static let disposeBag = DisposeBag()

	@nonobjc internal static func hasValidCredentials() -> Bool {
		return authSession.hasValidCredentials()
	}

}
