//
//  PilotClient.swift
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
import RxSwift

internal class PilotClient: HTTPClient {

	init() {
		super.init(basePath: Constants.Api.pilotUrl)
	}

	enum PilotClientError: Error {
		case invalidPilotIdentifier
		case invalidAircraftIdentifier
	}

	// MARK: Pilot

	func get(_ pilotId: AirMapPilotId) -> Observable<AirMapPilot> {
		AirMap.logger.debug("GET Pilot", pilotId)
		return perform(method: .get, path: "/\(pilotId)")
	}

	func getAuthenticatedPilot() -> Observable<AirMapPilot> {
		AirMap.logger.debug("GET Authenticated Pilot", AirMap.authSession.userId)
		return perform(method: .get, path: "/\(AirMap.authSession.userId)", checkAuth: true)
	}

	func update(_ pilot: AirMapPilot) -> Observable<AirMapPilot> {
		AirMap.logger.debug("Update Pilot", pilot)
		guard let pilotId = pilot.id else { return .error(PilotClientError.invalidPilotIdentifier) }
		return perform(method: .patch, path: "/\(pilotId)", params: pilot.params(), update: pilot, checkAuth: true)
	}
	
	func sendVerificationToken() -> Observable<Void> {
		AirMap.logger.debug("Send Phone Number SMS Verification Token")
		return perform(method: .post, path: "/\(AirMap.authSession.userId)/phone/send_token")
	}

	func verifySMS(token: String) -> Observable<AirMapPilotVerified> {
		AirMap.logger.debug("Verify SMS Token")
		let params = ["token": Int(token) ?? 0]
		return perform(method: .post, path: "/\(AirMap.authSession.userId)/phone/verify_token", params: params)
	}

	// MARK: Aircraft
	
	func listAircraft() -> Observable<[AirMapAircraft]> {
		AirMap.logger.debug("List Aircraft")
		return perform(method: .get, path: "/\(AirMap.authSession.userId)/aircraft", checkAuth: true)
	}

	func getAircraft(_ aircraftId: AirMapAircraftId) -> Observable<AirMapAircraft> {
		AirMap.logger.debug("Get Aircraft")
		return perform(method: .get, path: "/\(AirMap.authSession.userId)/aircraft/\(aircraftId)", checkAuth: true)
	}

	func createAircraft(_ aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		AirMap.logger.debug("Create Aircraft", aircraft)
		return perform(method: .post, path: "/\(AirMap.authSession.userId)/aircraft", params: aircraft.toJSON(), update: aircraft, checkAuth: true)
	}

	func updateAircraft(_ aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		AirMap.logger.debug("Update Aircraft", aircraft)
		guard let aircraftId = aircraft.id, let nickname = aircraft.nickname else { return .error(PilotClientError.invalidAircraftIdentifier) }
		let params = ["nickname" : nickname]
		return perform(method: .patch, path: "/\(AirMap.authSession.userId)/aircraft/\(aircraftId)", params: params, update: aircraft, checkAuth: true)
	}

	func deleteAircraft(_ aircraft: AirMapAircraft) -> Observable<Void> {
		AirMap.logger.debug("Delete Aircraft", aircraft)
		guard let aircraftId = aircraft.id else { return .error(PilotClientError.invalidAircraftIdentifier) }
		return perform(method: .delete, path: "/\(AirMap.authSession.userId)/aircraft/\(aircraftId)", checkAuth: true)
	}
}
