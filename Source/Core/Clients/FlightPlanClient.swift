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
		AirMap.logger.debug("Create Flight Plan", flightPlan)
		return perform(method: .post, path: "/plan", params: flightPlan.toJSON(), update: flightPlan, checkAuth: true)
	}
	
	func update(_ flightPlan: AirMapFlightPlan) -> Observable<AirMapFlightPlan> {
		AirMap.logger.debug("Update Flight Plan", flightPlan)
		guard let flightPlanId = flightPlan.id else {
			return Observable.error(FlightPlanClientError.flightPlanDoesntExistCreateFirst)
		}
		return perform(method: .patch, path: "/plan/\(flightPlanId)", params: flightPlan.toJSON(), update: flightPlan, checkAuth: true)
	}
	
	func get(_ flightPlanId: AirMapFlightPlanId) -> Observable<AirMapFlightPlan> {
		AirMap.logger.debug("Get Flight Plan", flightPlanId)
		return perform(method: .get, path: "/plan/\(flightPlanId)", checkAuth: true)
	}
		
	func getBriefing(_ flightPlanId: AirMapFlightPlanId) -> Observable<AirMapFlightBriefing> {
		AirMap.logger.debug("Get Flight Briefing", flightPlanId)
		return perform(method: .get, path: "/plan/\(flightPlanId)/briefing", checkAuth: true)
	}
	
	func submitFlightPlan(_ flightPlan: AirMapFlightPlan, makeFlightPublic: Bool = true) -> Observable<AirMapFlightPlan> {
		guard let flightPlanId = flightPlan.id else {
			return Observable.error(FlightPlanClientError.flightPlanDoesntExistCreateFirst)
		}
		AirMap.logger.debug("Submit Flight Plan", flightPlanId)
		let params = ["public": makeFlightPublic]
		return perform(method: .post, path: "/plan/\(flightPlanId)/submit", params: params, update: flightPlan, checkAuth: true)
	}
	
	func deleteFlightPlan(_ flightPlanId: AirMapFlightPlanId) -> Observable<Void> {
		AirMap.logger.debug("Delete Flight Plan", flightPlanId)
		return perform(method: .delete, path: "/plan/\(flightPlanId)", checkAuth: true)
	}

}
