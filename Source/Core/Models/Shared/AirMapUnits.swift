//
//  AirMapUnits.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 2/7/17.
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

public enum DistanceUnits {
	case metric
	case imperial
}

public typealias Feet = Double
public typealias Meters = Double
public typealias Kilometers = Double
public typealias StatuteMiles = Double
public typealias NauticalMiles = Double
public typealias Acres = Double
public typealias Hectares = Double

public extension Feet {
	
	static let metersPerFoot: Meters = 1/3.28084

	var meters: Meters {
		return self * Feet.metersPerFoot
	}
}

public extension Meters {
	
	static let metersPerNauticalMile: Meters = 1852.0
	static let metersPerStatuteMile: Meters = 1609.34

	var nauticalMiles: NauticalMiles {
		return self / Meters.metersPerNauticalMile
	}
	
	var feet: Feet {
		return self / Feet.metersPerFoot
	}
}

public extension Kilometers {
	
	var statuteMiles: StatuteMiles {
		return self * 1000 / Meters.metersPerStatuteMile
	}
}

public extension Hectares {
	
	var acres: Acres {
		return self / 0.404686
	}
}

public typealias Knots = Double
public typealias MilesPerHour = Double
public typealias MetersPerSecond = Double
public typealias KilometersPerHour = Double

public extension Knots {
	
	static let metersPerSecondPerKnot = 0.514444
}

public extension KilometersPerHour {
	
	var metersPerSecond: MetersPerSecond {
		return self / 3.6
	}
	
	var milesPerHour: MilesPerHour {
		return self * 0.621371
	}
	
	var knots: Knots {
		return self * 0.539957
	}
}

public enum TemperatureUnits {
	case celcius
	case fahrenheit
}

public typealias Celcius = Double
public typealias Fahrenheit = Double

public extension Celcius {
	
	var fahrenheit: Fahrenheit {
		return (self * 9.0/5.0) + 32.0
	}
}

public extension Fahrenheit {
	
	var celcius: Celcius {
		return (self - 32.0) * (5.0/9.0)
	}
}

public typealias HPa = Double
public typealias InHg = Double

public extension HPa {
	
	var inHg: InHg {
		return self * 0.02953
	}
}

#if os(Linux)
	
	public typealias Coordinate2D = AirMapLocationCoordinate2D
	
	public struct AirMapLocationCoordinate2D {
		
		let latitude: Double
		let longitude: Double
		
		var isValid: Bool {
			return (latitude <= 90 && latitude >= -90) && (longitude <= 180 && longitude >= -180)
		}
	}
	
#else
	
	import CoreLocation
	
	public typealias Coordinate2D = CLLocationCoordinate2D
	
	extension CLLocationCoordinate2D {
		
		public var isValid: Bool {
			return CLLocationCoordinate2DIsValid(self)
		}
	}
	
#endif
