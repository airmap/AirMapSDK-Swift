//
//  Color+App.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/19/16.
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
	import AppKit
	public typealias Color = NSColor
#else
	import UIKit
	public typealias Color = UIColor
#endif

public extension Color {

	public static var airMapLightBlue: Color {
		return Color(red: 136.0/255.0, green: 219.0/255.0, blue: 223.0/255.0, alpha: 1.0)
	}

	public static var airMapDarkBlue: Color {
		return Color(red: 51.0/255.0, green: 63.0/255.0, blue: 72.0/255.0, alpha: 1.0)
	}
	
	public static var airMapDarkGray: Color {
		return Color(red: 51.0/255.0, green: 63.0/255.0, blue: 72.0/255.0, alpha: 1.0)
	}
	
	public static var airMapGreen: Color {
		return Color(red: 108.0/255.0, green: 194.0/255.0, blue: 74.0/255.0, alpha: 1.0)
	}
	
	public static var airMapYellow: Color {
		return Color(red: 249.0/255.0, green: 225.0/255.0, blue: 59.0/255.0, alpha: 1.0)
	}
	
	public static var airMapOrange: Color {
		return Color(red: 252.0/255.0, green: 145.0/255.0, blue: 0.0/255.0, alpha: 1.0)
	}
	
	public static var airMapLightGray: Color {
		return Color(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
	}
	
	public static var airMapRed: Color {
		return Color(red: 208.0/255.0, green: 1.0/255.0, blue: 27.0/255.0, alpha: 1.0)
	}
	
	public static var airMapBlack: Color {
		return .black
	}

	public static var primary: Color {
		var primaryColor: Color?
		if #available(iOS 11.0, *) {
			primaryColor = Color(named: "Primary")
		}
		return primaryColor ?? .airMapDarkGray
	}

	public static var secondary: Color {
		var secondaryColor: Color?
		if #available(iOS 11.0, *) {
			secondaryColor = Color(named: "Secondary")
		}
		return secondaryColor ?? Color(red: 40/255, green: 49/255, blue: 56/255, alpha: 1)
	}

	public static var highlight: Color {
		var highlightColor: Color?
		if #available(iOS 11.0, *) {
			highlightColor = Color(named: "Highlight")
		}
		return highlightColor ?? .airMapLightBlue
	}
}
