//
//  AirMap+JSONSerialization.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/1/17.
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
import ObjectMapper

// INTERNAL: Extends objects for Mappable/ImmutableMappable Protocol Conformance

// MARK: - AirMapAirspaceStatus

extension AirMapAirspaceStatus: ImmutableMappable {
	
	public init(map: Map) throws {
		
		do {
			color       =  try map.value("color")
			advisories  =  try map.value("advisories")
		}
		catch {
			AirMap.logger.error("Failed to parse AirMapAirspaceStatus", metadata: ["error": .string(error.localizedDescription)])
			throw error
		}
	}
}

// MARK: - AirMapAdvisory

extension AirMapAdvisory: ImmutableMappable {
	
	public init(map: Map) throws {
		
		let dateTransform = CustomDateFormatTransform(formatString: Constants.Api.dateFormat)
		
		do {
			id            =  try  map.value("id")
			color         =  try  map.value("color")
			lastUpdated   = (try? map.value("last_updated", using: dateTransform)) ?? Date()
			city          =  try? map.value("city")
			state         =  try? map.value("state")
			country       =  try  map.value("country")
			ruleId        =  try  map.value("rule_id")
			rulesetId     =  try  map.value("ruleset_id")
			requirements  =  try? map.value("requirements")
			timesheets    =  try? map.value("schedule")

			let latitude  = try map.value("latitude") as Double
			let longitude = try map.value("longitude") as Double
			coordinate = Coordinate2D(latitude: latitude, longitude: longitude)
			
			let airspaceType: AirMapAirspaceType = (try? map.value("type")) ?? .unclassified
			type = airspaceType
			name = (try? map.value("name") as String) ?? airspaceType.title

			if let props: [String: Any] = try? map.value("properties") {
				switch airspaceType {
				case .airport:
					properties = try? AirportProperties(JSON: props)
				case .amaField:
					properties = try? AMAFieldProperties(JSON: props)
				case .controlledAirspace:
					properties = try? ControlledAirspaceProperties(JSON: props)
				case .city:
					properties = try? CityProperties(JSON: props)
				case .custom:
					properties = try? CustomProperties(JSON: props)
				case .emergency:
					properties = try? EmergencyProperties(JSON: props)
				case .heliport:
					properties = try? HeliportProperties(JSON: props)
				case .notam:
					properties = try? NOTAMProperties(JSON: props)
				case .notification:
					properties = try? NotificationProperties(JSON: props)
				case .park:
					properties = try? ParkProperties(JSON: props)
				case .powerPlant:
					properties = try? PowerPlantProperties(JSON: props)
				case .school:
					properties = try? SchoolProperties(JSON: props)
				case .specialUse:
					properties = try? SpecialUseProperties(JSON: props)
				case .tfr:
					properties = try? TFRProperties(JSON: props)
				case .university:
					properties = try? UniversityProperties(JSON: props)
				case .wildfire:
					properties = try? WildfireProperties(JSON: props)
				default:
					properties = nil
				}
			} else {
				properties = nil
			}
		}
			
		catch {
			AirMap.logger.error("Failed to parse AirMapAdvisory", metadata: ["error": .string(error.localizedDescription)])
			throw error
		}
	}
}

extension AirMapAdvisory.Timesheet: ImmutableMappable {
	public init(map: Map) throws {
		active         =  try? map.value("active")
		timesheetData  =  try? map.value("data")
	}
}

extension AirMapAdvisory.Timesheet.Data: ImmutableMappable {
	public init(map: Map) throws {
		offsetUTC             =  try? map.value("utc_offset")
		excluded              =  try? map.value("excluded")
		daylightSavingAdjust  =  try? map.value("daylight_saving_adjust")
		day                   =  try? map.value("day")
		dayTil                =  try? map.value("day_til")
		start                 =  try? map.value("start")
		end                   =  try? map.value("end")
	}
}

extension AirMapAdvisory.Timesheet.DayDescriptor: ImmutableMappable {
	public init(map: Map) throws {
		name  =  try map.value("name")
		day   =  try map.value("id")
	}
}

extension AirMapAdvisory.Timesheet.EventDescriptor: ImmutableMappable {
	public init(map: Map) throws {
		name  =  try map.value("name")
		event =  try map.value("id")
	}
}

