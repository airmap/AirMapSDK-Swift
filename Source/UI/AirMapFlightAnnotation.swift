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
		guard #available(iOS 10.0, *) else { return image }

		let stroke: CGFloat = 1.5
		let rect = CGRect(x: 0, y: 0, width: image.size.width+stroke*2, height: image.size.height+stroke*2)

		// Add halo to image
		UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
		defer {
			UIGraphicsEndImageContext()
		}

		guard let context = UIGraphicsGetCurrentContext() else {
			return nil
		}

		context.setFillColor(UIColor.highlight.cgColor)
		context.setAlpha(0.8)
		context.fillEllipse(in: rect)
		context.setAlpha(1.0)
		context.draw(image.cgImage!, in: CGRect(origin: .zero, size: image.size).offsetBy(dx: stroke, dy: stroke))

		return UIGraphicsGetImageFromCurrentImageContext()
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
