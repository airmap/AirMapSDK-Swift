//
//  AirMapDrawingOverlayView.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/6/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import SwiftSimplify

protocol DrawingOverlayDelegate: class {
	func overlayDidDraw(geometry: [CGPoint])
}

class AirMapDrawingOverlayView: UIView {
	
	weak var delegate: DrawingOverlayDelegate?
	
	var tolerance: Float = 10
	var discardsDuplicateClosingPoint = false
	
	private var points = [CGPoint]()
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		
		points = []

		let point = touches.first!.locationInView(self)
		points.append(point)
	}
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		
		let point = touches.first!.locationInView(self)
		points.append(point)
		setNeedsDisplay()
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		
		let point = touches.first!.locationInView(self)
		points.append(point)

		points = SwiftSimplify.simplify(points, tolerance: tolerance, highQuality: true)

		if discardsDuplicateClosingPoint {
			discardDuplicateClosingPoint(within: tolerance*2)
		}

		delegate?.overlayDidDraw(points)
		
		points = []
		setNeedsDisplay()
	}
	
	override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
		
		touchesEnded(touches!, withEvent: event)
	}
	
	override func drawRect(rect: CGRect) {
		super.drawRect(rect)
		
		let cgPath = CGPathCreateMutable()
		CGPathAddLines(cgPath, nil, points, points.count)
		
		UIColor.airMapGray().setStroke()
		
		let uiPath = UIBezierPath(CGPath: cgPath)
		uiPath.setLineDash([6,6], count: 2, phase: 0)
		uiPath.lineWidth = 2
		uiPath.stroke()
	}
	
	private func discardDuplicateClosingPoint(within tolerance: Float) {
		
		guard points.count >= 2 else { return }
		
		let first = points.first!
		let last = points.last!
		
		let distance = Float(hypot(first.x-last.x, first.y-last.y))
		if distance < tolerance {
			points.removeLast()
		}
		
	}

}
