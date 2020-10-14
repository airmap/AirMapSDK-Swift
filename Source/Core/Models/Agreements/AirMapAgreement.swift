//
//  AirMapAgreement.swift
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

import Foundation
import ObjectMapper

/// An agreement required by an Authority
final public class AirMapAgreement: ImmutableMappable {

	/// The Agreement Type
	public enum AirMapAgreementType: String {
		case termsAndConditions = "TERMS_AND_CONDITIONS"
	}

	/// The unique identifier for the agreement
	public let id: AirMapAgreementId

	/// The standard version of the agreement Ex: 1.0.0
	public let version: String

	/// The type of agreement
	public let type: AirMapAgreementType?

	/// A bool indicating if the user has agreed to this agreement
	public internal(set) var hasAgreed: Bool = false

	public init(map: Map) throws {
		id        =  try  map.value("id")
		version   =  try  map.value("version")
		type      =  try? map.value("type")
	}
}
