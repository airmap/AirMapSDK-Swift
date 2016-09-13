//
//  AirMapFlightTypeButton.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/9/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit

class AirMapFlightTypeButton: UIButton {
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		adjustInsets()
	}
	
	private func adjustInsets() {
		
		let spacing: CGFloat = 3.0
		
		var titleEdgeInsets = UIEdgeInsetsZero
		if let image = imageView?.image {
			titleEdgeInsets.left = -image.size.width
			titleEdgeInsets.bottom = -(image.size.height + spacing)
		}
		self.titleEdgeInsets = titleEdgeInsets;
		
		var imageEdgeInsets = UIEdgeInsetsZero
		if let
			text: NSString = self.titleLabel?.text,
			font = self.titleLabel?.font {
				let attributes = [NSFontAttributeName: font]
				let titleSize = text.sizeWithAttributes(attributes)
				imageEdgeInsets.top = -(titleSize.height + spacing)
				imageEdgeInsets.right = -titleSize.width
			}
		self.imageEdgeInsets = imageEdgeInsets
	}
	
}
