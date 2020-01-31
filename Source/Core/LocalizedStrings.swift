//
//  LocalizedStrings.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 2/27/17.
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

public struct LocalizedStrings {
	
	private static let bundle = AirMapBundle.core
	
	public struct Status {
		
		public static let redDescription = NSLocalizedString("STATUS_RED_DESCRIPTION", bundle: bundle, value: "Flight Strictly Regulated", comment: "Description for status advisory color Red")
		
		public static let orangeDescription = NSLocalizedString("STATUS_ORANGE_DESCRIPTION", bundle: bundle, value: "Action Required", comment: "Description for status advisory color Orange")
		
		public static let yellowDescription = NSLocalizedString("STATUS_YELLOW_DESCRIPTION", bundle: bundle, value: "Advisories", comment: "Description for status advisory color Yellow")
		
		public static let greenDescription = NSLocalizedString("STATUS_GREEN_DESCRIPTION", bundle: bundle, value: "Informational", comment: "Description for status advisory color Green")
	}
	
	public struct Authorization {
		
		public static let accepted = NSLocalizedString("AUTHORIZATION_ACCEPTED", bundle: bundle, value: "Approved", comment: "The request with the authority has been accepted")
		
		public static let authorizedUponSubmission = NSLocalizedString("AUTHORIZATION_UPON_SUBMISSION", bundle: bundle, value: "Authorization Pending Submission", comment: "The request with the authority will be accepted once the flight plan is submitted")
		
		public static let notRequested = NSLocalizedString("AUTHORIZATION_NOT_REQUESTED", bundle: bundle, value: "Authorization Not Requested", comment: "The request with the authority has not been requested")
		
		public static let manualAuthorization = NSLocalizedString("MANUAL_AUTHORIZATION", bundle: bundle, value: "Manual Authorization Pending Submission", comment: "The request with the authority will be reviewed manually sometime after the flight plan is submitted")
		
		public static let pending = NSLocalizedString("AUTHORIZATION_PENDING", bundle: bundle, value: "Authorization Pending", comment: "The request with the authority has been made and a response is pending")
		
		public static let rejected = NSLocalizedString("AUTHORIZATION_REJECTED", bundle: bundle, value: "Authorization Rejected", comment: "The request with the authority has been rejected")
		
		public static let rejectedUponSubmission = NSLocalizedString("AUTHORIZATION_REJECTED_UPON_SUBMISSION", bundle: bundle, value: "Rejected Upon Submission", comment: "The request with the authority will be rejected once the flight plan is submitted")
		
		public static let cancelled = NSLocalizedString("AUTHORIZATION_CANCELLED_SUBMISSION", bundle: bundle, value: "Authorization Invalidated", comment: "The request with the authority has been invalidated")
	}
	
	public struct Validation {
		
		public static let accepted = NSLocalizedString("VALIDATION_ACCEPTED", bundle: bundle, value: "Validated", comment: "The request with the authority has been accepted")
		
		public static let notRequested = NSLocalizedString("VALIDATION_NOT_REQUESTED", bundle: bundle, value: "Validation Not Requested", comment: "No validation request has been filed")
		
		public static let pending = NSLocalizedString("VALIDATION_PENDING", bundle: bundle, value: "Validation Pending", comment: "The request with the authority has been made and a response is pending")
		
		public static let rejected = NSLocalizedString("VALIDATION_REJECTED", bundle: bundle, value: "Rejected Missing Info", comment: "The request with the authority has been rejected")
		
	}
	
	public struct AirspaceType {
		
		public static let airport = NSLocalizedString("AIRSPACE_TYPE_AIRPORT", bundle: bundle, value: "Airport", comment: "Name for airspace type Airport")
		
		public static let amaField = NSLocalizedString("AIRSPACE_TYPE_AMA_FIELD", bundle: bundle, value: "AMA Field", comment: "Name for airspace type AMA Field (Academy of Model Aeronautics)")
		
		public static let city = NSLocalizedString("AIRSPACE_TYPE_CITY", bundle: bundle, value: "City", comment: "Name for airspace type City")
		
		public static let controlledAirspace = NSLocalizedString("AIRSPACE_TYPE_CONTROLLED", bundle: bundle, value: "Controlled Airspace", comment: "Name for airspace type Controlled Airspace")
		
