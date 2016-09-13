//
//  AirMapFlight+MGL.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/5/16.
//
//

import Mapbox
import SwiftTurf

extension AirMapFlight: MGLAnnotation {
		
	public var title: String? {
		guard let startTime = startTime else { return nil }
		let dateFormatter = NSDateFormatter()
		dateFormatter.doesRelativeDateFormatting = true
		dateFormatter.dateStyle = .MediumStyle
		dateFormatter.timeStyle = .LongStyle
		return dateFormatter.stringFromDate(startTime)
	}
	
	public func annotationRepresentations() -> [MGLAnnotation]? {
		
		guard let buffer = self.buffer else { return nil }
		
		switch geometryType() {

		case .Point:
			
			guard let centerCoordinate = (geometry as? AirMapPoint)?.coordinate
			else { return nil }
			
			let point = Point(geometry: centerCoordinate)
			let bufferedPoint = SwiftTurf.buffer(point, distance: buffer, units: .Meters)
			var coordinates = bufferedPoint?.geometry.first ?? []
			let circlePolygon = MGLPolygon(coordinates: &coordinates, count: UInt(coordinates.count))
			let circleLine = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))

			return [circlePolygon, circleLine]
			
		case .Path:

			guard var coordinates = (geometry as? AirMapPath)?.coordinates
			where coordinates.count >= 2
			else { return nil }

			let lineString = LineString(geometry: coordinates)

			guard let bufferedCoordinates = SwiftTurf.buffer(lineString, distance: buffer)?.geometry else {
				return nil
			}
			var outerCoordinates = bufferedCoordinates.first!
			
			var interiorPolygons: [MGLPolygon] = bufferedCoordinates.map {
				var coordinates = $0
				return MGLPolygon(coordinates: &coordinates, count: UInt(coordinates.count))
			}
			interiorPolygons.removeFirst()
			
			let bufferPolygon = Buffer(coordinates: &outerCoordinates, count: UInt(outerCoordinates.count), interiorPolygons: interiorPolygons)
			let pathPolyline = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))

			return [bufferPolygon, pathPolyline]

		case .Polygon:
			
			guard
				var coordinates = (geometry as? AirMapPolygon)?.coordinates
			where
				coordinates.count >= 3
			else { return nil }
			
			coordinates.append(coordinates.first!)
			
			let polygon = MGLPolygon(coordinates: &coordinates, count: UInt(coordinates.count))
			let polyline = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
			
			return [polygon, polyline]
		}
	
	}

}
