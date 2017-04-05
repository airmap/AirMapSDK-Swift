//
//  AirMapAdvisories.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

open class AirMapStatusAdvisory: NSObject {

	open fileprivate(set) var id: String!
	open fileprivate(set) var name: String = ""
	open fileprivate(set) var type: AirMapAirspaceType!
	open fileprivate(set) var city: String = ""
	open fileprivate(set) var state: String = ""
	open fileprivate(set) var country: String = ""
	open fileprivate(set) var lastUpdated: Date = Date()
	open fileprivate(set) var color = AirMapStatus.StatusColor.gray
	open fileprivate(set) var distance: Meters = 0
	open fileprivate(set) var latitude: Double = 0
	open fileprivate(set) var longitude: Double = 0
	open fileprivate(set) var requirements: AirMapStatusRequirements?
	open fileprivate(set) var airportProperties: AirMapStatusAdvisoryAirportProperties?
	open fileprivate(set) var parkProperties: AirMapStatusAdvisoryParkProperties?
	open fileprivate(set) var powerPlantProperties: AirMapStatusAdvisoryPowerPlantProperties?
	open fileprivate(set) var specialUseProperties: AirMapStatusAdvisorySpecialUseProperties?
	open fileprivate(set) var schoolProperties: AirMapStatusAdvisorySchoolProperties?
	open fileprivate(set) var tfrProperties: AirMapStatusAdvisoryTFRProperties?
	open fileprivate(set) var controlledAirspaceProperties: AirMapStatusAdvisoryControlledAirspaceProperties?
	open fileprivate(set) var wildfireProperties : AirMapStatusAdvisoryWildfireProperties?
	open fileprivate(set) var availablePermits = [AirMapAvailablePermit]()
	open internal(set) var organization: AirMapOrganization?
	
	internal fileprivate(set) var organizationId: String?

	public required init?(map: Map) {
		guard (try? map.value("type") as AirMapAirspaceType) != nil else {
			AirMap.logger.warning("Unexpected advisory type", map.JSON["type"] ?? "")
			return nil
		}
	}
	
	open override var hashValue: Int {
		return id.hashValue
	}
	
	open override func isEqual(_ object: Any?) -> Bool {
		if let object = object as? AirMapStatusAdvisory {
			return object.id == self.id
		} else {
			return false
		}
	}
}

public func ==(lhs: AirMapStatusAdvisory, rhs: AirMapStatusAdvisory) -> Bool {
	return lhs.id == rhs.id
}

extension AirMapStatusAdvisory: Mappable {

	public func mapping(map: Map) {

		let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)

		id               <-  map["id"]
		organizationId   <-  map["organization_id"]
		name             <-  map["name"]
		color            <-  map["color"]
		city             <-  map["city"]
		state            <-  map["state"]
		country          <-  map["country"]
		distance         <-  map["distance"]
		latitude         <-  map["latitude"]
		longitude        <-  map["longitude"]
		lastUpdated      <- (map["last_updated"], dateTransform)
		requirements     <-  map["requirements"]
		availablePermits <-  map["available_permits"]
		type             <-  map["type"]
		
		if let type = type {
			switch type {
			case .airport, .heliport: airportProperties            <- map["properties"]
			case .park:               parkProperties               <- map["properties"]
			case .specialUse:         specialUseProperties         <- map["properties"]
			case .powerPlant:         powerPlantProperties         <- map["properties"]
			case .school:             schoolProperties             <- map["properties"]
			case .controlledAirspace: controlledAirspaceProperties <- map["properties"]
			case .tfr:                tfrProperties                <- map["properties"]
			case .wildfire:           wildfireProperties           <- map["properties"]
			default:
				break
			}
		}
	}
}
