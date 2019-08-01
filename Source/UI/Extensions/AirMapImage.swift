//
//  UIImage+AirMap.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/15/16.
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

#if os(OSX)
	public typealias Image = NSImage
#else
import UIKit
	public typealias Image = UIImage
#endif

public class AirMapImage {
	
	static func image(named name: String) -> Image? {
		
		#if os(OSX)
			// TODO:
			return nil
		#else
			return UIImage(named: name, in: AirMapBundle.core, compatibleWith: nil)
		#endif
	}
	
	#if AIRMAP_TRAFFIC
	public static func trafficIcon(type: AirMapTraffic.TrafficType, heading: Int) -> Image? {

		let direction = heading == 0 ? "" : "_" + AirMapTrafficServiceUtils.directionFromBearing(Double(heading), localized:false)

		switch type {
		case .situationalAwareness:
			return AirMapImage.image(named: "sa_traffic_marker_icon" + direction)
		case .alert:
			return AirMapImage.image(named: "traffic_marker_icon" + direction)
		}
	}
	#endif

}