extension AirMapAdvisory.Timesheet.DataMarker: ImmutableMappable {
	public init(map: Map) throws {
		event                 =  try? map.value("event")
		eventInterpretation   =  try? map.value("event_interpretation")
		eventOffset           =  try? map.value("event_offset")
		time                  =  try? map.value("time")
		date                  =  try? map.value("date")
	}
}

extension AirMapAdvisory.Timesheet.Time: ImmutableMappable {
	public init(map: Map) throws {
		hour     =  try map.value("hour")
		minute   =  try map.value("minute")
	}
}

extension AirMapAdvisory.Timesheet.Date: ImmutableMappable {
	public init(map: Map) throws {
		month =  try map.value("month")
		day   =  try map.value("day")
	}
}

// MARK: - AirMapAdvisoryRequirements

extension AirMapAdvisoryRequirements: ImmutableMappable {
	
	public init(map: Map) throws {
		notice  =  try? map.value("notice")
	}
}

extension AirMapAdvisoryRequirements.Notice: ImmutableMappable {
	
	public init(map: Map) throws {
		digital      = (try? map.value("digital")) ?? false
		phoneNumber  =  try? map.value("phone")
	}
}

// MARK: - AdvisoryPropertiesType

public protocol AdvisoryPropertiesType: ImmutableMappable {}

extension AirMapAdvisory.AirportProperties: ImmutableMappable {
	
	public init(map: Map) throws {
		identifier    =  try? map.value("faa")
		phone         =  try? map.value("phone")
		tower         =  try? map.value("tower")
		use           =  try? map.value("type")
		longestRunway =  try? map.value("longest_runway")
		instrumentProcedure
		              =  try? map.value("instrument_approach_procedure")
		url           =  try? map.value("url", using: URLTransform())
		description   =  try? map.value("description")
		icao          =  try? map.value("icao")
	}
}
	
extension AirMapAdvisory.AMAFieldProperties: ImmutableMappable {
	
	public init(map: Map) throws {
		// TODO: Remove once AMA Field data contains proper http URLs
		if let urlString: String = try? map.value("url"), var urlComponents = URLComponents(string: urlString) {
			if urlComponents.scheme == nil {
				urlComponents.scheme = "http"
			}
			url = try? urlComponents.asURL()
		} else {
			url = nil
		}

		phone         =  try? map.value("phone")
		siteLocation  =  try? map.value("site_location")
		contactName   =  try? map.value("contact_name")
		contactPhone  =  try? map.value("contact_phone")
		contactEmail  =  try? map.value("contact_email")
	}
}

extension AirMapAdvisory.CityProperties: ImmutableMappable {
	
	public init(map: Map) throws {
		url           =  try? map.value("url", using: URLTransform())
		description   =  try? map.value("description")
		phone         =  try? map.value("phone")
	}
}

extension AirMapAdvisory.ControlledAirspaceProperties: ImmutableMappable {
	
	public init(map: Map) throws {
		type                   =  try  map.value("type")
		isLaancProvider        =  try? map.value("laanc")
		supportsAuthorization  =  try? map.value("authorization")
		url                    =  try? map.value("url", using: URLTransform())
		icao                   =  try? map.value("icao")
 		airportID              =  try? map.value("airport_id")
 		airportName            =  try? map.value("airport_name")
 		ceiling                =  try? map.value("ceiling")
 		floor                  =  try? map.value("floor")
		phone                  =  try? map.value("phone")
	}
}

extension AirMapAdvisory.CustomProperties: ImmutableMappable {
	
	public init(map: Map) throws {
		url           =  try? map.value("url", using: URLTransform())
		description   =  try? map.value("description")
		phone         =  try? map.value("phone")
	}
}

extension AirMapAdvisory.EmergencyProperties: ImmutableMappable {
	
	public init(map: Map) throws {
		effective   =  try? map.value("date_effective", using: Constants.Api.dateTransform)
		type        =  try? map.value("type")
		url         =  try? map.value("url", using: URLTransform())
		phone       =  try? map.value("phone")
	}
}

extension AirMapAdvisory.FireProperties: ImmutableMappable {
	
