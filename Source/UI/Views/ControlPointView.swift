//
//  ControlPointView.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/21/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import Mapbox

enum ControlPointType {
	case Vertex
	case MidPoint
}

class ControlPoint: MGLPointAnnotation {
	
	var type: ControlPointType
	
	init(type: ControlPointType = .Vertex, coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()) {
		self.type = type
		super.init()
		self.coordinate = coordinate
	}
}

protocol ControlPointDelegate: class {
	func didStartDragging(controlPoint: ControlPointView)
	func didDrag(controlPoint: ControlPointView, to point: CGPoint)
	func didEndDragging(controlPoint: ControlPointView)
}

class ControlPointView: MGLAnnotationView {
	
	weak var delegate: ControlPointDelegate?
	
	var controlPoint: ControlPoint? {
		return annotation as? ControlPoint
	}
	
	var type = ControlPointType.Vertex {
		didSet { configureForType() }
	}
	
	init(type: ControlPointType) {
		super.init(reuseIdentifier: String(type))
		
		self.type = type
		
		draggable = true
		scalesWithViewingDistance = false
		
		// Reduce annotation long press gesture delay
		gestureRecognizers?
			.flatMap { $0 as? UILongPressGestureRecognizer }
			.forEach { $0.minimumPressDuration = 0.08 }
		
		configureForType()
	}
	
	override init(frame: CGRect) {
		super.init(frame: CGRectMake(0, 0, 35, 35))

		layer.backgroundColor = UIColor.clearColor().CGColor
		layer.borderWidth = 0
		layer.borderColor = UIColor.clearColor().CGColor
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		layer.cornerRadius = bounds.size.width / 2
	}
	
	private func configureForType() {
		
		let handle = CAShapeLayer()

		switch type {
			
		case .Vertex:
			layer.zPosition = 0
			handle.path = UIBezierPath(ovalInRect: CGRectInset(frame, 8, 8)).CGPath
			handle.fillColor = UIColor.whiteColor().CGColor
			handle.borderWidth = 2
			handle.strokeColor = UIColor.airMapGray().CGColor
			handle.shadowColor = UIColor.airMapGray().CGColor
			handle.shadowOpacity = 0.5
			handle.shadowOffset = CGSize(width: 3, height: 3)
			layer.addSublayer(handle)
			
		case .MidPoint:
			layer.zPosition = -1
			handle.path = UIBezierPath(ovalInRect: CGRectInset(frame, 14, 14)).CGPath
			handle.fillColor = UIColor.airMapGray().CGColor
			layer.addSublayer(handle)
		}
	}
	
	override func setDragState(dragState: MGLAnnotationViewDragState, animated: Bool) {
		super.setDragState(dragState, animated: animated)
		
		switch dragState {
		case .Starting:
			delegate?.didStartDragging(self)
		case .Dragging:
			delegate?.didDrag(self, to: center)
		case .Ending, .Canceling:
			delegate?.didEndDragging(self)
		case .None:
			break
		}
	}
	
}


