//
//  AirMapFlightAnnotation.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/25/17.
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

import Foundation
import Mapbox

/// NSObject wrapper for AirMapFlight
open class AirMapFlightAnnotation: NSObject {
	
	public let flight: AirMapFlight
	
	public init(_ flight: AirMapFlight) {
		self.flight = flight
	}
	
	override open func isEqual(_ object: Any?) -> Bool {
		guard let object = object as? AirMapFlightAnnotation else {
			return false
		}
		return self.flight == object.flight
	}
	
    override open var hash: Int {
		return flight.hashValue
	}
	
	static func ==(lhs: AirMapFlightAnnotation, rhs: AirMapFlightAnnotation) -> Bool {
		return lhs.flight.hashValue == rhs.flight.hashValue
	}
}

extension AirMapFlightAnnotation: MGLAnnotation {
	
	public var coordinate: CLLocationCoordinate2D {
		return flight.coordinate
	}
	
	public var title: String? {
		guard let startTime = flight.startTime else { return nil }
		let dateFormatter = DateFormatter()
		dateFormatter.doesRelativeDateFormatting = true
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .long
		return dateFormatter.string(from: startTime)
	}

	public static func annotateFlightIcon(_ image: Image?) -> Image? {
		guard let image = image else { return nil }
		if #available(iOS 10.0, *) {
			// Create glowBackgroundView
			let widthInPixels = image.size.width// * image.scale
			let heightInPixels = image.size.height// * image.scale
			let viewSize = CGRect(x: 0, y: 0, width: widthInPixels + 20, height: heightInPixels + 20) // watch out for messing up the aspect ratio here

			let glowBackgroundView = UIView(frame: viewSize)
			glowBackgroundView.backgroundColor = .clear // Change to clear? Do I need this?

			glowBackgroundView.layer.cornerRadius = widthInPixels / 2
			glowBackgroundView.layer.masksToBounds = true
			glowBackgroundView.layer.shadowOffset = .zero
			glowBackgroundView.layer.shadowColor = UIColor.highlight.cgColor
			glowBackgroundView.layer.shadowRadius = 20
			glowBackgroundView.layer.shadowOpacity = 1
			glowBackgroundView.layer.shadowPath = UIBezierPath(rect: glowBackgroundView.bounds).cgPath

			// Render glowBackgroundView to glowBackgroundImage
			let renderer = UIGraphicsImageRenderer(size: glowBackgroundView.bounds.size)
			let glowBackgroundImage = renderer.image { ctx in
				glowBackgroundView.drawHierarchy(in: glowBackgroundView.bounds, afterScreenUpdates: true)
				ctx.cgContext.addEllipse(in: glowBackgroundView.bounds)
			}

			// Merge glowBackgroundImage with flightIcon
			UIGraphicsBeginImageContext(viewSize.size)
			glowBackgroundImage.draw(in: viewSize)
			image.draw(in: viewSize, blendMode: .normal, alpha: 0.8) // Change alpha
			let combinedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
			UIGraphicsEndImageContext()

			return combinedImage
		} else {
			return image
		}
	}

}

extension AirMapFlightAnnotation: AnnotationRepresentable {
	
	var buffer: Meters? {
		return flight.buffer
	}
	
	var geometry: AirMapGeometry? {
		return flight.geometry
	}

}
