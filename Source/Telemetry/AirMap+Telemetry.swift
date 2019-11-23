//
//  AirMap+Telemetry.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
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

import SwiftProtobuf
import CoreLocation

extension AirMap {

	// MARK: - Telemetry
	
	public enum TelemetryError: Error {
		case invalidCredentials
		case invalidFlight
	}

	/// Queries archived telemetry for a given flight
	///	  - Parameters:
	///   - flightId: The flight identifier the telemetry is associated with
	///   - from: Start time of temporal filter
	///   - to: End time of temporal filter
	///   - sampleRate: Temporal resolution of telemetry data. Default: 1 second.
	/// - Returns: A collection of telemetry reports for the given inputs
	public static func queryFlightTelemetry(for flightId: AirMapFlightId, from start: Date? = nil, to end: Date? = nil, sampleRate: SampleRate? = nil, completion: @escaping (Result<ArchivedTelemetry>) -> Void) {

		return rx.queryFlightTelemetry(for: flightId, from: start, to: end, sampleRate: sampleRate).thenSubscribe(completion)
	}

	/**
	
	Send aircraft position telemetry data to AirMap
	
	- parameter flight: The identifier for the `AirMapFlight` to report telemetry data for
	- parameter coordinate: The latitude & longitude of the aircraft
	- parameter altitudeAgl: The altitude of the aircraft in meters above ground
	- parameter altitudeMsl: The altitude of the aircraft in meters above Mean Sea Level
	- parameter horizontalAccuracy: Optional. The horizontal dilution of precision (HDOP)
	
	*/
	public static func sendTelemetryData(_ flightId: AirMapFlightId, coordinate: Coordinate2D, altitudeAgl: Float?, altitudeMsl: Float?, horizontalAccuracy: Float? = nil) throws {
		
		try canSendTelemetry()

		telemetryClient.sendTelemetry(flightId, message: Telemetry_Position.with { (position) in
			position.timestamp = Date().timeIntervalSince1970.milliseconds
			position.latitude = coordinate.latitude
			position.longitude = coordinate.longitude
			if let agl = altitudeAgl {
				position.altitudeAgl = agl
			}
			if let msl = altitudeMsl {
				position.altitudeMsl = msl
			}
			if let accuracy = horizontalAccuracy {
				position.horizontalAccuracy = accuracy
			}
		})
	}
	
	/**
	
	Send aircraft speed telemetry data to AirMap
	
	- parameter flightId: The identifier for the `AirMapFlight` to report telemetry data for
	- parameter velocity: A tuple of axis velocities (X,Y,Z) using the N-E-D (North-East-Down) coordinate system
	
	*/
	public static func sendTelemetryData(_ flightId: AirMapFlightId, velocity: (x: Float, y: Float, z: Float)) throws {
		
		try canSendTelemetry()

		telemetryClient.sendTelemetry(flightId, message: Telemetry_Speed.with { speed in
			speed.timestamp = Date().timeIntervalSince1970.milliseconds
			speed.velocityX = velocity.x
			speed.velocityY = velocity.y
			speed.velocityZ = velocity.z
		})
	}
	
	/**
	
	Send aircraft attitude telemetry data to AirMap
	
	- parameter flight: The identifier for the `AirMapFlight` to report telemetry data for
	- parameter yaw: The yaw angle in degrees measured from True North (0 <= x < 360)
	- parameter pitch: The angle (up-down tilt) in degrees up or down relative to the forward horizon (-180 < x <= 180)
	- parameter roll: The angle (left-right tilt) in degrees (-180 < x <= 180)
	
	*/
	public static func sendTelemetryData(_ flightId: AirMapFlightId, yaw: Float, pitch: Float, roll: Float) throws {
		
		try canSendTelemetry()

		telemetryClient.sendTelemetry(flightId, message: Telemetry_Attitude.with { attitude in
			attitude.timestamp = Date().timeIntervalSince1970.milliseconds
			attitude.yaw = yaw
			attitude.pitch = pitch
			attitude.roll = roll
		})
	}
	
	/**
	
	Send barometer telemetry data to AirMap
	
	- parameter flight: The identifier for the `AirMapFlight` to report telemetry data for
	- parameter baro: The barometric pressure in hPa (~1000)
	
	*/
	public static func sendTelemetryData(_ flightId: AirMapFlightId, baro: Float) throws {
		
		try canSendTelemetry()

		telemetryClient.sendTelemetry(flightId, message: Telemetry_Barometer.with { barometer in
			barometer.timestamp = Date().timeIntervalSince1970.milliseconds
			barometer.pressure = baro
		})
	}
	
	/**
	
	Verify the user can send telemetry data
	
	*/
	fileprivate static func canSendTelemetry() throws {
	
		guard AirMap.authService.isAuthorized else {
			logger.error("Failed to send telemetry data", metadata: ["error": .stringConvertible("unauthorized")])
			throw TelemetryError.invalidCredentials
		}
	}
	
}