		public static let country = NSLocalizedString("AIRSPACE_TYPE_COUNTRY", bundle: bundle, value: "Country", comment: "Name for airspace type Country")
		
		public static let county = NSLocalizedString("AIRSPACE_TYPE_COUNTY", bundle: bundle, value: "County", comment: "Name for airspace type County")
		
		public static let custom = NSLocalizedString("AIRSPACE_TYPE_CUSTOM", bundle: bundle, value: "Custom", comment: "Name for airspace type Custom")
		
		public static let embassy = NSLocalizedString("AIRSPACE_TYPE_EMBASSY", bundle: bundle, value: "Embassy", comment: "Name for airspace type Embassy")
		
		public static let federalBuilding = NSLocalizedString("AIRSPACE_TYPE_FEDERAL_BUILDING", bundle: bundle, value: "Federal Building", comment: "Name for airspace type Federal Building")
		
		public static let fir = NSLocalizedString("AIRSPACE_TYPE_FIR", bundle: bundle, value: "Flight Information Region", comment: "Name for airspace type Flight Information Region")
		
		public static let gliderport = NSLocalizedString("AIRSPACE_TYPE_GLIDERPORT", bundle: bundle, value: "Gliderport", comment: "Name for airspace type Gliderport")
		
		public static let hazardArea = NSLocalizedString("AIRSPACE_TYPE_HAZARD_AREA", bundle: bundle, value: "Hazard Area", comment: "Name for airspace type Hazard Area")
		
		public static let heliport = NSLocalizedString("AIRSPACE_TYPE_HELIPORT", bundle: bundle, value: "Heliport", comment: "Name for airspace type Heliport")
		
		public static let highway = NSLocalizedString("AIRSPACE_TYPE_HIGHWAY", bundle: bundle, value: "Highway", comment: "Name for airspace type Highway")
		
		public static let hospital = NSLocalizedString("AIRSPACE_TYPE_HOSPITAL", bundle: bundle, value: "Hospital", comment: "Name for airspace type Hospital")
		
		public static let industrialProperty = NSLocalizedString("AIRSPACE_TYPE_INDUSTRIAL_PROPERTY", bundle: bundle, value: "Industrial Property", comment: "Name for airspace type Industrial Property")
		
		public static let japanBase = NSLocalizedString("AIRSPACE_TYPE_JAPAN_BASE", bundle: bundle, value: "Japan Base Admin", comment: "Name for airspace type Japan Base Admin (Smallest unit of Japanse administrative units)")
				
		public static let militaryProperty = NSLocalizedString("AIRSPACE_TYPE_MILITARY_PROPERTY", bundle: bundle, value: "Military Property", comment: "Name for airspace type Military Property")
		
		public static let notam = NSLocalizedString("AIRSPACE_TYPE_NOTAM", bundle: bundle, value: "NOTAM", comment: "Name for airspace type NOTAM")
		
		public static let notification = NSLocalizedString("AIRSPACE_TYPE_NOTIFICATION", bundle: bundle, value: "Notification", comment: "Name for airspace type Notification")

		public static let obstacle = NSLocalizedString("AIRSPACE_TYPE_OBSTACLE", bundle: bundle, value: "Obstacle", comment: "Name for airspace type Obstacle")

		public static let park = NSLocalizedString("AIRSPACE_TYPE_NATIONAL_PARK", bundle: bundle, value: "National Park", comment: "Name for airspace type National Park")
		
		public static let policeStation = NSLocalizedString("AIRSPACE_TYPE_POLICE_STATION", bundle: bundle, value: "Police Station", comment: "Name for airspace type Police Station")
		
		public static let powerline = NSLocalizedString("AIRSPACE_TYPE_POWERLINE", bundle: bundle, value: "Powerline", comment: "Name for airspace type Powerline")
		
		public static let powerPlant = NSLocalizedString("AIRSPACE_TYPE_POWER_PLANT", bundle: bundle, value: "Power Plant", comment: "Name for airspace type Power Plant")
		
		public static let prison = NSLocalizedString("AIRSPACE_TYPE_PRISON", bundle: bundle, value: "Prison", comment: "Name for airspace type Prison")
		
		public static let railway = NSLocalizedString("AIRSPACE_TYPE_RAILWAY", bundle: bundle, value: "Railway", comment: "Name for airspace type Railway")
		
