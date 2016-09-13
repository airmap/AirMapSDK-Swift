//
//  AirMapDrawingLoupeView.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/16/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import GLKit

class AirMapDrawingLoupeView: UIView {

	var magnifiedView: UIView? {
		didSet { setNeedsDisplay() }
	}

	var anchor = CGPointZero {
		didSet {
			setNeedsDisplay()
			center = CGPointMake(anchor.x - 80, anchor.y - 80)
		}
	}
	
	private let loupe = CALayer()
	
	init() {
		super.init(frame: CGRectMake(0, 0, 110, 110))
		
//		userInteractionEnabled = false
		backgroundColor = .clearColor()

		layer.shadowOffset = CGSize(width: 10, height: 10)
		layer.shadowColor = UIColor.blackColor().CGColor
		layer.shadowOpacity = 0.5
		layer.shadowRadius = 20
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func drawRect(rect: CGRect) {
		super.drawRect(rect)
		
		guard
			let magnifiedView = magnifiedView,
			let context = UIGraphicsGetCurrentContext()
		else {
			return
		}
		
		let scale: CGFloat = 4.0
		CGContextTranslateCTM(context, frame.width * 0.5, frame.height * 0.5)
		CGContextScaleCTM(context, scale, scale)
		CGContextTranslateCTM(context, -anchor.x, -anchor.y)

		// clip the view to a circle
		let transform = CGAffineTransformMakeScale(1/scale, 1/scale)
		var clipFrame = CGRectApplyAffineTransform(bounds, transform)
		clipFrame = CGRectOffset(clipFrame, anchor.x - clipFrame.width / 2, anchor.y - clipFrame.width / 2)
		let clip = UIBezierPath(ovalInRect: clipFrame).CGPath
		CGContextAddPath(context, clip)
		CGContextClip(context)
		
		// If magnifiedView contains GLView subviews, snapshot and render image
		for glView in magnifiedView.subviews.flatMap({ $0 as? GLKView }) {
			glView.snapshot.drawAtPoint(CGPointZero)
		}
		
		CGContextSetAlpha(context, 0.5)
		
		// Draw the drawing overlay
		magnifiedView.layer.renderInContext(context)

		UIColor.airMapGray().setStroke()
		
		// Add outline to loupe
		CGContextAddPath(context, clip)
		CGContextSetLineWidth(context, 1)
		CGContextStrokePath(context)
		
		// Draw crosshairs
		CGContextMoveToPoint(context, clipFrame.midX, clipFrame.minY)
		CGContextAddLineToPoint(context, clipFrame.midX, clipFrame.maxY)
		CGContextMoveToPoint(context, clipFrame.minX, clipFrame.midY)
		CGContextAddLineToPoint(context, clipFrame.maxX, clipFrame.midY)
		CGContextSetLineWidth(context, 0.5)
		CGContextStrokePath(context)
		
	}
	
}
