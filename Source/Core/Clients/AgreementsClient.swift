//
//  AgreementsClient.swift
//  AirMapSDK
//
//  Created by Michael Odere on 10/12/20.
//  Copyright 2020 AirMap, Inc.
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

internal class AgreementsClient: HTTPClient {

	init() {
		super.init(basePath: Constants.Api.agreementsUrl)
	}

	// MARK: - Agreements

	func anonymousListAgreements(from authorityId: AirMapAuthorityId) -> Observable<[AirMapAgreement]> {
		return self.perform(method: .get, path: "/authority/\(authorityId.rawValue)")
	}

	func listAgreements(from authorityId: AirMapAuthorityId) -> Observable<[AirMapAgreement]> {
		return withCredentials().flatMap { (credentials) -> Observable<[AirMapAgreement]> in
			AirMap.logger.debug("List Agreements")
			return self.perform(method: .get, path: "/authority/\(authorityId.rawValue)", auth: credentials)
		}.flatMap { [unowned self] (agreements) -> Observable<[AirMapAgreement]> in
			return Observable.zip(agreements.map(self.getAgreement))
		}
	}

	func getAgreementDocument(with agreementId: AirMapAgreementId, withMarkdown: Bool) -> Observable<AirMapAgreementDocument> {
		let params = ["with_markdown": withMarkdown]
		return self.perform(method: .get, path: "/agreement/\(agreementId.rawValue)", params: params)
	}

	func getAgreementPDF(with agreementId: AirMapAgreementId) -> Observable<Data> {
		return withCredentials().flatMap { (credentials) -> Observable<Data> in
			AirMap.logger.debug("Get Agreement PDF", metadata: ["id": .stringConvertible(agreementId)])
			return self.perform(method: .get, path: "/agreement/\(agreementId.rawValue)/pdf", auth: credentials)
		}
	}

	func hasAgreedToAgreement(with agreementId: AirMapAgreementId) -> Observable<AirMapAgreementStatus> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapAgreementStatus> in
			AirMap.logger.debug("Has Agreed to Agreement", metadata: ["id": .stringConvertible(agreementId)])
			return self.perform(method: .get, path: "/agreement/\(agreementId.rawValue)/agreed", auth: credentials)
		}
	}

	func agreeToAgreement(with agreementId: AirMapAgreementId, date: Date = Date()) -> Observable<Void> {
		return withCredentials().flatMap { (credentials) -> Observable<Void> in
			AirMap.logger.debug("Agree to Agreement", metadata: ["id": .stringConvertible(agreementId), "agree_date": .stringConvertible(date.iso8601String())])
			let params = ["agree_date": date.iso8601String()]
			return self.perform(method: .post, path: "/agreement/\(agreementId.rawValue)/agree", params: params, auth: credentials)
		}
	}

	private func getAgreement(agreement: AirMapAgreement) -> Observable<AirMapAgreement> {
		return hasAgreedToAgreement(with: agreement.id)
			.map { (status) -> AirMapAgreement in
				agreement.hasAgreed = status.hasAgreed
				return agreement
			}
	}
}