		public static let recreationalArea = NSLocalizedString("AIRSPACE_TYPE_AERIAL_REC_AREA", bundle: bundle, value: "Aerial Recreational Area", comment: "Name for airspace type Aerial Recreational Area")
		
		public static let residentialProperty = NSLocalizedString("AIRSPACE_TYPE_RESIDENTIAL_PROPERTY", bundle: bundle, value: "Residential Property", comment: "Name for airspace type Residential Property")
		
		public static let school = NSLocalizedString("AIRSPACE_TYPE_SCHOOL", bundle: bundle, value: "School", comment: "Name for airspace type School")
		
		public static let seaplaneBase = NSLocalizedString("AIRSPACE_TYPE_SEAPLANE_BASE", bundle: bundle, value: "Seaplane Base", comment: "Name for airspace type Seaplane Base")
		
		public static let specialUse = NSLocalizedString("AIRSPACE_TYPE_SPECIAL_USE", bundle: bundle, value: "Special Use Airspace", comment: "Name for airspace type Special Use Airspace")
		
		public static let stadium = NSLocalizedString("AIRSPACE_TYPE_STADIUM", bundle: bundle, value: "Stadium", comment: "Name for airspace type Stadium")
		
		public static let subprefecture = NSLocalizedString("AIRSPACE_TYPE_SUBPREFECTURE", bundle: bundle, value: "Subprefecture", comment: "Name for airspace type Subprefecture")
		
		public static let supercity = NSLocalizedString("AIRSPACE_TYPE_SUPERCITY", bundle: bundle, value: "Supercity", comment: "Name for airspace type Supercity (Japan related)")
		
		public static let state = NSLocalizedString("AIRSPACE_TYPE_STATE", bundle: bundle, value: "State", comment: "Name for airspace type State")
		
		public static let tfr = NSLocalizedString("AIRSPACE_TYPE_TFR_FAA", bundle: bundle, value: "Temporary Flight Restriction", comment: "Name for airspace type FAA Temporary Flight Restriction")
		
		public static let ultralightField = NSLocalizedString("AIRSPACE_TYPE_ULM_FIELD", bundle: bundle, value: "Ultralight Field", comment: "Name for airspace type Ultralight Field")
		
		public static let unclassified = NSLocalizedString("AIRSPACE_TYPE_UNCLASSIFIED", bundle: bundle, value: "Unclassified", comment: "Generic catchall placeholder/name for airspace type is new and unknown at time of development but present via the advisories or map sources")
		
		public static let university = NSLocalizedString("AIRSPACE_TYPE_UNIVERSITY", bundle: bundle, value: "University", comment: "Name for airspace type University")
		
		public static let waterway = NSLocalizedString("AIRSPACE_TYPE_WATERWAY", bundle: bundle, value: "Waterway", comment: "Name for airspace type Waterway")
		
		public static let wildfire = NSLocalizedString("AIRSPACE_TYPE_WILDFIRE", bundle: bundle, value: "WildFire", comment: "Name for airspace type WildFire")
		
		public static let fire = NSLocalizedString("AIRSPACE_TYPE_FIRE", bundle: bundle, value: "Fire", comment: "Name for airspace type Fire")
		
		public static let emergency = NSLocalizedString("AIRSPACE_TYPE_EMERGENCY", bundle: bundle, value: "First Responder Activity", comment: "Name for airspace type Emergency")
		
	}
	
	public struct Auth {
		
		public static let unauthorized = NSLocalizedString("AUTH_ERROR_UNAUTHORIZED", bundle: bundle, value: "Unauthorized", comment: "Login message when a user failed to authenticate")
		
		public static let emailVerificationRequired = NSLocalizedString("AUTH_ERROR_EMAIL_NEEDS_VERIFICATION_REQUIRED", bundle: bundle, value: "Your email address needs to be verified. Please check your inbox.", comment: "Login message when a user must verify their email address")
		
		public static let domainBlacklisted = NSLocalizedString("AUTH_ERROR_ACCOUNT_BLACKLISTED", bundle: bundle, value: "Your account has been blacklisted. Please contact security@airmap.com", comment: "Login message when a user's account has been blacklisted.")
		
