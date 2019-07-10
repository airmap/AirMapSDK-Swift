//
//  FlightPlanClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 5/21/16.
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

internal class FlightPlanClient: HTTPClient {
	
	enum FlightPlanClientError: Error {
		case flightPlanDoesntExistCreateFirst
	}

	init() {
		super.init(basePath: Constants.Api.flightUrl)
	}
	
	func create(_ flightPlan: AirMapFlightPlan) -> Observable<AirMapFlightPlan> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapFlightPlan> in
			AirMap.logger.debug("Create Flight Plan", flightPlan)
			return self.perform(method: .post, path: "/plan", params: flightPlan.toJSON(), update: flightPlan, auth: credentials)
		}
	}
	
	func update(_ flightPlan: AirMapFlightPlan) -> Observable<AirMapFlightPlan> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapFlightPlan> in
			AirMap.logger.debug("Update Flight Plan", flightPlan)
			guard let flightPlanId = flightPlan.id else {
				return Observable.error(FlightPlanClientError.flightPlanDoesntExistCreateFirst)
			}
			return self.perform(method: .patch, path: "/plan/\(flightPlanId)", params: flightPlan.toJSON(), update: flightPlan, auth: credentials)
		}
	}
	
	func get(_ flightPlanId: AirMapFlightPlanId) -> Observable<AirMapFlightPlan> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapFlightPlan> in
			AirMap.logger.debug("Get Flight Plan", flightPlanId)
			return self.perform(method: .get, path: "/plan/\(flightPlanId)", auth: credentials)
		}
	}
		
	func getBriefing(_ flightPlanId: AirMapFlightPlanId) -> Observable<AirMapFlightBriefing> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapFlightBriefing> in
			AirMap.logger.debug("Get Flight Briefing", flightPlanId)
			return self.perform(method: .get, path: "/plan/\(flightPlanId)/briefing", auth: credentials)
		}
	}
	
	func getFlightPlanAuthorizationsByFlightPlanIds(_ ids: [AirMapFlightPlanId]) -> Observable<[AirMapFlightPlanAuthorizations]> {
		return withCredentials().flatMap({ (credentials) -> Observable<[AirMapFlightPlanAuthorizations]> in
			AirMap.logger.debug("Get Authorization for Flight Plan ids", ids)
			let params = [ "flight_plan_ids": ids.csv ]
			return self.perform(method: .get, path: "/plan/batch/authorizations", params: params, auth: credentials)
		})
	}
	
	func submitFlightPlan(_ flightPlan: AirMapFlightPlan, makeFlightPublic: Bool = true) -> Observable<AirMapFlightPlan> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapFlightPlan> in
			guard let flightPlanId = flightPlan.id else {
				return Observable.error(FlightPlanClientError.flightPlanDoesntExistCreateFirst)
			}
			AirMap.logger.debug("Submit Flight Plan", flightPlanId)
			let params = ["public": makeFlightPublic]
			return self.perform(method: .post, path: "/plan/\(flightPlanId)/submit", params: params, update: flightPlan, auth: credentials)
		}
	}
	
	func deleteFlightPlan(_ flightPlanId: AirMapFlightPlanId) -> Observable<Void> {
		return withCredentials().flatMap { (credentials) -> Observable<Void> in
			AirMap.logger.debug("Delete Flight Plan", flightPlanId)
			return self.perform(method: .delete, path: "/plan/\(flightPlanId)", auth: credentials)
		}
	}
}
