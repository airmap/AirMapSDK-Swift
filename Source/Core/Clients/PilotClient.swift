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
		return withCredentials().flatMap { (credentials) -> Observable<AirMapPilot> in
			AirMap.logger.debug("GET Authenticated Pilot", credentials.pilot)
			return self.perform(method: .get, path: "/\(credentials.pilot)", auth: credentials)
		}
	}

	func update(_ pilot: AirMapPilot) -> Observable<AirMapPilot> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapPilot> in
			AirMap.logger.debug("Update Pilot", pilot)
			guard let pilotId = pilot.id else { return .error(PilotClientError.invalidPilotIdentifier) }
			return self.perform(method: .patch, path: "/\(pilotId)", params: pilot.params(), update: pilot, auth: credentials)
		}
	}
	
	func sendVerificationToken() -> Observable<Void> {
		return withCredentials().flatMap { (credentials) -> Observable<Void> in
			AirMap.logger.debug("Send Phone Number SMS Verification Token")
			return self.perform(method: .post, path: "/\(credentials.pilot)/phone/send_token", auth: credentials)
		}
	}

	func verifySMS(token: String) -> Observable<AirMapPilotVerified> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapPilotVerified> in
			AirMap.logger.debug("Verify SMS Token")
			let params = ["token": Int(token) ?? 0]
			return self.perform(method: .post, path: "/\(credentials.pilot)/phone/verify_token", params: params, auth: credentials)
		}
	}

	// MARK: Aircraft
	
	func listAircraft() -> Observable<[AirMapAircraft]> {
		return withCredentials().flatMap { (credentials) -> Observable<[AirMapAircraft]> in
			AirMap.logger.debug("List Aircraft")
			return self.perform(method: .get, path: "/\(credentials.pilot)/aircraft", auth: credentials)
		}
	}

	func getAircraft(_ aircraftId: AirMapAircraftId) -> Observable<AirMapAircraft> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapAircraft> in
			AirMap.logger.debug("Get Aircraft")
			return self.perform(method: .get, path: "/\(credentials.pilot)/aircraft/\(aircraftId)", auth: credentials)
		}
	}

	func createAircraft(_ aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapAircraft> in
			AirMap.logger.debug("Create Aircraft", aircraft)
			return self.perform(method: .post, path: "/\(credentials.pilot)/aircraft", params: aircraft.toJSON(), update: aircraft, auth: credentials)
		}
	}

	func updateAircraft(_ aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapAircraft> in
			AirMap.logger.debug("Update Aircraft", aircraft)
			guard let aircraftId = aircraft.id, let nickname = aircraft.nickname else { return .error(PilotClientError.invalidAircraftIdentifier) }
			let params = ["nickname" : nickname]
			return self.perform(method: .patch, path: "/\(credentials.pilot)/aircraft/\(aircraftId)", params: params, update: aircraft, auth: credentials)
		}
	}

	func deleteAircraft(_ aircraft: AirMapAircraft) -> Observable<Void> {
		return withCredentials().flatMap { (credentials) -> Observable<Void> in
			AirMap.logger.debug("Delete Aircraft", aircraft)
			guard let aircraftId = aircraft.id else { return .error(PilotClientError.invalidAircraftIdentifier) }
			return self.perform(method: .delete, path: "/\(credentials.pilot)/aircraft/\(aircraftId)", auth: credentials)
		}
	}

}
