//
//  AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/10/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

private typealias RxAirMap_Flight = AirMap
extension RxAirMap_Flight {

	public class func rx_listPublicFlights(fromDate fromDate: NSDate? = nil, toDate: NSDate? = nil, limit: Int? = nil) -> Observable<[AirMapFlight]> {
		return flightClient.listPublicFlights(fromDate: fromDate, toDate: toDate, limit: limit)
	}

	public class func rx_getCurrentAuthenticatedPilotFlight() -> Observable<AirMapFlight?> {
		return flightClient.list(startBeforeNow: true, endAfterNow: true, pilotId: AirMap.authSession.userId, authCheck:true ).map { $0.first }
	}

	public class func rx_getFlight(flightId: String) -> Observable<AirMapFlight> {
		return flightClient.get(flightId)
	}

	public class func rx_listFlights(pilot: AirMapPilot, limit: Int = 100) -> Observable<[AirMapFlight]> {
		return flightClient.list(limit, pilotId: pilot.pilotId)
	}

	public class func rx_createFlight(flight: AirMapFlight, geometryType: AirMapFlight.FlightGeometryType? = .Point) -> Observable<AirMapFlight> {
		return flightClient.create(flight)
	}

	public class func rx_endFlight(flight: AirMapFlight) -> Observable<AirMapFlight> {
		return flightClient.end(flight)
	}

	public class func rx_deleteFlight(flight: AirMapFlight) -> Observable<Void> {
		return flightClient.delete(flight)
	}
}

private typealias RxAirMap_Aircraft = AirMap
extension RxAirMap_Aircraft {

	public class func rx_listManufacturers() -> Observable<[AirMapAircraftManufacturer]> {
		return aircraftClient.listManufacturers()
	}

	public class func rx_listModels() -> Observable<[AirMapAircraftModel]> {
		return aircraftClient.listModels()
	}

	public class func rx_getModel(modelId: String) -> Observable<AirMapAircraftModel> {
		return aircraftClient.getModel(modelId)
	}
}

private typealias RxAirMap_Pilot_Aircraft = AirMap
extension RxAirMap_Pilot_Aircraft {

	public class func rx_listAircraft() -> Observable<[AirMapAircraft]> {
		return pilotClient.listAircraft()
	}

	public class func rx_createAircraft(aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		return pilotClient.createAircraft(aircraft)
	}

	public class func rx_updateAircraft(aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		return pilotClient.updateAircraft(aircraft)
	}

	public class func rx_deleteAircraft(aircraft: AirMapAircraft) -> Observable<Void> {
		return pilotClient.deleteAircraft(aircraft)
	}
}

private typealias RxAirMap_Pilot = AirMap
extension RxAirMap_Pilot {

	public class func rx_getPilot(pilotId: String) -> Observable<AirMapPilot> {
		return pilotClient.get(pilotId)
	}

	public class func rx_getAuthenticatedPilot() -> Observable<AirMapPilot> {
		return pilotClient.getAuthenticatedPilot()
	}

	public class func rx_updatePilot(pilot: AirMapPilot) -> Observable<AirMapPilot> {
		return pilotClient.update(pilot)
	}

	public class func rx_sendVerificationToken() -> Observable<Void> {
		return pilotClient.sendVerificationToken()
	}

	public class func rx_verifySMS(token: String) -> Observable<AirMapPilotVerified> {
		return pilotClient.verifySMS(token)
	}
}

private typealias RxAirMap_Pilot_Permits = AirMap
extension RxAirMap_Pilot_Permits {

	public class func rx_listPilotPermits() -> Observable<[AirMapPilotPermit]> {
		return pilotClient.listPilotPermits()
	}

	public class func rx_deletePilotPermit(pilotId: String, permit: AirMapPilotPermit) -> Observable<Void> {
		return pilotClient.deletePilotPermit(pilotId, permit: permit)
	}
}

private typealias RxAirMap_Permit = AirMap
extension RxAirMap_Permit {

	public class func rx_listPermits(permitIds: [String]? = nil, organizationId: String? = nil) -> Observable<[AirMapAvailablePermit]> {
		return permitClient.list(permitIds, organizationId: organizationId)
	}

	public class func rx_getAvailablePermit(permitId: String) -> Observable<AirMapAvailablePermit?> {
		return permitClient.list([permitId]).map { $0.first }
	}

	public class func rx_applyForPermit(permit: AirMapAvailablePermit) -> Observable<AirMapPilotPermit> {
		return permitClient.apply(permit)
	}

}

