//
//  AirMapAdvisory.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/8/17.
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

/// An airspace object that intersects with area of operation.
public struct AirMapAdvisory {
	
	/// The advisory's unique identifier
	public let id: AirMapAdvisoryId
	
	/// The airspace classification type
	public let type: AirMapAirspaceType
	
	/// A color representative of the advisory level
	public let color: Color
	
	/// A descriptive title
	public let name: String
	
	/// The location of the advisory
	public let coordinate: Coordinate2D
		
	/// The advisory location's city
	public let city: String?

	/// The advisory location's state/province
	public let state: String?

	/// The advisory location's country
	public let country: String
	
	/// The identifier of the rule that generated the advisory
	public let ruleId: Int

	/// The identifier of the ruleset from which the rule originated
	public let rulesetId: String
	
	/// Additional metadata specific to the advisory type
	public let properties: AdvisoryProperties?

	/// Describes the list of intervals the advisory is active
	public let timeSheets: [Timesheet]?

	/// Any requirements necessary to operate within the advisory
	public let requirements: AirMapAdvisoryRequirements?

	/// The date and time the advisory was last updated
	public let lastUpdated: Date
	
	/// A color representative of the level of advisory
	public enum Color: String {
		/// Restricted
		case red
		/// Action required
		case orange
		/// Caution
		case yellow
		/// Informational
		case green
	}	
	
	/// Airport advisory properties
	public struct AirportProperties: AdvisoryProperties, HasOptionalURL, HasOptionalDescription, HasOptionalPhoneNumber {
		public let identifier: String?
		public let phone: String?
		public let tower: Bool?
		public let use: String?
		public let longestRunway: Meters?
		public let instrumentProcedure: Bool?
		public let url: URL?
		public let description: String?
		public let icao: String?
	}
	
	/// AMA field properties
	public struct AMAFieldProperties: AdvisoryProperties, HasOptionalURL {
		public let url: URL?
		public let siteLocation: String?
		public let contactName: String?
		public let contactPhone: String?
		public let contactEmail: String?
	}
	
	/// Heliport advisory properties
	public struct HeliportProperties: AdvisoryProperties, HasOptionalPhoneNumber {
		public let identifier: String?
		public let paved: Bool?
		public let phone: String?
		public let tower: Bool?
		public let use: String?
		public let instrumentProcedure: Bool?
		public let icao: String?
	}
	
	/// Controlled Airspace advisory properties
	public struct ControlledAirspaceProperties: AdvisoryProperties, HasOptionalURL, HasAuthorization {
		public let type: String?
		public let isLaancProvider: Bool?
		public let supportsAuthorization: Bool?
		public let url: URL?
		public let icao: String?
		public let airportID: String?
		public let airportName: String?
		public let ceiling: Double?
		public let floor: Double?
	}
	
	/// City properties
	public struct CityProperties: AdvisoryProperties, HasOptionalURL, HasOptionalDescription {
		public let url: URL?
		public let description: String?
	}
	
	/// Custom airspace properties
	public struct CustomProperties: AdvisoryProperties, HasOptionalURL, HasOptionalDescription {
		public let url: URL?
		public let description: String?
	}
	
	/// Emergency advisory properties
	public struct EmergencyProperties: AdvisoryProperties {
		public let effective: Date?
		public let type: String?
	}
	
	/// Fire advisory properties
	public struct FireProperties: AdvisoryProperties {
		public let effective: Date?
	}
	
	/// NOTAM advisory properties
	public struct NOTAMProperties: AdvisoryProperties {
		public let body: String?
		public let startTime: Date?
		public let endTime: Date?
		public let type: String?
	}

	/// Notification advisory properties
	public struct NotificationProperties: AdvisoryProperties, HasOptionalURL {
		public let body: String?
		public let url: URL?
	}

	/// Park advisory properties
	public struct ParkProperties: AdvisoryProperties, HasOptionalURL {
		public let type: String?
		public let url: URL?
	}
	