	public init(map: Map) throws {
		effective  =  try? map.value("date_effective", using: Constants.Api.dateTransform)
		url        =  try? map.value("url", using: URLTransform())
		phone      =  try? map.value("phone")
	}
}

extension AirMapAdvisory.HeliportProperties: ImmutableMappable {
	
	public init(map: Map) throws {
		identifier    =  try? map.value("faa")
		paved         =  try? map.value("paved")
		phone         =  try? map.value("phone")
		tower         =  try? map.value("tower")
		use           =  try? map.value("use")
		instrumentProcedure
			=  try? map.value("instrument_approach_procedure")
		icao          =  try? map.value("icao")
		url           =  try? map.value("url", using: URLTransform())
	}
}

extension AirMapAdvisory.ParkProperties: ImmutableMappable {
	
	public init(map: Map) throws {
		type  =  try? map.value("type")
		url   =  try? map.value("url", using: URLTransform())
		phone =  try? map.value("phone")
	}
}

extension AirMapAdvisory.PowerPlantProperties: ImmutableMappable {
	
	public init(map: Map) throws {
		technology      =  try? map.value("tech")
		generatorType   =  try? map.value("generator_type")
		output          =  try? map.value("output")
		url             =  try? map.value("url", using: URLTransform())
		phone           =  try? map.value("phone")
	}
}

extension AirMapAdvisory.SchoolProperties: ImmutableMappable {
	
	public init(map: Map) throws {
		numberOfStudents  =  try? map.value("students")
		url               =  try? map.value("url", using: URLTransform())
		phone             =  try? map.value("phone")
	}
}

extension AirMapAdvisory.SpecialUseProperties: ImmutableMappable {
	
	public init(map: Map) throws {
		description =  try? map.value("description")
		url         =  try? map.value("url", using: URLTransform())
		phone       =  try? map.value("phone")
	}
}

extension AirMapAdvisory.NOTAMProperties: ImmutableMappable {
	
	public init(map: Map) throws {
		body       =  try? map.value("body")
		startTime  =  try? map.value("effective_start", using: Constants.Api.dateTransform)
		endTime    =  try? map.value("effective_end", using: Constants.Api.dateTransform)
		type       =  try? map.value("type")
		url        =  try? map.value("url", using: URLTransform())
		phone      =  try? map.value("phone")
	}
}

extension AirMapAdvisory.NotificationProperties: ImmutableMappable {

	public init(map: Map) throws {
		body    =  try? map.value("body")
		url     =  try? map.value("url", using: URLTransform())
		phone   =  try? map.value("phone")
	}
}

extension AirMapAdvisory.TFRProperties: ImmutableMappable {
	
	public init(map: Map) throws {
		url        =  try? map.value("url", using: URLTransform())
		body       =  try? map.value("body")
		startTime  =  try? map.value("effective_start", using: Constants.Api.dateTransform)
		endTime    =  try? map.value("effective_end", using: Constants.Api.dateTransform)
		type       =  try? map.value("type")
		sport      =  try? map.value("sport")
		venue      =  try? map.value("venue")
		phone      =  try? map.value("phone")
	}
}

extension AirMapAdvisory.WildfireProperties: ImmutableMappable {
	
	public init(map: Map) throws {
		effective   =  try? map.value("date_effective", using: Constants.Api.dateTransform)
		size        =  try? map.value("size")
		url         =  try? map.value("url", using: URLTransform())
		phone       =  try? map.value("phone")
	}
}

extension AirMapAdvisory.UniversityProperties: ImmutableMappable {
	
	public init(map: Map) throws {
		url           =  try? map.value("url", using: URLTransform())
		description   =  try? map.value("description")
		phone         =  try? map.value("phone")
	}
}

// MARK: - Aircraft

extension AirMapAircraft {
	
	public func mapping(map: Map) {
		model.id   >>>  (map["model_id"], AirMapIdTransform())
		nickname   >>>   map["nickname"]
	}
}

// MARK: - AirMapAircraftManufacturer

extension AirMapAircraftManufacturer: ImmutableMappable {
	
	public init(map: Map) throws {
		id   = try map.value("id")
		name = try map.value("name")
	}
	
	public func mapping(map: Map) {
		id  >>>  (map["id"], AirMapIdTransform())
	}
}

// MARK: - AirMapAircraftModel

