//
//  MapboxMapViewDelegate.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Mapbox

class AirMapMapboxMapViewDelegate: NSObject, MGLMapViewDelegate {
	
	weak var controlPointDelegate: ControlPointDelegate?
	
	func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
		mapView.hideObscuredMidPointControls()
	}
	
	func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
		return annotation is ControlPointView ? .airMapLightBlue() : .airMapGray()
	}
	
	func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
		return 2.5
	}
	
	func mapView(mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
		if annotation is RedAdvisory {
			return UIColor.airMapRed()
		} else {
			return UIColor.airMapLightBlue()
		}
	}
	
	func mapView(mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
		switch annotation {
		case is MGLPolyline:
			return 1.0
		case is RedAdvisory:
			return 0.25
		default:
			return 0.5
		}
	}
	
	func mapView(mapView: MGLMapView, viewForAnnotation annotation: MGLAnnotation) -> MGLAnnotationView? {
		
		if let controlPoint = annotation as? ControlPoint {
			if let controlPointView = mapView.dequeueReusableAnnotationViewWithIdentifier(String(controlPoint.type)) as? ControlPointView {
				return controlPointView
			} else {
				let controlPointView = ControlPointView(type: controlPoint.type)
				controlPointView.delegate = controlPointDelegate
				return controlPointView
			}
		}
		
		if let invalidIntersection = annotation as? InvalidIntersection {
			if let invalidIntersectionView = mapView.dequeueReusableAnnotationViewWithIdentifier(String(InvalidIntersectionView)) as? InvalidIntersectionView {
				return invalidIntersectionView
			} else {
				return InvalidIntersectionView()
			}
		}
		
		return nil
	}
	
}
