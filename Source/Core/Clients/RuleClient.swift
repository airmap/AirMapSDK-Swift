//
//  RuleClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/10/17.
/*
Copyright 2018 AirMap, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
//

import Foundation
import RxSwift

internal class RuleClient: HTTPClient {
	
	init() {
		super.init(basePath: Constants.AirMapApi.rulesUrl)
	}
	
	enum RulesClientError: Error {
		case invalidPolygon
	}
	
	func getJurisdictions(intersecting geometry: AirMapGeometry) -> Observable<[AirMapJurisdiction]> {
		AirMap.logger.debug("Getting jurisdictions intersecting geometry")
		let params = ["geometry": geometry.params()]
		return perform(method: .post, path: "/", params: params).map { $0.jurisdictions }
	}
	
	func getRuleset(by identifier: AirMapRulesetId) -> Observable<AirMapRuleset> {
		return perform(method: .get, path: "/" + identifier.rawValue)
	}
	
	func getRulesets(intersecting geometry: AirMapGeometry) -> Observable<[AirMapRuleset]> {
		let params = ["geometry": geometry.params()]
		return perform(method: .post, path: "/", params: params)
	}
	
	func getRulesetsEvaluated(by flightPlanId: AirMapFlightPlanId) -> Observable<[AirMapFlightBriefing.Ruleset]> {
		AirMap.logger.debug("Getting evaluated rulesets for flight_plan_id", flightPlanId)
		return AirMap.flightPlanClient.getBriefing(flightPlanId).map { $0.rulesets }
	}
	
	func getRulesets(by rulesetIds: [AirMapRulesetId]) -> Observable<[AirMapRuleset]> {
		AirMap.logger.debug("Getting rules for ruleset:", rulesetIds)
		let params = ["rulesets": rulesetIds.map { $0.rawValue }.joined(separator: ",")]
		return perform(method: .get, path: "/rule", params: params)
	}
	
	func getRulesetsEvaluated(from geometry: AirMapPolygon, rulesetIds: [AirMapRulesetId], flightFeatureValues: [String: Any]?) -> Observable<[AirMapFlightBriefing.Ruleset]> {
		AirMap.logger.debug("Getting airspace evaluation")
		let params: [String: Any] = [
			"rulesets": rulesetIds.csv,
			"geometry": geometry.params(),
			"flight_features": flightFeatureValues ?? [:]
		]
		return perform(method: .post, path: "/evaluation", params: params, keyPath: "data.rulesets")
	}
	
}
