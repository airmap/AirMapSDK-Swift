//
//  AirMapPointEditingOverlay.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit

class AirMapPointEditingOverlay: UIView {
	
	private var points = [[CGPoint]]()
		
	func drawProposedPath(along points: [[CGPoint]]) {
		
		self.points = points
		setNeedsDisplay()
	}
	
	func clearPath() {

		drawProposedPath(along: [])
	}
	
	override func drawRect(rect: CGRect) {
		super.drawRect(rect)
		
		UIColor.airMapGray().colorWithAlphaComponent(0.5).setStroke()
		
		for pointArray in points {
			
			let cgPath = CGPathCreateMutable()
			CGPathAddLines(cgPath, nil, pointArray, pointArray.count)
			
			let uiPath = UIBezierPath(CGPath: cgPath)
			uiPath.setLineDash([6], count: 1, phase: 0)
			uiPath.lineWidth = 2
			uiPath.miterLimit = 2
			uiPath.lineJoinStyle = .Round
			uiPath.stroke()
		}

	}
	
}
