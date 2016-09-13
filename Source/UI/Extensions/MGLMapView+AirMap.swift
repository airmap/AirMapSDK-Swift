//
//  MGLMapView+AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 10/7/16.
//
//

import Mapbox
import GLKit

extension MGLMapView {
	
	func controlPointViews() -> [ControlPointView] {
		
		return subviews
			.filter { $0 is GLKView }.first?.subviews
			.filter { String($0.dynamicType) == "MGLAnnotationContainerView"}.first?.subviews
			.flatMap { $0 as? ControlPointView } ?? []
	}
	
	func hideControlPoints(_ hidden: Bool) {
		
		let animations = { self.controlPointViews().forEach { $0.alpha = hidden ? 0 : 1 } }
		UIView.animateWithDuration(0.15, delay: 0, options: [.BeginFromCurrentState, .AllowUserInteraction], animations: animations, completion: nil)
	}
	
	func hideObscuredMidPointControls() {
		
		guard let annotations = annotations else { return }
		let controlPoints = annotations.flatMap { $0 as? ControlPoint }
		let midPoints = controlPoints.filter { $0.type == ControlPointType.MidPoint }
		let vertexPoints = controlPoints.filter { $0.type == .Vertex }
		
		for midPoint in midPoints {
			for vertex in vertexPoints {
				if distance(from: midPoint, to: vertex) < 40 {
					controlPointViews().filter { $0.annotation === midPoint }.first?.hidden = true
					break
				} else {
					controlPointViews().filter { $0.annotation === midPoint }.first?.hidden = false
				}
			}
		}
	}
	
	func distance(from pointA: ControlPoint, to pointB: ControlPoint) -> CGFloat {
		
		let ptA = convertCoordinate(pointA.coordinate, toPointToView: self)
		let ptB = convertCoordinate(pointB.coordinate, toPointToView: self)
		
		return hypot(ptA.x-ptB.x, ptA.y-ptB.y)
	}
	
}