	/// Power Plant advisory properties
	public struct PowerPlantProperties: AdvisoryProperties {
		public let technology: String?
		public let generatorType: String?
		public let output: Int?
	}
	
	/// School advisory properties
	public struct SchoolProperties: AdvisoryProperties {
		public let numberOfStudents: Int?
	}
	
	/// Special Use advisory properties
	public struct SpecialUseProperties: AdvisoryProperties {
		public let description: String?
	}
	
	/// TFR advisory properties
	public struct TFRProperties: AdvisoryProperties, HasOptionalURL {
		public let url: URL?
		public let body: String?
		public let startTime: Date?
		public let endTime: Date?
		public let type: String?
		public let sport: String?
		public let venue: String?
	}
	
	/// University properties
	public struct UniversityProperties: AdvisoryProperties, HasOptionalURL, HasOptionalDescription {
		public let url: URL?
		public let description: String?
	}
	
	/// Wildfire advisory properties
	public struct WildfireProperties: AdvisoryProperties {
		public let effective: Date?
		public let size: Hectares?
	}


	/// A time sheet to describe when the airspace is active
	public struct Timesheet {
		public let active: Bool?
		public let timesheetData: Data?

		public struct Data {
			public let offsetUTC: Int?
			public let excluded: Bool?
			public let daylightSavingAdjust: Bool?
			public let day: DayDescriptor?
			public let dayTil: DayDescriptor?
			public let start: DataMarker?
			public let end: DataMarker?
		}

		public struct DayDescriptor {
			public let name: String
			public let day: Day
		}

		public struct EventDescriptor {
			public let name: String
			public let event: Event
		}

		public struct DataMarker {
			public let event: EventDescriptor?
			public let eventInterpretation: EventInterpretationDescriptor?
			public let eventOffset: Int?
			public let time: Timesheet.Time?
			public let date: Timesheet.Date?
		}

		public struct Time {
			public let hour: Int
			public let minute: Int
		}

		public struct Date {
			public let month: Int
			public let day: Int
		}

		public enum Day: String, CaseIterable {
			case monday = "day_monday"
			case tuesday = "day_tuesday"
			case wednesday = "day_wednesday"
			case thursday = "day_thursday"
			case friday = "day_friday"
			case saturday = "day_saturday"
			case sunday = "day_sunday"
			case workDay = "day_work_day"
			case beforeWorkDay = "day_before_work_day"
			case afterWorkDay = "day_after_work_day"
			case holiday = "day_holiday"
			case beforeHoliday = "day_before_holiday"
			case afterHoliday = "day_after_holiday"
			case busyFriday = "day_busy_friday"
			case any = "day_any"
		}

		public enum Event: String, CaseIterable {
			case sunrise = "event_sunrise"
			case sunset = "event_sunset"
		}

		public enum EventInterpretationDescriptor: String {
			case earliest = "event_interpretation_earliest"
			case latest = "event_interpretation_latest"
		}
	}
}

public protocol AdvisoryProperties {}

public protocol HasOptionalURL {
	var url: URL? { get }
}

public protocol HasOptionalPhoneNumber {
	var phone: String? { get }
}

public protocol HasOptionalDescription {
	var description: String? { get }
}

public protocol HasOptionalTimeRange {
	var startTime: Date? { get }
	var endTime: Date? { get }
}

public protocol HasAuthorization {
	var isLaancProvider: Bool?  { get }
	var supportsAuthorization: Bool?  { get }
	var floor: Double? { get }
	var ceiling: Double? { get }
}


// MARK: - CustomStringConvertible

extension AirMapAdvisory.Color: CustomStringConvertible {
	
	public var description: String {
		
		let localized = LocalizedStrings.Status.self
		
		switch self {
		case .red:     return localized.redDescription
		case .orange:  return localized.orangeDescription
		case .yellow:  return localized.yellowDescription
		case .green:   return localized.greenDescription
		}
	}
}