		public static let failedLoginTitle = NSLocalizedString("AUTH_FAILED_LOGIN_TITLE", bundle: bundle, value: "Alert", comment: "Navigation title for failed login attempt")
	}
	
	public struct Advisory {
		
		public static let phoneNumberNotProvided = NSLocalizedString("ADVISORY_PHONE_NOT_PROVIDED", bundle: bundle, value: "No Phone Number Provided", comment: "Displayed when an advisory has not provided a contact phone")
		
		public static let tfrStartsFormat = NSLocalizedString("ADVISORY_TFR_STARTS_FORMAT", bundle: bundle, value: "Starts: %1$@", comment: "Label and format for displaying the start time of temporary flight restriction")
		
		public static let tfrEndsFormat = NSLocalizedString("ADVISORY_TFR_ENDS_FORMAT", bundle: bundle, value: "Ends: %1$@", comment: "Label and format for displaying the end time of temporary flight restriction")
		
		public static let tfrPermanent = NSLocalizedString("ADVISORY_TFR_PERMANENT", bundle: bundle, value: "Permanent", comment: "Never ending duration for a TFR")
		
		public static let wildfireSizeFormatAcres = NSLocalizedString("ADVISORY_WILDFIRE_SIZE_FORMAT_ACRES", bundle: bundle, value: "%1$@ Acres", comment: "Format and unit for wildfire advisory in the area unit acres")
		
		public static let wildfireSizeFormatHectares = NSLocalizedString("ADVISORY_WILDFIRE_SIZE_FORMAT_HECTARES", bundle: bundle, value: "%1$@ Hectares", comment: "Format and unit for wildfire advisory in the area unit hectares")
		
		public static let wildfireSizeUnknown = NSLocalizedString("ADVISORY_WILDFIRE_SIZE_UNKNOWN", bundle: bundle, value: "Size Unknown", comment: "Label for wildfire advisory cells where size is unknown")
		
		public static let acceptsDigitalNotice = NSLocalizedString("ADVISORY_ACCEPTS_DIGITAL_NOTICE", bundle: bundle, value: "Accepts Digital Notice", comment: "Label for advisories that are stup to receive digital notice")
	}
	
	public struct FlightDrawing {
		
		public static let width = NSLocalizedString("FLIGHT_DRAWING_WIDTH", bundle: bundle, value: "Width", comment: "The width of a path-based flight extending outward from the centerline")
		
		public static let radius = NSLocalizedString("FLIGHT_DRAWING_RADIUS", bundle: bundle, value: "Radius", comment: "The radius around a point-based flight's center")
		
		public static let tooltipErrorOverlappingPermitAreas = NSLocalizedString("FLIGHT_DRAWING_TOOLTIP_ERROR_OVERLAPPING_PERMIT_AREAS", bundle: bundle, value: "Flight area cannot overlap with conflicting permit requirement zones.", comment: "Displayed when the user has drawn an invalid shaping, overlapping with conflicting permitted zones")
		
		public static let tooltipErrorSelfIntersectingGeometry = NSLocalizedString("FLIGHT_DRAWING_TOOLTIP_ERROR_SELF_INTERSECTING_GEOMETRY", bundle: bundle, value: "Invalid flight area. Adjust flight area so that it does not overlap with itself.", comment: "Call to action to fix self-intersecting geometries of an area-based flight.")
		
		public static let toolTipCtaDrawFreehandPath = NSLocalizedString("FLIGHT_DRAWING_TOOLTIP_CTA_DRAW_FREEHAND_PATH", bundle: bundle, value: "Draw a flight path", comment: "Call to action to draw a path-based flight.")
		
		public static let toolTipCtaDrawFreehandArea = NSLocalizedString("FLIGHT_DRAWING_TOOLTIP_CTA_DRAW_FREEHAND_AREA", bundle: bundle, value: "Draw a flight area", comment: "Call to action to draw an area-based flight.")
		
		public static let toolTipCtaTapToDrawPath = NSLocalizedString("FLIGHT_DRAWING_TOOLTIP_CTA_TAP_ICON_TO_DRAW_PATH", bundle: bundle, value: "Tap the hand icon to draw a flight path.", comment: "Call to action to tap the icon to begin drawing a flight path.")
		
