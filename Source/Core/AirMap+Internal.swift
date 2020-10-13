//
//  AirMap+Internal.swift
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

import RxSwift
#if AIRMAP_TELEMETRY
import CocoaAsyncSocket
#endif

extension AirMap {

	internal static let advisoryClient = AdvisoryClient()
	internal static let agreementsClient = AgreementsClient()
	internal static let aircraftClient = AircraftClient()
	internal static let airspaceClient = AirspaceClient()
	internal static let authClient = AuthClient()
	internal static let openIdClient = OpenIdClient()
	internal static let flightClient = FlightClient()
	internal static let flightPlanClient = FlightPlanClient()
	internal static let pilotClient = PilotClient()
	internal static let ruleClient = RuleClient()

	internal static let authService = AuthService()

	#if AIRMAP_TELEMETRY
	internal static let archiveClient = ArchiveClient()
	internal static let telemetryClient = AirMapTelemetry.Client()
	internal static let telemetrySocket = GCDAsyncUdpSocket()
	#endif

	#if AIRMAP_TRAFFIC
	internal static let trafficService = TrafficService()
	#endif

	#if AIRMAP_SYSTEMSTATUS
	internal static let systemStatusService = SystemStatusService()
	#endif

	internal static let disposeBag = DisposeBag()

}
