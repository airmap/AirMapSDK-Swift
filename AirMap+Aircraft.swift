//
//  AirMap+Aircraft.swift
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

extension AirMap {

	// MARK: - Aircraft

	/// List of all aircraft manufacturers
	///
	/// - Parameter completion: A completion handler to call with the Result
	public static func listManufacturers(_ completion: @escaping (Result<[AirMapAircraftManufacturer]>) -> Void) {
		rx.listManufacturers().thenSubscribe(completion)
	}

	/// Search all aircraft manufacturers by name
	///
	/// - Parameters:
	///   - name: The name of the manufacturer to filter the results with
	///   - completion: A completion handler to call with the Result
	public static func searchManufacturers(by name: String, _ completion: @escaping (Result<[AirMapAircraftManufacturer]>) -> Void) {
		rx.searchManufacturers(by: name).thenSubscribe(completion)
	}

	/// List all aircraft models by manufacturer
	///
	/// - Parameters:
	///   - manufacturerId: The identifier for the entity that manufactures the model
	///   - completion: A completion handler to call with the Result
	public static func listModels(by manufacturerId: AirMapAircraftManufacturerId, completion: @escaping (Result<[AirMapAircraftModel]>) -> Void) {
		rx.listModels(by: manufacturerId).thenSubscribe(completion)
	}

	/// Search all models by an aircraft's name
	///
	/// - Parameters:
	///   - name: The string to search models by
	///   - completion: A completion handler to call with the Result
	public static func searchModels(by name: String, completion: @escaping (Result<[AirMapAircraftModel]>) -> Void) {
		rx.searchModels(by: name).thenSubscribe(completion)
	}

	/// Get a specific aircraft model by identifier
	///
	/// - Parameters:
	///   - modelId: The unique identifier associated with the aircraft model
	/// - Parameter completion: A completion handler to call with the Result
	public static func getModel(by modelId: AirMapAircraftModelId, completion: @escaping (Result<AirMapAircraftModel>) -> Void) {
		rx.getModel(modelId).thenSubscribe(completion)
	}

}