		public static let toolTipCtaDragPointToModifyGeometry = NSLocalizedString("FLIGHT_DRAWING_TOOLTIP_CTA_DRAG_TO_MODIFY_GEOMETRY", bundle: bundle, value: "Drag any point to move. Drag any midpoint to add a new point.", comment: "Call to action to fine-tune the geometry of a flight.")
		
		public static let toolTipCtaTapToDrawArea = NSLocalizedString("FLIGHT_DRAWING_TOOLTIP_CTA_TAP_ICON_TO_DRAW_AREA", bundle: bundle, value: "Tap the hand icon to draw a flight area.", comment: "Call to action to tap the icon to begin drawing a flight area.")
		
		public static let toolTipCtaTapToDrawPoint = NSLocalizedString("FLIGHT_DRAWING_TOOLTIP_CTA_POSTIION_POINT", bundle: bundle, value: "Drag the center point to position your flight area.", comment: "Call to action to drag the center position of a point-based flight.")
		
		public static let toolTipCtaDragToTrashToDelete = NSLocalizedString("FLIGHT_DRAWING_TOOLTIP_CTA_DRAG_TO_TRASH_TO_DELETE", bundle: bundle, value: "Drag point to trash to delete", comment: "Call to action to drag a point to the trash to delete.")
	}
	
	public struct FlightPlan {
		
		public static let sectionHeaderFlight = NSLocalizedString("FLIGHT_PLAN_SECTION_HEADER_FLIGHT", bundle: bundle, value: "Flight", comment: "Title for the section displaying flight plan details")
		
		public static let sectionHeaderAssociated = NSLocalizedString("FLIGHT_PLAN_SECTION_HEADER_ASSOCIATED", bundle: bundle, value: "Pilot & Aircraft", comment: "Title for the section displaying the pilot and aircraft details")
		
		public static let sectionHeaderSocial = NSLocalizedString("FLIGHT_PLAN_SECTION_HEADER_SHARE", bundle: bundle, value: "Share My Flight", comment: "Title for the section displaying social sharing features")
		
		public static let rowTitleMaxAltitudeAGL = NSLocalizedString("FLIGHT_PLAN_ROW_TITLE_MAX_ALTITUDE", bundle: bundle, value: "Max Altitude AGL", comment: "Title for the row displaying flight plan max altitude AGL (above ground level)")
		
		public static let rowTitleRadius = NSLocalizedString("FLIGHT_PLAN_ROW_TITLE_RADIUS", bundle: bundle, value: "Radius", comment: "Title for the row displaying flight plan radius")
		
		public static let rowTitleBuffer = NSLocalizedString("FLIGHT_PLAN_ROW_TITLE_BUFFER", bundle: bundle, value: "Buffer", comment: "Title for the row displaying flight plan buffer")
		
		public static let rowTitleStartTime = NSLocalizedString("FLIGHT_PLAN_ROW_TITLE_START_TIME", bundle: bundle, value: "Starts", comment: "Title for the row displaying flight plan start time")
		
		public static let rowTitleDuration = NSLocalizedString("FLIGHT_PLAN_ROW_TITLE_DURATION", bundle: bundle, value: "Duration", comment: "Title for the row displaying flight plan duration")
		
		public static let rowTitlePilot = NSLocalizedString("FLIGHT_PLAN_ROW_TITLE_PILOT", bundle: bundle, value: "Select Pilot Profile", comment: "Call to action title for the user to select a pilot profile")
		
		public static let rowTitleAircraftName = NSLocalizedString("FLIGHT_PLAN_ROW_TITLE_AIRCRAFT_NAME", bundle: bundle, value: "Aircraft", comment: "Title for the row displaying the name of the aircraft")
		
		public static let rowTitleAircraft = NSLocalizedString("FLIGHT_PLAN_ROW_TITLE_AIRCRAFT", bundle: bundle, value: "Select Aircraft", comment: "Call to action title for the user to select an aircraft")
		
		public static let buttonTitleNext = NSLocalizedString("FLIGHT_PLAN_BUTTON_TITLE_NEXT", bundle: bundle, value: "Next", comment: "Title for the button to advance to the next screen")
		
		public static let buttonTitleSave = NSLocalizedString("FLIGHT_PLAN_BUTTON_TITLE_SAVE", bundle: bundle, value: "Save", comment: "Title for the button to save and create the flight")
	}
	
