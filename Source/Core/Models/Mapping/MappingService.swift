//
//  AirMapMapTiles.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/6/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

/**

Supported Map Layers

*/
public enum AirMapLayerType: Int, CustomStringConvertible {
	
	case TFRs
	case Wildfires
	case HazardAreas
	case RecreationalAreas
	case Prohibited
	case Restricted
	case NationalParks
	case NOAA
	case Schools
	case Hospitals
	case Heliports
	case PowerPlants
	case AirportsCommercial
	case AirportsCommercialPrivate
	case AirportsRecreational
	case AirportsRecreationalPrivate
	case ClassB
	case ClassC
	case ClassD
	case ClassE
	case EssentialAirspace
	
	public static let allLayerTypes = [
		TFRs,
		Wildfires,
		HazardAreas,
		RecreationalAreas,
		Prohibited,
		Restricted,
		NationalParks,
		NOAA,
		Schools,
		Hospitals,
		Heliports,
		PowerPlants,
		AirportsCommercial,
		AirportsRecreational,
		ClassB,
		ClassC,
		ClassD,
		ClassE,
		AirportsCommercialPrivate,
		AirportsRecreationalPrivate
	]
	
	public var type: String {
		
		switch self {
		case .TFRs:
			return "tfrs"
		case .Wildfires:
			return "wildfires"
		case HazardAreas:
			return "hazard_areas"
		case RecreationalAreas:
			return "aerial_recreational_areas"
		case .Prohibited:
			return "sua_prohibited"
		case .Restricted:
			return "sua_restricted"
		case .NationalParks:
			return "national_parks"
		case .NOAA:
			return "noaa"
		case .Schools:
			return "schools"
		case .Hospitals:
			return "hospitals"
		case .Heliports:
			return "heliports"
		case .PowerPlants:
			return "power_plants"
		case .AirportsCommercial:
			return "airports_commercial"
		case .AirportsRecreational:
			return	"airports_recreational"
		case .AirportsCommercialPrivate:
			return "airports_commercial_private"
		case .AirportsRecreationalPrivate:
			return	"airports_recreational_private"
		case .ClassB:
			return "class_b"
		case .ClassC:
			return "class_c"
		case .ClassD:
			return "class_d"
		case .ClassE:
			return "class_e0"  // ClassE *at the surface
		case EssentialAirspace:
			return "class_b,class_c,class_d,class_e0"
		}
	}
	
	public var category: String {
		
		switch self {
		case .TFRs:
			return "TFRs"
		case .Wildfires:
			return "Wildfires"
		case .HazardAreas:
			return "Hazard Areas"
		case .RecreationalAreas:
			return "Aerial Recreational Areas"
		case .Prohibited, .Restricted:
			return "Special Use Airspace"
		case .NationalParks:
			return "National Park"
		case .NOAA:
			return "NOAA"
		case .Schools:
			return "School"
		case .Hospitals:
			return "Hospital"
		case .Heliports:
			return "Heliport"
		case .PowerPlants:
			return "Power Plant"
		case .AirportsCommercial, .AirportsRecreational, AirportsCommercialPrivate, .AirportsRecreationalPrivate:
			return "Airport"
		case .ClassB, .ClassC, .ClassD, .ClassE, .EssentialAirspace:
			return "Controlled Airspace"
			
		}
	}
	
	public var title: String {
		
		switch self {
		case .TFRs:
			return "Temporary Flight Restriction"
		case .Wildfires:
			return "Wildfires"
		case .HazardAreas:
			return "Hazard Areas"
		case .RecreationalAreas:
			return "Aerial Recreational Areas"
		case .Prohibited:
			return "Prohibited Area"
		case .Restricted:
			return "Restricted Area"
		case .NationalParks:
			return "National Park"
		case .NOAA:
			return "NOAA"
		case .Schools:
			return "School"
		case .Hospitals:
			return "Hospital"
		case .Heliports:
			return "Heliport"
		case .PowerPlants:
			return "Power Plant"
		case .AirportsCommercial:
			return "Airport"
		case .AirportsRecreational:
			return	"Airport"
		case .AirportsCommercialPrivate:
			return "Private Airport"
		case .AirportsRecreationalPrivate:
			return	"Private Airport"
		case .ClassB:
			return "Class B Airspace"
		case .ClassC:
			return "Class C Airspace"
		case .ClassD:
			return "Class D Airspace"
		case .ClassE:
			return "Class E Airspace"  // ClassE *at the surface
		case EssentialAirspace:
			return "Essential Airspace (B, C, D & E)"
		}
	}
	
	public var description: String {
		
		switch self {
		case .TFRs:
			return "Temporary flight restriction"
		case .Wildfires:
			return "Wildfires"
		case .HazardAreas:
			return "Hazard Areas"
		case .RecreationalAreas:
			return "Aerial Recreational Areas"
		case .Prohibited:
			return "Prohibited airspace"
		case .Restricted:
			return "Restricted airspace"
		case .NationalParks:
			return "National park"
		case .NOAA:
			return "NOAA marine protection area"
		case .Schools:
			return "School"
		case .Hospitals:
			return "Hospital"
		case .Heliports:
			return "Heliport"
		case .PowerPlants:
			return "Power Plant"
		case .AirportsCommercial:
			return "Airport"
		case .AirportsRecreational:
			return	"Airport"
		case .AirportsCommercialPrivate:
			return "Private Airport"
		case .AirportsRecreationalPrivate:
			return	"Private Airport"
		case .ClassB:
			return "Class B controlled airspace"
		case .ClassC:
			return "Class C controlled airspace"
		case .ClassD:
			return "Class D controlled airspace"
		case .ClassE:
			return "Class E controlled airspace to the surface"
		case EssentialAirspace:
			return "Essential Airspace (B, C, D & E)"
		}
	}
	