extension AirMapAircraftModel: ImmutableMappable {
	
	public init(map: Map) throws {
		id           = try  map.value("id")
		name         = try  map.value("name")
		manufacturer = try  map.value("manufacturer")
		metadata     = try? map.value("metadata")
	}
	
	public func mapping(map: Map) {
		id  >>>  (map["id"], AirMapIdTransform())
	}
}

// MARK: - AirMapAirspace

extension AirMapAirspace: ImmutableMappable {
	
	init(map: Map) throws {
		id        =  try  map.value("id")
		name      =  try  map.value("name")
		type      =  try  map.value("type")
		country   =  try  map.value("country")
		state     =  try? map.value("state")
		city      =  try? map.value("city")
		geometry  =  try  map.value("geometry", using: GeoJSONToAirMapGeometryTransform())
		propertyBoundary
			=  try? map.value("related_geometry.property_boundary.geometry", using: GeoJSONToAirMapGeometryTransform())
	}
}

// MARK: - AirMapRuleset

extension AirMapRuleset: ImmutableMappable {
	
	/// The mapping context from where the JSON originated
	///
	/// - tileService: data from tile service metadata
	/// - airMapApi: data from the ruleset API
	public enum Origin: MapContext {
		case tileService
		case airMapApi
	}
	
	public init(map: Map) throws {
		
		do {
			id        =  try  map.value("id")
			name      = (try? map.value("name")) ?? "?" //TODO: FIXME
			shortName = (try? map.value("short_name")) ?? "?"
			type      =  try  map.value("selection_type")
			isDefault =  try  map.value("default")
			
			switch (map.context as? Origin) ?? .airMapApi {
				
			case .airMapApi:
				rules           = try map.value("rules")
				description     = try map.value("description")
				airspaceTypes   = try map.value("airspace_types", using: AirMapAirspaceTypeTransform())
				
			case .tileService:
				rules           =  []
				description     = (try? map.value("short_description")) ?? ""
				airspaceTypes   =  try  map.value("layers", using: AirMapAirspaceTypeTransform())
			}
			
			jurisdictionId     = try? map.value("jurisdiction.id")
			jurisdictionName   = try? map.value("jurisdiction.name")
			jurisdictionRegion = try? map.value("jurisdiction.region")
		}
		catch {
			AirMap.logger.error("Failed to parse AirMapRuleset", metadata: ["error": .string(error.localizedDescription)])
			throw error
		}
	}
}

// MARK: - AirMapAirspaceType

/// Custom transform that converts between [String] and [AirMapAirspaceType]
fileprivate class AirMapAirspaceTypeTransform: TransformType {

	public typealias Object = [AirMapAirspaceType]
	public typealias JSON = [String]
	
	init() {}
	
	func transformFromJSON(_ value: Any?) -> [AirMapAirspaceType]? {
		if let rawArray = value as? [String] {
			var airspaceTypes = [AirMapAirspaceType]()
			for rawValue in rawArray {
				if let airspaceType = AirMapAirspaceType(rawValue: rawValue) {
					airspaceTypes.append(airspaceType)
				} else {
					AirMap.logger.debug("Failed to parse AirMapAirspaceType", metadata: ["type": .string(rawValue)])
				}
			}
			return airspaceTypes
		}
		return nil
	}
	
	func transformToJSON(_ value: [AirMapAirspaceType]?) -> [String]? {
		if let obj = value {
			return obj.map { $0.rawValue }
		}
		return nil
	}
}

// MARK: - AirMapFlight

extension AirMapFlight: Mappable {
	