	public struct ReviewFlightPlanNotices {
		
		public static let headerNoNotices = NSLocalizedString("REVIEW_FLIGHT_PLAN_NOTICES_TAB_SECTION_HEADER_NO_NOTICES", bundle: bundle, value: "There are no notices for this flight.", comment: "Displayed in the flight plan review notices tab when there are no notices to display")
		
		public static let acceptsDigitalNotice = NSLocalizedString("REVIEW_FLIGHT_PLAN_NOTICES_TAB_ACCEPTS_NOTICE", bundle: bundle, value: "Accepts Digital Notice", comment: "Displayed for authorities that are setup to receive digital notice")
		
		public static let doesNotacceptsDigitalNotice = NSLocalizedString("REVIEW_FLIGHT_PLAN_NOTICES_TAB_DOES_NOT_ACCEPT_NOTICE", bundle: bundle, value: "The following authorities in this area do not accept digital notice", comment: "Displayed for authorities that are NOT setup to receive digital notice")
	}
	
	public struct Ruleset {
		
		public static let selectionTypeOptional = NSLocalizedString("RULESET_SELECTION_TYPE_OPTIONAL", bundle: bundle, value: "Optional", comment: "Label for rulesets that can be optionally enabled by the user")
		
		public static let selectionTypeRequired = NSLocalizedString("RULESET_SELECTION_TYPE_REQUIRED", bundle: bundle, value: "Required", comment: "Label for rulesets that must be enabled by the user")
		
		public static let selectionTypePickOne = NSLocalizedString("RULESET_SELECTION_TYPE_PICKONE", bundle: bundle, value: "Pick One", comment: "Label for rulesets that are part of a group in which one and only one ruleset can be enabled by the user")
	}
	
	public struct PilotProfile {
		
		public static let fullNameFormat = NSLocalizedString("PILOT_FULL_NAME_FORMAT", bundle: bundle, value: "%1$@ %2$@", comment: "Format for displaying the given + family name of a user. 1) given name 2) family name")

		public static let faaRegistrationLabel = NSLocalizedString("PILOT_PROFILE_FAA_REGISTRATION", bundle: bundle, value: "FAA Registration Number", comment: "Table row label for FAA registration number")
		
		public static let firstNameLabel = NSLocalizedString("PILOT_PROFILE_LABEL_FIRST_NAME", bundle: bundle, value: "First Name", comment: "Label for the pilot profile first name")
		
		public static let lastNameLabel = NSLocalizedString("PILOT_PROFILE_LABEL_LAST_NAME", bundle: bundle, value: "Last Name", comment: "Label for the pilot profile last name")
		
		public static let usernameLabel = NSLocalizedString("PILOT_PROFILE_LABEL_USERNAME", bundle: bundle, value: "Username", comment: "Label for the pilot profile username")
		
		public static let emailLabel = NSLocalizedString("PILOT_PROFILE_LABEL_EMAIL", bundle: bundle, value: "Email", comment: "Label for the pilot profile email")
		
		public static let phoneLabel = NSLocalizedString("PILOT_PROFILE_LABEL_PHONE", bundle: bundle, value: "Phone", comment: "Label for the pilot profile phone")
		
		public static let sectionHeaderPersonal = NSLocalizedString("PILOT_PROFILE_SECTION_PERSONAL", bundle: bundle, value: "Personal Info", comment: "Section header for the pilot profile personal info section")
		
		public static let sectionHeaderAdditional = NSLocalizedString("PILOT_PROFILE_SECTION_ADDITIONAL", bundle: bundle, value: "Additional Info", comment: "Section header for the pilot profile additional info section")
		
		public static let statisticsFormat = NSLocalizedString("PILOT_PROFILE_STATISTICS_FORMAT", bundle: bundle, value: "%@ Aircraft, %@ Flights", comment: "Format for displaying a user's number of aircraft and flights")
	}
	
	public struct PhoneVerification {
		
		public static let verificationFailed = NSLocalizedString("PHONE_VERIFICATION_VERIFICATION_FAILED", bundle: bundle, value: "Phone Number Verification Failed", comment: "Message presented to a user when the SMS code they input is incorrect and verification of that code has failed")
		
