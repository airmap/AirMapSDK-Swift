//
//  AirMap+Flights.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

private typealias AirMap_Aircraft = AirMap
extension AirMap_Aircraft {

	public typealias AirMapAircraftModelResponseHandler = (AirMapAircraftModel?, NSError?) -> Void
	public typealias AirMapAircraftModelsCollectionResponseHandler = ([AirMapAircraftModel]?, NSError?) -> Void
	public typealias AirMapAircraftManufacturersCollectionResponseHandler = ([AirMapAircraftManufacturer]?, NSError?) -> Void

	/**
	Get a list of all `AirMapAircraftManufacturer`s

	- parameter handler: `([AirMapAircraftManufacturer]?, NSError?) -> Void`

	*/
	public class func listManufacturers(handler: AirMapAircraftManufacturersCollectionResponseHandler) {
		aircraftClient.listManufacturers().subscribe(handler)
	}

	/**
	Get a list of all `AirMapAircraftModel`'s

	- parameter handler: `([AirMapAircraftModel]?, NSError?) -> Void`

	*/
	public class func listModels(handler: AirMapAircraftModelsCollectionResponseHandler) {
		aircraftClient.listModels().subscribe(handler)
	}

	/**

	Get a `AirMapAircraftModel`

	- parameter modelId: `String`  The id of the model
	- parameter handler: `([AirMapAircraftModel]?, NSError?) -> Void`

	*/
	public class func getModel(modelId: String, handler: AirMapAircraftModelResponseHandler) {
		aircraftClient.getModel(modelId).subscribe(handler)
	}

}