	public var airSpaceType: AirMapAirspaceType {
		
		switch self {
		case .AirportsCommercial,
		     .AirportsRecreational,
		     .AirportsRecreationalPrivate,
		     .AirportsCommercialPrivate:
			return .Airport
			
		case .Heliports :
			return .Heliport
			
		case .NationalParks,
		     .NOAA:
			
			return AirMapAirspaceType.Park
			
		case .ClassB,
		     .ClassC,
		     .ClassD,
		     .ClassE,
		     .EssentialAirspace:
			return .ControlledAirspace
			
		case .Hospitals:
			return.Hospital
			
		case .PowerPlants:
			return .PowerPlant
			
		case .Schools:
			return .School
			
		case .TFRs:
			return .TFR
			
		case .Restricted,
		     .Prohibited:
			return .SpecialUse
			
		case .Wildfires:
			return .Wildfires
		case .HazardAreas:
			return .HazardArea
		case .RecreationalAreas:
			return .RecreationalArea
		}
	}
}

public enum AirMapAirspaceType: Int {
	
	case Airport
	case Heliport
	case Park
	case Hospital
	case PowerPlant
	case ControlledAirspace
	case School
	case SpecialUse
	case TFR
	case Wildfires
	case HazardArea
	case RecreationalArea
	
	public var type: String {
		
		switch self {
		case Airport:
			return "airport"
		case Heliport:
			return "heliport"
		case Park:
			return "park"
		case PowerPlant:
			return "power_plant"
		case .Hospital:
			return "hospital"
		case ControlledAirspace:
			return "controlled_airspace"
		case School:
			return "school"
		case SpecialUse:
			return "special_use_airspace"
		case TFR:
			return "tfr"
		case Wildfires:
			return "wildfire"
		case HazardArea:
			return "hazard_area"
		case RecreationalArea:
			return "recreational_area"
		}
	}
	
	public var title: String {
		
		switch self {
		case Airport:
			return "Airport"
		case .Heliport:
			return "Heliport"
		case Park:
			return "Park"
		case PowerPlant:
			return "Power Plant"
		case ControlledAirspace:
			return "Controlled Airspace"
		case School:
			return "School"
		case SpecialUse:
			return "Special Use Airspace"
		case TFR:
			return "Temporary Flight Restriction"
		case Wildfires:
			return "Wildfire"
		case .Hospital:
			return "Hospital"
		case .HazardArea:
			return "Hazard Area"
		case .RecreationalArea:
			return "Recreational Area"
		}
	}
	
	public static let allAirspaceTypes: [AirMapAirspaceType] = [
		.Airport,
		.Heliport,
		.Park,
		.Hospital,
		.PowerPlant,
		.ControlledAirspace,
		.School,
		.SpecialUse,
		.TFR,
		.Wildfires,
		.HazardArea,
		.RecreationalArea
	]
	
	public static func airspaceTypeFromName(name: String) -> AirMapAirspaceType? {
		
		switch name {
		case AirMapAirspaceType.Airport.type:
			return .Airport
		case AirMapAirspaceType.Park.type:
			return .Park
		case AirMapAirspaceType.Heliport.type:
			return .Heliport
		case AirMapAirspaceType.Hospital.type:
			return .Hospital
		case AirMapAirspaceType.PowerPlant.type:
			return .PowerPlant
		case AirMapAirspaceType.ControlledAirspace.type:
			return .ControlledAirspace
		case AirMapAirspaceType.School.type:
			return .School
		case AirMapAirspaceType.Airport.type:
			return .Airport
		case AirMapAirspaceType.SpecialUse.type:
			return .SpecialUse
		case AirMapAirspaceType.TFR.type:
			return .TFR
		case AirMapAirspaceType.Wildfires.type:
			return .Wildfires
		case AirMapAirspaceType.HazardArea.type:
			return .HazardArea
		case AirMapAirspaceType.RecreationalArea.type:
			return .RecreationalArea
		default:
			return nil
		}
	}
}

/**

Supported Map Themes

*/
public enum AirMapMapTheme: Int {
	
	case Standard
	case Dark
	case Light
	case Satellite
	
	public var name: String {
		switch self {
		case .Standard:
			return "standard"
		case .Dark:
			return "dark"
		case .Light:
			return "light"
		case .Satellite:
			return "satellite"
		}
	}
	
}

internal class MappingService {
	
	/**
	
	Generates and returns map tile source url based upon Map Layers & Theme.
	
	- parameter layers: An array of AirMapMapLayer's.
	- parameter theme: An AirMapMapTheme.
	
	- returns: NSURL?
	
	*/
	func tileSourceUrl(layers: [AirMapLayerType], theme: AirMapMapTheme) -> NSURL? {
		
		let apiKey = AirMap.configuration.airMapApiKey
		let tiles  = layers.count == 0 ? "_-_" : layers.flatMap {$0.type}.joinWithSeparator(",")
		let urlString = Config.AirMapApi.mapTilesUrl + "/\(tiles)?&theme=\(theme.name)&apikey=\(apiKey)&token=\(apiKey)"
		
		return  NSURL(string: urlString)
	}
	
}