		public static let tryAgain = NSLocalizedString("PHONE_VERIFICATION_TRY_AGAIN", bundle: bundle, value: "Try Again", comment: "Message that is presented after a phone verification has failed, encouraging the user to try again")
		
		public static let requestNewSMSCode = NSLocalizedString("PHONE_VERIFICATION_REQUEST_NEW_SMS_CODE", bundle: bundle, value: "Request New SMS Code", comment: "Message that is presented after a phone verification has failed, encouraging the user to send a new code to the phone number provided")
		
	}
	
	public struct PhoneCountry {
		
		public static let selectedCountry = NSLocalizedString("PHONE_COUNTRY_SECTION_SELECTED_COUNTRY", bundle: bundle, value: "Selected Country", comment: "Table section title for the currently selected country")
		
		public static let otherCountry = NSLocalizedString("PHONE_COUNTRY_SECTION_OTHER_COUNTRY", bundle: bundle, value: "Other", comment: "Table section title for other selectable countries")
	}
	
	public struct Aircraft {
		
		public static let titleCreate = NSLocalizedString("AIRCRAFT_TITLE_CREATE_NEW", bundle: bundle, value: "Create Aircraft", comment: "Title to display for the view creating a new aircraft")
		
		public static let titleUpdate = NSLocalizedString("AIRCRAFT_TITLE_UPDATE_EXISTING", bundle: bundle, value: "Update Aircraft", comment: "Title to display for the view when updating an existing aircraft")
		
		public static let selectAircraft = NSLocalizedString("AIRCRAFT_SELECT_AIRCRAFT", bundle: bundle, value: "Select Aircraft", comment: "Call to action when a user has not selected an aircraft")
	}
	
	public struct CardinalDirection {
		
		public static let N   = NSLocalizedString("CARDINAL_DIRECTION_N",    bundle: bundle, value: "N",   comment: "Abbreviation for North")
		
		public static let NNE = NSLocalizedString("CARDINAL_DIRECTION_NNNE", bundle: bundle, value: "NNE", comment: "Abbreviation for North North East")
		
		public static let NE  = NSLocalizedString("CARDINAL_DIRECTION_NE",   bundle: bundle, value: "NE",  comment: "Abbreviation for North East")
		
		public static let ENE = NSLocalizedString("CARDINAL_DIRECTION_ENE",  bundle: bundle, value: "ENE", comment: "Abbreviation for East North East")
		
		public static let E   = NSLocalizedString("CARDINAL_DIRECTION_E",    bundle: bundle, value: "E",   comment: "Abbreviation for East")
		
		public static let ESE = NSLocalizedString("CARDINAL_DIRECTION_ESE",  bundle: bundle, value: "ESE", comment: "Abbreviation for East South East")
		
		public static let SE  = NSLocalizedString("CARDINAL_DIRECTION_SE",   bundle: bundle, value: "SE",  comment: "Abbreviation for South East")
		
		public static let SSE = NSLocalizedString("CARDINAL_DIRECTION_SSE",  bundle: bundle, value: "SSE", comment: "Abbreviation for South South East")
		
		public static let S   = NSLocalizedString("CARDINAL_DIRECTION_S",    bundle: bundle, value: "S",   comment: "Abbreviation for South")
		
		public static let SSW = NSLocalizedString("CARDINAL_DIRECTION_SSW",  bundle: bundle, value: "SSW", comment: "Abbreviation for South South West")
		
		public static let SW  = NSLocalizedString("CARDINAL_DIRECTION_SW",   bundle: bundle, value: "SW",  comment: "Abbreviation for South West")
		
		public static let WSW = NSLocalizedString("CARDINAL_DIRECTION_WSW",  bundle: bundle, value: "WSW", comment: "Abbreviation for West South West")
		
		public static let W   = NSLocalizedString("CARDINAL_DIRECTION_W",    bundle: bundle, value: "W",   comment: "Abbreviation for West")
		
		public static let WNW = NSLocalizedString("CARDINAL_DIRECTION_WNW",  bundle: bundle, value: "WNW", comment: "Abbreviation for West North West")
		
		public static let NW  = NSLocalizedString("CARDINAL_DIRECTION_NW",   bundle: bundle, value: "NW",  comment: "Abbreviation for North West")
		
		public static let NNW = NSLocalizedString("CARDINAL_DIRECTION_NNW",  bundle: bundle, value: "NNW", comment: "Abbreviation for North North West")
	}
	
