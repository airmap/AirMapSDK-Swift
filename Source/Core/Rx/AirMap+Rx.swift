//
//  AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/10/16.
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

// Reactive extension for AirMap methods.
extension AirMap: ReactiveCompatible {}

extension Reactive where Base: AirMap {
	
	public static var networkActivity: ActivityTracker {
		return HTTPClient.activity
	}
}

/// Documentation found in AirMap+Flights.swift
extension Reactive where Base: AirMap {
	
	public static func listPublicFlights(from fromDate: Date? = nil, to toDate: Date? = nil, limit: Int? = nil, within geometry: AirMapGeometry? = nil) -> Observable<[AirMapFlight]> {
		return AirMap.flightClient.listPublicFlights(from: fromDate, to: toDate, limit: limit, within: geometry)
	}

	public static func listFlights(for pilotId: AirMapPilotId, from: Date? = nil, to: Date? = nil, limit: Int? = 100) -> Observable<[AirMapFlight]> {
		return AirMap.flightClient.list(limit: limit, pilotId: pilotId, startBefore: to, endAfter: from)
	}
	
	public static func getCurrentAuthenticatedPilotFlight() -> Observable<AirMapFlight?> {
		return AirMap.flightClient.getCurrentAuthenticatedPilotFlight()
	}

	public static func getFlight(by id: AirMapFlightId) -> Observable<AirMapFlight> {
		return AirMap.flightClient.get(id)
	}

	public static func createFlight(_ flight: AirMapFlight) -> Observable<AirMapFlight> {
		return AirMap.flightClient.create(flight)
	}

	public static func endFlight(_ flight: AirMapFlight) -> Observable<AirMapFlight> {
		return AirMap.flightClient.end(flight)
	}
	
	public static func endFlight(by id: AirMapFlightId) -> Observable<Void> {
		return AirMap.flightClient.end(id)
	}

	public static func deleteFlight(_ flight: AirMapFlight) -> Observable<Void> {
		return AirMap.flightClient.delete(flight)
	}
	
	public static func getFlightPlanByFlightId(_ id: AirMapFlightId) -> Observable<AirMapFlightPlan> {
		return AirMap.flightClient.getFlightPlanByFlightId(id)
	}
}

/// Documentation found in AirMap+Flights.swift
extension Reactive where Base: AirMap {
	
	public static func createFlightPlan(_ flightPlan: AirMapFlightPlan) -> Observable<AirMapFlightPlan> {
		return AirMap.flightPlanClient.create(flightPlan)
	}

	public static func updateFlightPlan(_ flightPlan: AirMapFlightPlan) -> Observable<AirMapFlightPlan> {
		return AirMap.flightPlanClient.update(flightPlan)
	}
	
	public static func getFlightPlan(_ flightPlanId: AirMapFlightPlanId) -> Observable<AirMapFlightPlan> {
		return AirMap.flightPlanClient.get(flightPlanId)
	}
	
	public static func getFlightBriefing(_ flightPlanId: AirMapFlightPlanId) -> Observable<AirMapFlightBriefing> {
		return AirMap.flightPlanClient.getBriefing(flightPlanId)
	}
	
	public static func submitFlightPlan(_ flightPlan: AirMapFlightPlan, makeFlightPublic: Bool = true) -> Observable<AirMapFlightPlan> {
		return AirMap.flightPlanClient.submitFlightPlan(flightPlan, makeFlightPublic: makeFlightPublic)
	}

	public static func deleteFlightPlan(_ flightPlanId: AirMapFlightPlanId) -> Observable<Void> {
		return AirMap.flightPlanClient.deleteFlightPlan(flightPlanId)
	}
}

/// Documentation found in AirMap+Aircraft.swift
extension Reactive where Base: AirMap {

	public static func listAircraft() -> Observable<[AirMapAircraft]> {
		return AirMap.pilotClient.listAircraft()
	}

	public static func createAircraft(_ aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		return AirMap.pilotClient.createAircraft(aircraft)
	}

	public static func updateAircraft(_ aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		return AirMap.pilotClient.updateAircraft(aircraft)
	}

	public static func deleteAircraft(_ aircraft: AirMapAircraft) -> Observable<Void> {
		return AirMap.pilotClient.deleteAircraft(aircraft)
	}

	public static func listManufacturers() -> Observable<[AirMapAircraftManufacturer]> {
		return AirMap.aircraftClient.listManufacturers()
	}
	
	public static func searchManufacturers(by name: String) -> Observable<[AirMapAircraftManufacturer]> {
		return AirMap.aircraftClient.searchManufacturers(by: name)
	}
	
	public static func listModels(by manufacturerId: AirMapAircraftManufacturerId) -> Observable<[AirMapAircraftModel]> {
		return AirMap.aircraftClient.listModels(by: manufacturerId)
	}
	
	public static func searchModels(by name: String) -> Observable<[AirMapAircraftModel]> {
		return AirMap.aircraftClient.searchModels(by: name)
	}
	