	public func mapping(map: Map) {
		
		var lat: Double?
		var lng: Double?
		
		lat <- map["latitude"]
		lng <- map["longitude"]
		
		if let lat = lat, let lng = lng {
			coordinate.latitude = lat
			coordinate.longitude = lng
		}
		
		let dateTransform = CustomDateFormatTransform(formatString: Constants.Api.dateFormat)
		
		id          	<- (map["id"], AirMapIdTransform())
		flightPlanId	<- (map["flight_plan_id"], AirMapIdTransform())
		createdAt   	<- (map["creation_date"], dateTransform)
		startTime   	<- (map["start_time"], dateTransform)
		maxAltitude 	<-  map["max_altitude"]
		city        	<-  map["city"]
		state       	<-  map["state"]
		country     	<-  map["country"]
		notify      	<-  map["notify"]
// FIXME: Map pilot
//		pilot       <-  map["pilot"]
		pilotId     	<- (map["pilot_id"], AirMapIdTransform())
		aircraft    	<-  map["aircraft"]
		aircraftId  	<- (map["aircraft_id"], AirMapIdTransform())
		isPublic    	<-  map["public"]
		buffer      	<-  map["buffer"]
		geometry    	<- (map["geometry"], GeoJSONToAirMapGeometryTransform())
		
		var endTime: Date?
		endTime     <- (map["end_time"], dateTransform)
		
		if let startTime = startTime, let endTime = endTime {
			duration = endTime.timeIntervalSince(startTime)
		}
	}
	
	// TODO: Remove and replace with .toJSON()
	
	func params() -> [String: Any] {
		
		var params = [String: Any]()
		
		params["latitude"    ] = coordinate.latitude
		params["longitude"   ] = coordinate.longitude
		params["max_altitude"] = maxAltitude
		params["aircraft_id" ] = aircraftId
		params["public"      ] = isPublic
		params["notify"      ] = notify
		params["geometry"    ] = geometry?.params()
		params["buffer"      ] = buffer ?? 0
		
		if let startTime = startTime, let endTime = endTime {
			params["start_time"] = startTime.iso8601String()
			params["end_time"  ] = endTime.iso8601String()
		} else {
			let now = Date()
			params["start_time"] = now.iso8601String()
			params["end_time"  ] = now.addingTimeInterval(duration).iso8601String()
		}
		
		return params
	}
}

// MARK: - AirMapFlightBriefing

extension AirMapFlightBriefing: ImmutableMappable {
	
	public init(map: Map) throws {
		
		guard map.JSON["rulesets"] != nil else {
			throw AirMapError.server
		}
		
		let dateTransform = CustomDateFormatTransform(formatString: Constants.Api.dateFormat)
		do {
			createdAt      =  try  map.value("created_at", using: dateTransform)
			rulesets       =  try  map.value("rulesets")
			flightFeatures = (try? map.value("flight_features")) ?? []
			status         =  try  map.value("airspace")
			authorizations = (try? map.value("authorizations")) ?? []
		}
		catch {
			AirMap.logger.error("Failed to parse AirMapFlightBriefing", metadata: ["error": .string(error.localizedDescription)])
			throw error
		}
	}
}

extension AirMapFlightBriefing.Ruleset: ImmutableMappable {
	
	public init(map: Map) throws {
		id    = try map.value("id")
		rules = try map.value("rules")
	}
}

extension AirMapAuthority: ImmutableMappable {
	
	public init(map: Map) throws {
		do {
			id       = try map.value("id")
			name     = try map.value("name")
			facility = try map.value("facility")
		}
		catch {
			AirMap.logger.error("Failed to parse AirMapAuthority", metadata: ["error": .string(error.localizedDescription)])
			throw error
		}
	}
	
	public func mapping(map: Map) {
		id    >>> (map["id"], AirMapIdTransform())
		name  >>>  map["name"]
	}
}

extension AirMapFlightBriefing.Authorization: ImmutableMappable {
	
	public init(map: Map) throws {
		do {
			authority        =  try  map.value("authority")
			status           = (try? map.value("status")) ?? .rejected
			message          =  try  map.value("message")
			airspaceCategory =  try? map.value("airspace_category")
			geometry         =  try?  map.value("geometry", using: GeoJSONToAirMapGeometryTransform())
			notices          = (try? map.value("notices")) ?? []
			referenceNumber  =  try? map.value("reference_number")
			description      =  try  map.value("description")
		}
		catch {
			AirMap.logger.error("Failed to parse AirMapFlightBriefing.Authorization", metadata: ["error": .string(error.localizedDescription)])
			throw error
		}
	}
	
	public func mapping(map: Map) {
		authority    >>> map["authority"]
		status       >>> map["status"]
		message      >>> map["message"]
		notices      >>> map["notices"]
		description  >>> map["description"]
	}
}

extension AirMapFlightBriefing.Notice: ImmutableMappable {