	public struct Units {
		
		public static let metric = NSLocalizedString("UNITS_METRIC", bundle: bundle, value: "Metric", comment: "Name for the metric system of measurement")
		
		public static let imperial = NSLocalizedString("UNITS_IMPERIAL", bundle: bundle, value: "Imperial", comment: "Name for the imperial system of measurement")
		
		public static let nauticalMileFormat = NSLocalizedString("UNITS_NAUTICAL_MILE_FORMAT", bundle: bundle, value: "%@ NM", comment: "Unit and format for displaying nautical miles")
		
		public static let speedFormatMetersPerSecond = NSLocalizedString("UNITS_SPEED_FORMAT_METERS_PER_SECOND", bundle: bundle, value: "%@ m/s", comment: "Unit and format for displaying speed in meters per second")
		
		public static let speedFormatMilesPerHour = NSLocalizedString("UNITS_SPEED_FORMAT_MILES_PER_HOUR", bundle: bundle, value: "%@ mph", comment: "Unit and format for displaying speed in miles per hour")
		
		public static let speedRangeFormatMetersPerSecond = NSLocalizedString("UNITS_SPEED_RANGE_FORMAT_METERS_PER_SECOND", bundle: bundle, value: "%@-%@ m/s", comment: "Unit and format for displaying a speed range in meters per second")
		
		public static let speedRangeFormatMilesPerHour = NSLocalizedString("UNITS_SPEED_RANGE_FORMAT_MILES_PER_HOUR", bundle: bundle, value: "%@-%@ mph", comment: "Unit and format for displaying a speed range in miles per hour")
		
		public static let speedFormatKnots = NSLocalizedString("UNITS_SPEED_FORMAT_KNOTS", bundle: bundle, value: "%@ kts", comment: "Unit and format for displaying speed in knots")
		
		public static let temperatureFormatCelcius = NSLocalizedString("UNITS_TEMPERATURE_CELCIUS_FORMAT", bundle: bundle, value: "%1$@°C", comment: "Unit and format for displaying temperature in Celcius")
		
		public static let temperatureFormatFahrenheit = NSLocalizedString("UNITS_TEMPERATURE_FAHRENHEIT_FORMAT", bundle: bundle, value: "%1$@°F", comment: "Unit and format for displaying temperature in Fahrenheit")
	}
	
	public struct Traffic {
		
		public static let alertWithAircraftIdFormat = NSLocalizedString("TRAFFIC_ALERT_WITH_AIRCRAFT_ID_FORMAT", bundle: bundle, value: "Traffic %1$@\nAltitude %2$@\n%3$@", comment: "Format for traffic alerts. 1) aircraft id, 2) altitude, 3) ground speed")
		
		public static let alertWithAircraftIdAndDistanceFormat = NSLocalizedString("TRAFFIC_ALERT_WITH_AIRCRAFT_ID_AND_DISTANCE_FORMAT", bundle: bundle, value: "Traffic %1$@\nAltitude %2$@\n%3$@ %4$@ %5$@", comment: "Format for traffic alerts. 1) aircraft id, 2) altitude, 3) distance, 4) direction, 5) time")
	}
	
	public struct Error {
		
		public static let cancelled = NSLocalizedString("ERROR_CANCELLED", bundle: bundle, value: "Request cancelled before it could be completed", comment: "Request cancelled error")

		public static let unauthorized = NSLocalizedString("ERROR_UNAUTHORIZED", bundle: bundle, value: "Unauthorized. Please check login credentials.", comment: "Authorization failure error")
		
		public static let conflict = NSLocalizedString("ERROR_CONFLICT", bundle: bundle, value: "A conflict exists", comment: "A conflict exists with the attempted request")

		public static let server = NSLocalizedString("ERROR_SERVER", bundle: bundle, value: "The server could not complete your request.", comment: "Server failure error")
		
		public static let serialization = NSLocalizedString("ERROR_SERIALIZATION", bundle: bundle, value: "The server returned an unprocessable response.", comment: "Response serialization failure error")
		
		public static let genericFormat = NSLocalizedString("ERROR_GENERIC_FORMAT", bundle: bundle, value: "The server returned an error. (%@)", comment: "A generic server error message with an associated error code")
	}
	
}
