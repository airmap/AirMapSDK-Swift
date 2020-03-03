//
//  AirMapFlight+Mapbox.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/5/16.
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

import Mapbox
import SwiftTurf

protocol AnnotationRepresentable {
	var geometry: AirMapGeometry? { get }
	var buffer: Meters? { get }
}

extension AnnotationRepresentable {
	
	public func annotationRepresentations() -> [MGLAnnotation]? {
		
		guard let geometry = self.geometry else { return nil }
		
		switch geometry.type {
			
		case .point:
			
			guard let buffer = self.buffer
				else { return nil }
			
			guard let centerCoordinate = (geometry as? AirMapPoint)?.coordinate
				else { return nil }
			
			let point = Point(geometry: centerCoordinate)
			let bufferedPoint = SwiftTurf.buffer(point, distance: buffer, units: .Meters)
			
			guard var coordinates = bufferedPoint?.geometry.first
				else { return nil }
			
			let circlePolygon = MGLPolygon(coordinates: &coordinates, count: UInt(coordinates.count))
			let circleLine = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
			return [circlePolygon, circleLine]
			
		case .path:
			
			guard let buffer = self.buffer
				else { return nil }
			
			guard var coordinates = (geometry as? AirMapPath)?.coordinates, coordinates.count >= 2
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
			
			let bufferPolygon = MGLPolygon(coordinates: &outerCoordinates, count: UInt(outerCoordinates.count), interiorPolygons: interiorPolygons)
			
			let pathPolyline = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
			
			return [bufferPolygon, pathPolyline]
			
		case .polygon:
			
			guard
				let polygons = (geometry as? AirMapPolygon)?.coordinates,
				polygons.count > 0 &&
					polygons.first!.count >= 3
				else {
					return nil
			}
			
			var outer = polygons.first!
			outer.append(outer.first!)
			
			let fill: MGLPolygon
			let strokes: [MGLAnnotation]
			
			if polygons.count == 1 {
				fill = MGLPolygon(coordinates: &outer, count: UInt(outer.count))
				strokes = [MGLPolyline(coordinates: &outer, count: UInt(outer.count))]
			} else {
				let interiorPolygons: [MGLPolygon] = polygons[1..<polygons.count].map {
					var coords = $0
					return MGLPolygon(coordinates: &coords, count: UInt(coords.count))
				}
				fill = MGLPolygon(coordinates: &outer, count: UInt(outer.count), interiorPolygons: interiorPolygons)
				strokes = interiorPolygons.map { polygon in
					MGLPolyline(coordinates: polygon.coordinates, count: UInt(interiorPolygons.count))
				}
			}
			
			return [fill] + strokes
		}		
	}
	
}