private typealias RxAirMap_Status = AirMap
extension RxAirMap_Status {

	public class func rx_checkCoordinate(coordinate: CLLocationCoordinate2D,
	                                  buffer: Double,
	                                  types: [AirMapAirspaceType]? = nil,
	                                  ignoredTypes: [AirMapAirspaceType]? = nil,
	                                  weather: Bool = false,
	                                  date: NSDate = NSDate()) -> Observable<AirMapStatus> {

		return statusClient.checkCoordinate(coordinate,
		                                    buffer: buffer,
		                                    types: types,
		                                    ignoredTypes: ignoredTypes,
		                                    weather: weather,
		                                    date: date)
	}

	public class func rx_checkFlightPath(path: [CLLocationCoordinate2D],
	                                  buffer: Int,
	                                  takeOffPoint: CLLocationCoordinate2D,
	                                  types: [AirMapAirspaceType]? = nil,
	                                  ignoredTypes: [AirMapAirspaceType]? = nil,
	                                  weather: Bool = false,
	                                  date: NSDate = NSDate()) -> Observable<AirMapStatus> {

		return statusClient.checkFlightPath(path,
		                                    buffer: buffer,
		                                    takeOffPoint: takeOffPoint,
		                                    types: types,
		                                    ignoredTypes: ignoredTypes,
		                                    weather: weather,
		                                    date: date)
	}

	public class func rx_checkPolygon(geometry: [CLLocationCoordinate2D],
	                               takeOffPoint: CLLocationCoordinate2D,
	                               types: [AirMapAirspaceType]? = nil,
	                               ignoredTypes: [AirMapAirspaceType]? = nil,
	                               weather: Bool = false,
	                               date: NSDate = NSDate()) -> Observable<AirMapStatus> {

		return statusClient.checkPolygon(geometry,
		                                 takeOffPoint: takeOffPoint,
		                                 types: types,
		                                 ignoredTypes: ignoredTypes,
		                                 weather: weather,
		                                 date: date)
	}

}

private typealias RxAirMap_Airspace = AirMap
extension RxAirMap_Airspace {

	class func rx_getAirspace(airspaceId: String) -> Observable<AirMapAirspace> {
		return airspaceClient.getAirspace(airspaceId)
	}
	
	class func rx_listAirspace(airspaceIds: [String]) -> Observable<[AirMapAirspace]> {
		return airspaceClient.listAirspace(airspaceIds)
	}	

}

#if AIRMAP_TRAFFIC

class RxAirMapTrafficDelegateProxy: DelegateProxy, DelegateProxyType {

	static func currentDelegateFor(object: AnyObject) -> AnyObject? {
		return AirMap.trafficDelegate
	}

	static func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
		AirMap.trafficDelegate = delegate as? AirMapTrafficObserver
	}

}

private typealias RxAirMap_Traffic = AirMap
extension RxAirMap_Traffic {


	public static var rx_trafficDelegate: DelegateProxy {
		return RxAirMapTrafficDelegateProxy.proxyForObject(self)
	}

	public static var rx_trafficServiceDidConnect: Observable<Bool> {

		return rx_trafficDelegate.observe(#selector(AirMapTrafficObserver.airMapTrafficServiceDidConnect))
			.map { _ in return true }
	}

	public static var rx_trafficServiceDidDisconnect: Observable<Bool> {
		return rx_trafficDelegate.observe(#selector(AirMapTrafficObserver.airMapTrafficServiceDidDisconnect))
			.map { _ in return false }
	}

	public static var rx_trafficServiceDidAdd: Observable<[AirMapTraffic]> {
		return rx_trafficDelegate.observe(#selector(AirMapTrafficObserver.airMapTrafficServiceDidAdd(_:)))
			.map { $0 as! [AirMapTraffic] }
	}

	public static var rx_trafficServiceDidUpdate: Observable<[AirMapTraffic]> {
		return rx_trafficDelegate.observe(#selector(AirMapTrafficObserver.airMapTrafficServiceDidUpdate(_:)))
			.map { $0 as! [AirMapTraffic] }
	}

	public static var rx_trafficServiceDidRemove: Observable<[AirMapTraffic]> {
		return rx_trafficDelegate.observe(#selector(AirMapTrafficObserver.airMapTrafficServiceDidRemove(_:)))
			.map { $0 as! [AirMapTraffic] }
	}

}
#endif
