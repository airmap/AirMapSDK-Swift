//
//  AirMapAgreementStatus.swift
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

/// The status of the agreement
public final class AirMapAgreementStatus: ImmutableMappable {

	/// A bool indicating if the user has agreed to this agreement
	let hasAgreed: Bool

	public init(map: Map) throws {
		hasAgreed =  try map.value("has_agreed_to_latest_version")
	}
}
