//
//  AirMap+Agreements.swift
//  AirMapSDK
//
//  Created by Michael Odere on 10/13/20.
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

import Foundation

extension AirMap {
	
	// MARK: - Agreements

	/// List all Agreements from an authority without being authorized
	///
	/// - Parameters:
	///  - authorityId: The id of the authority to get the agreements from
	/// - completion: A completion handler to call with the Result
	public static func anonymousListAgreements(from authorityId: AirMapAuthorityId, _ completion: @escaping (Result<[AirMapAgreement]>) -> Void) {
		rx.anonymousListAgreements(from: authorityId).thenSubscribe(completion)
	}

	/// List all Agreements from an authority
	///
	/// - Parameters:
	///  - authorityId: The id of the authority to get the agreements from
	/// - completion: A completion handler to call with the Result
	public static func listAgreements(from authorityId: AirMapAuthorityId, _ completion: @escaping (Result<[AirMapAgreement]>) -> Void) {
		rx.listAgreements(from: authorityId).thenSubscribe(completion)
	}

	/// Get the text document of the agreement
	///
	/// - Parameters:
	///   - agreementId: The id of the agreement to get
	///   - withMarkdown: Get markdown formatted agreement text 
	///   - completion: A completion handler to call with the Result
	public static func getAgreementDocument(with agreementId: AirMapAgreementId, withMarkdown: Bool = false, _ completion: @escaping (Result<AirMapAgreementDocument>) -> Void) {
		rx.getAgreementDocument(with: agreementId, withMarkdown: withMarkdown).thenSubscribe(completion)
	}

	/// Get the PDF of the agreement
	///
	/// - Parameters:
	///   - agreementId: The id of the agreement to get
	///   - completion: A completion handler to call with the Result
	public static func getAgreementPDF(with agreementId: AirMapAgreementId, _ completion: @escaping (Result<Data>) -> Void) {
		rx.getAgreementPDF(with: agreementId).thenSubscribe(completion)
	}

	/// Check if the current authorized pilot has agreed to an agreement
	///
	/// - Parameters:
	///   - agreementId: The id of the agreement to get
	///   - completion: A completion handler to call with the Result
	public static func hasAgreedToAgreement(with agreementId: AirMapAgreementId, _ completion: @escaping (Result<AirMapAgreementStatus>) -> Void) {
		rx.hasAgreedToAgreement(with: agreementId).thenSubscribe(completion)
	}

	/// Agree to an agreement
	///
	/// - Parameters:
	///   - agreementId: The id of the agreement to agree to
	///   - date: The date when the agreement was agreed to
	///   - completion: A completion handler to call with the Result
	public static func agreeToAgreement(with agreementId: AirMapAgreementId, date: Date = Date(), _ completion: @escaping (Result<Void>) -> Void) {
		rx.agreeToAgreement(with: agreementId, date: date).thenSubscribe(completion)
	}
}