	public init(map: Map) throws {
		do {
			message = try map.value("message")
		}
		catch {
			AirMap.logger.error("Failed to parse AirMapFlightBriefing.Notice", metadata: ["error": .string(error.localizedDescription)])
			throw error
		}
	}

	public func mapping(map: Map) {
		message >>> map["message"]
	}
}

extension AirMapJurisdiction: ImmutableMappable {
	
	public init(map: Map) throws {
		
		do {
			id     = try map.value("id")
			name   = try map.value("name")
			region = try map.value("region")
			
			guard let rulesetJSON = map.JSON["rulesets"] as? [[String: Any]] else {
				throw AirMapError.serialization(.invalidJson)
			}
			
			// Patch the JSON with information about the jurisdiction :/
			var updatedJSON = [[String: Any]]()
			for var json in rulesetJSON {
				json["jurisdiction"] = ["id": id.rawValue, "name": name, "region": region.rawValue]
				updatedJSON.append(json)
			}
			
			let mapper = Mapper<AirMapRuleset>(context: AirMapRuleset.Origin.tileService)
			rulesets = try mapper.mapArray(JSONArray: updatedJSON)
		}
		catch {
			AirMap.logger.error("Failed to parse AirMapJurisdiction", metadata: ["error": .string(error.localizedDescription)])
			throw error
		}
	}
	
	static let tileServiceMapper = Mapper<AirMapJurisdiction>(context: AirMapRuleset.Origin.tileService)

}

// MARK: - AirMapFlightFeature

extension AirMapFlightFeature: ImmutableMappable {
	
	public init(map: Map) throws {
		do {
			id              =  try  map.value("flight_feature")
			description     =  try  map.value("description")
			inputType       =  try? map.value("input_type")
			measurementType = (try? map.value("measurement_type")) ?? .binary
			measurementUnit =  try? map.value("measurement_unit")
			status          = (try? map.value("status")) ?? .unevaluated
			isCalculated    = (try? map.value("is_calculated")) ?? false
		}
		catch {
			AirMap.logger.error("Failed to parse AirMapFlightFeature", metadata: ["error": .string(error.localizedDescription)])
			throw error
		}
	}
}

// MARK: - AirMapRule

import ObjectMapper

extension AirMapRule: ImmutableMappable {
	
	public init(map: Map) throws {
		shortText      =  try  map.value("short_text")
		description    =  try? map.value("description")
		flightFeatures = (try? map.value("flight_features")) ?? []
		status         = (try? map.value("status")) ?? .unevaluated
		displayOrder   = (try? map.value("display_order")) ?? Int.max
	}
}

// MARK: - AirMapToken

extension AirMapToken: ImmutableMappable {
	
	public init(map: Map) throws {
		idToken = try map.value("id_token")
	}
}

// MARK: - AirMapWeather

extension AirMapWeather: ImmutableMappable {
	
	public init(map: Map) throws {
		do {
			attribution     = try map.value("attribution")
			attributionUrl  = try map.value("attribution_uri", using: URLTransform())
			observations    = try map.value("weather")
		}
		catch {
			AirMap.logger.error("Failed to parse AirMapWeather", metadata: ["error": .string(error.localizedDescription)])
			throw error
		}
	}
}

extension AirMapWeather.Observation: ImmutableMappable {
	
	private static let dateTransform = CustomDateFormatTransform(formatString: Constants.Api.dateFormat)
	
	public init(map: Map) throws {
		do {
			time          =  try  map.value("time", using: AirMapWeather.Observation.dateTransform)
			condition     =  try  map.value("condition")
			icon          =  try  map.value("icon")
			dewPoint      =  try  map.value("dew_point")
			pressure      =  try  map.value("mslp")
			humidity      =  try  map.value("humidity")
			visibility    =  try? map.value("visibility")
			precipitation =  try  map.value("precipitation")
			temperature   =  try  map.value("temperature")
			windBearing   =  try? map.value("wind.heading")
			windSpeed     =  try  map.value("wind.speed")
			windGusting   =  try? map.value("wind.gusting")
		}
		catch {
			AirMap.logger.error("Failed to parse AirMapWeather.Observation", metadata: ["error": .string(error.localizedDescription)])
			throw error
		}
	}
}