	public static func getModel(_ modelId: AirMapAircraftModelId) -> Observable<AirMapAircraftModel> {
		return AirMap.aircraftClient.getModel(modelId)
	}
}

/// Documentation found in AirMap+Pilot.swift
extension Reactive where Base: AirMap {

	public static func getPilot(by id: AirMapPilotId) -> Observable<AirMapPilot> {
		return AirMap.pilotClient.get(id)
	}

	public static func getAuthenticatedPilot() -> Observable<AirMapPilot> {
		return AirMap.pilotClient.getAuthenticatedPilot()
	}

	public static func updatePilot(_ pilot: AirMapPilot) -> Observable<AirMapPilot> {
		return AirMap.pilotClient.update(pilot)
	}

	public static func sendSMSVerificationToken() -> Observable<Void> {
		return AirMap.pilotClient.sendVerificationToken()
	}

	public static func verifySMS(_ token: String) -> Observable<AirMapPilotVerified> {
		return AirMap.pilotClient.verifySMS(token: token)
	}
}

/// Documentation found in AirMap+Auth.swift
extension Reactive where Base: AirMap {
    
    public static func performAnonymousLogin(userId: String) -> Observable<Void> {
		return AirMap.authService.loginAnonymously(withForeign: userId)
    }	

	public static func logout() -> Observable<Void> {
		return AirMap.authService.logout()
	}

 	public static func login(from viewController: UIViewController) -> Observable<AirMapPilot> {
		return AirMap.authService.login(from: viewController)
			.flatMap(AirMap.rx.getAuthenticatedPilot)
    }
}

/// Documentation found in AirMap+Rules.swift
extension Reactive where Base: AirMap {
	
	public static func getJurisdictions(intersecting geometry: AirMapGeometry) -> Observable<[AirMapJurisdiction]> {
		return AirMap.ruleClient.getJurisdictions(intersecting: geometry)
	}

	public static func getRulesets(by rulesetIds: [AirMapRulesetId]) -> Observable<[AirMapRuleset]> {
		return AirMap.ruleClient.getRulesets(by: rulesetIds)
	}
	
	public static func getRuleset(by identifier: AirMapRulesetId) -> Observable<AirMapRuleset> {
		return AirMap.ruleClient.getRuleset(by: identifier)
	}
	
	public static func getRulesetsEvaluated(by flightPlanId: AirMapFlightPlanId) -> Observable<[AirMapFlightBriefing.Ruleset]> {
		return AirMap.ruleClient.getRulesetsEvaluated(by: flightPlanId)
	}

	public static func getRulesetsEvaluated(from geometry: AirMapPolygon, rulesetIds: [AirMapRulesetId], flightFeatureValues: [String: Any]?) -> Observable<[AirMapFlightBriefing.Ruleset]> {
		return AirMap.ruleClient.getRulesetsEvaluated(from: geometry, rulesetIds: rulesetIds, flightFeatureValues: flightFeatureValues)
	}

	public static func getRulesets(intersecting geometry: AirMapGeometry) -> Observable<[AirMapRuleset]> {
		return AirMap.ruleClient.getRulesets(intersecting: geometry)
	}
}

/// Documentation found in AirMap+Advisories.swift
extension Reactive where Base: AirMap {
	
	public static func getAirspaceStatus(at point: Coordinate2D, buffer: Meters, rulesetIds: [AirMapRulesetId], from start: Date? = nil, to end: Date? = nil) -> Observable<AirMapAirspaceStatus> {
		return AirMap.advisoryClient.getAirspaceStatus(at: point, buffer: buffer, rulesetIds: rulesetIds, from: start, to: end)
	}
	
	public static func getAirspaceStatus(along path: AirMapPath, buffer: Meters, rulesetIds: [AirMapRulesetId], from start: Date? = nil, to end: Date? = nil) -> Observable<AirMapAirspaceStatus> {
		return AirMap.advisoryClient.getAirspaceStatus(along: path, buffer: buffer, rulesetIds: rulesetIds, from: start, to: end)
	}
	
	public static func getAirspaceStatus(within polygon: AirMapGeometry, rulesetIds: [AirMapRulesetId], from start: Date? = nil, to end: Date? = nil) -> Observable<AirMapAirspaceStatus> {
		return AirMap.advisoryClient.getAirspaceStatus(within: polygon, under: rulesetIds, from: start, to: end)
	}
	
	public static func getWeatherForecast(at coordinate: Coordinate2D, from: Date? = nil, to: Date? = nil) -> Observable<AirMapWeather> {
		return AirMap.advisoryClient.getWeatherForecast(at: coordinate, from: from, to: to)
	}
}

extension Reactive where Base: AirMap {

	static func getAirspace(_ airspaceId: AirMapAirspaceId) -> Observable<AirMapAirspace> {
		return AirMap.airspaceClient.getAirspace(airspaceId)
	}
	
	static func listAirspace(_ airspaceIds: [AirMapAirspaceId]) -> Observable<[AirMapAirspace]> {
		return AirMap.airspaceClient.listAirspace(airspaceIds)
	}
}
