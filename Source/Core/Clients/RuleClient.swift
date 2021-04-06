//
//  RuleClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/10/17.
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

internal class RuleClient: HTTPClient {
	
	init() {
		super.init(basePath: Constants.Api.rulesUrl)
	}
	
	enum RulesClientError: Error {
		case invalidPolygon
	}
	
	func getJurisdictions(intersecting geometry: AirMapGeometry) -> Observable<[AirMapJurisdiction]> {
		AirMap.logger.debug("Getting jurisdictions intersecting geometry")
		let params = ["geometry": geometry.params()]
		return withOptionalCredentials().flatMap { (credentials) -> Observable<[AirMapJurisdiction]> in
			return self.perform(method: .post, path: "/", params: params, auth: credentials).map { $0.jurisdictions }
		}
	}
	
	func getRuleset(by identifier: AirMapRulesetId) -> Observable<AirMapRuleset> {
		return withOptionalCredentials().flatMap { (credentials) -> Observable<AirMapRuleset> in
			return self.perform(method: .get, path: "/" + identifier.rawValue, auth: credentials)
		}
	}
	
	func getRulesets(intersecting geometry: AirMapGeometry) -> Observable<[AirMapRuleset]> {
		let params = ["geometry": geometry.params()]
		return withOptionalCredentials().flatMap { (credentials) -> Observable<[AirMapRuleset]> in
			return self.perform(method: .post, path: "/", params: params, auth: credentials)
		}
	}
	
	func getRulesetsEvaluated(by flightPlanId: AirMapFlightPlanId) -> Observable<[AirMapFlightBriefing.Ruleset]> {
		AirMap.logger.debug("Getting evaluated rulesets", metadata: ["flight_plan_id": .stringConvertible(flightPlanId)])
		return AirMap.flightPlanClient.getBriefing(flightPlanId).map { $0.rulesets }
	}
	
	func getRulesets(by rulesetIds: [AirMapRulesetId]) -> Observable<[AirMapRuleset]> {
		AirMap.logger.debug("Getting rules", metadata: ["rulesets": .stringConvertible(rulesetIds)])
		let params = ["rulesets": rulesetIds.map { $0.rawValue }.joined(separator: ",")]
		return withOptionalCredentials().flatMap { (credentials) -> Observable<[AirMapRuleset]> in
			return self.perform(method: .get, path: "/rule", params: params, auth: credentials)
		}
	}
	
	func getRulesetsEvaluated(from geometry: AirMapPolygon, rulesetIds: [AirMapRulesetId], flightFeatureValues: [String: Any]?, withMarkdown: Bool) -> Observable<[AirMapFlightBriefing.Ruleset]> {
		AirMap.logger.debug("Getting airspace evaluation", metadata: ["rulesets": .stringConvertible(rulesetIds)])
		let params: [String: Any] = [
			"rulesets": rulesetIds.csv,
			"geometry": geometry.params(),
			"flight_features": flightFeatureValues ?? [:],
			"with_markdown": withMarkdown
		]

		return withOptionalCredentials().flatMap { (credentials) -> Observable<[AirMapFlightBriefing.Ruleset]> in
			return self.perform(method: .post, path: "/evaluation", params: params, keyPath: "data.rulesets", auth: credentials)
		}
	}
	
}
