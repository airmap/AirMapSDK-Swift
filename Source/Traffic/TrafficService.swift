//
//  TrafficService.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/29/16.
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

import SwiftMQTT
import CoreLocation
import ObjectMapper
import RxSwift
import RxSwiftExt
import RxCocoa

internal class TrafficService: MQTTSessionDelegate {

	enum ConnectionState {
		case connecting
		case connected
		case disconnected
	}

	enum TrafficServiceError: Error {
		case invalidCredentials
		case connectionFailed
		case subscriptionFailed
	}

	internal weak var delegate: AirMapTrafficObserver?

	internal var authToken: String? {
		set { client.password = newValue }
		get { return client.password }
	}

	fileprivate var activeTraffic = [AirMapTraffic]()
	fileprivate var expirationInterval = Constants.Traffic.expirationInterval
	fileprivate var client = TrafficClient()
	fileprivate var connectionState = BehaviorRelay<ConnectionState>(value: .disconnected)
	fileprivate var currentFlight = BehaviorRelay<AirMapFlight?>(value: nil)
	fileprivate var receivedFlight = BehaviorRelay<AirMapFlight?>(value: nil)
	fileprivate var isActive = BehaviorRelay<Bool>(value: false)

	fileprivate let disposeBag = DisposeBag()

	// MARK: - Setup

	init() {
		client.delegate = self
		setupBindings()
		connect()
	}

	// MARK: - Instance Methods

	func setupBindings() {

		let activate = isActive.filter { $0 }.share()
		let deactivate = isActive.filter { !$0 }.share()

		let getFlight = activate
			.mapToVoid()

		let refreshCurrentFlightTimer = Observable<Int>
			.timer(.seconds(0), period: .seconds(15), scheduler: MainScheduler.instance)
			.mapToVoid()

		let refreshCurrentFlight = Observable.merge(
				refreshCurrentFlightTimer,
				getFlight
			)
			.filter {[unowned self] _ in self.canConnect()}
			.flatMap(AirMap.rx.getCurrentAuthenticatedPilotFlight)
			.retry(2)
			.catchError({ [unowned self] _ in
				self.connectionState.accept(.disconnected)
				return Observable.of(nil)
			})

		Observable.merge(refreshCurrentFlight, receivedFlight.asObservable())
			.bind(to: currentFlight)
			.disposed(by: disposeBag)

		let state = connectionState.asObservable()

		let flightWhileConnected = currentFlight.asObservable()
			.distinctUntilChanged { flight in flight?.id ?? "" }
			.filter {[unowned self] _ in self.connectionState.value == .connected }
			.do(onNext: { [unowned self] (_) in
				self.connectionState.accept(.disconnected)
				self.removeAllTraffic()
			})

		let flightWhileDisconnected = currentFlight.asObservable()
			.filter {[unowned self] _ in self.connectionState.value == .disconnected }

		let flight = Observable.merge(
				flightWhileConnected,
				flightWhileDisconnected
			)
			.share()

		let flightState = Observable.combineLatest(flight, state) { ($0, $1) }
			.share()

		let whenConnected = flightState.filter { $1 == .connected }
		let whenDisconnected = flightState.filter { $1 == .disconnected }

		whenDisconnected
			.retry()
			.throttle(.seconds(1), scheduler: MainScheduler.instance)
			.map { flight, state in flight }
			.unwrap()
			.filter {[unowned self] _ in self.canConnect()}
			.flatMap({ [unowned self] flight -> Observable<ConnectionState> in
				return self.connectWithFlight(flight)
					.catchError({ _ in return Observable.just(.disconnected) })
			})
			.bind(to: connectionState)
			.disposed(by: disposeBag)

		whenConnected
			.retry()
			.throttle(.seconds(1), scheduler: MainScheduler.instance)
			.filter {[unowned self] _ in self.canConnect()}
			.map { flight, state in flight }
			.unwrap()
			.flatMap({ [unowned self] flight -> Observable<Void> in
				return self.subscribeToTraffic(flight)
					.catchError({ [unowned self] _ in
						self.connectionState.accept(.disconnected)
						return .empty()
					})
			})
			.subscribe()
			.disposed(by: disposeBag)

		state
			.subscribe(onNext: { [unowned self] state in
				switch state {
				case .connecting:
					AirMap.logger.info("Traffic Service Connecting…")
				case .connected:
					AirMap.logger.info("Traffic Service Connected")
					self.delegate?.airMapTrafficServiceDidConnect?()
				case .disconnected:
					AirMap.logger.info("Traffic Service Disconnected")
					self.delegate?.airMapTrafficServiceDidDisconnect?()
				}
			})
			.disposed(by: disposeBag)

		let unsubscribe = unsubscribeFromAllChannels()
			.do(onDispose: { [unowned self] in
				self.client.disconnect()
				self.connectionState.accept(.disconnected)
			})
			.catchError({ [unowned self] _ in
				self.connectionState.accept(.disconnected)
				return Observable.empty()
			})

		deactivate
			.flatMap { (_) -> Observable<Void> in
				return unsubscribe
			}
			.subscribe()
			.disposed(by: disposeBag)

		let trafficProjectionTimer = Observable<Int>
			.interval(.milliseconds(250), scheduler: MainScheduler.asyncInstance).mapToVoid()

		trafficProjectionTimer
			.subscribe(onNext: { [weak self] _ in
				self?.updateTrafficProjections()
			})
			.disposed(by: disposeBag)

		let purgeTrafficTimer = Observable<Int>.interval(.seconds(5), scheduler: MainScheduler.asyncInstance).mapToVoid()

		purgeTrafficTimer
			.subscribe(onNext: { [weak self] _ in
				self?.purgeExpiredTraffic()
			})
			.disposed(by: disposeBag)
	}

	private func canConnect() -> Bool {
		if AirMap.authService.isAuthorized && self.delegate != nil && isActive.value {
			return true
		}

		return false
	}

	func connect() {
		isActive.accept(true)
	}

	func disconnect() {
		isActive.accept(false)
	}

	func startObservingTraffic(for flight: AirMapFlight) {
		receivedFlight.accept(flight)
	}

	// MARK: - Observable Methods

	func connectWithFlight(_ flight: AirMapFlight) -> Observable<ConnectionState> {

		return AirMap.authService.performWithCredentials()
			.flatMap { (creds) -> Observable<ConnectionState> in
				return Observable.create { (observer: AnyObserver<ConnectionState>) -> Disposable in

					observer.onNext(.connecting)

					self.client.username = flight.id?.rawValue
					self.client.password = creds.token

					self.client.connect { error in
						if error == .none {
							observer.onNext(.connected)
						} else {
							AirMap.logger.error("Failed to connect to traffic", metadata: [
								"flight": .stringConvertible(flight.id ?? ""),
								"error": .string(error.description)]
							)
							observer.onError(TrafficServiceError.connectionFailed)
							observer.onNext(.disconnected)
						}
					}

					return Disposables.create()
				}
		}
	}

	func subscribeToTraffic(_ flight: AirMapFlight) -> Observable<Void> {
		
		let sa    = self.subscribe(flight, to: Constants.Traffic.awarenessTopic + flight.id!.rawValue)
		let alert = self.subscribe(flight, to: Constants.Traffic.alertTopic + flight.id!.rawValue)

		return unsubscribeFromAllChannels().concat(sa).concat(alert)
	}

	func subscribe(_ flight: AirMapFlight, to channel: String) -> Observable<Void> {
		return Observable.create { (observer: AnyObserver<Void>) -> Disposable in
			self.client.subscribe(to: channel, delivering: .atLeastOnce) { error in
				if error == .none {
					self.client.currentChannels.append(channel)
					AirMap.logger.debug("Subscribed to traffic", metadata: [
						"flight": .stringConvertible(flight.id ?? ""),
						"channel": .string(channel)]
					)
					observer.onCompleted()
				} else {
					observer.onError(TrafficServiceError.subscriptionFailed)
				}
			}
			return Disposables.create()
		}
	}

	func unsubscribeFromAllChannels() -> Observable<Void> {
		return Observable.create { observer in
			let channels = self.client.currentChannels
			guard channels.count > 0 else {
				observer.onCompleted()
				return Disposables.create()
			}
			self.client.unSubscribe(from: channels) { error in
				if error == .none {
					AirMap.logger.debug("Unsubscribed from traffic", metadata: [
						"channels": .stringConvertible(channels)]
					)
				} else {
					AirMap.logger.debug("Failed to unsubscribe from traffic", metadata: ["error": .stringConvertible(error)])
					observer.onError(TrafficServiceError.subscriptionFailed)
				}
				self.client.currentChannels = []
				observer.onCompleted()
			}
			return Disposables.create()
		}
	}

	func startPurgingExpiredTraffic(_ flight: AirMapFlight) -> Observable<AirMapFlight> {
		return Observable.create { (observer: AnyObserver<AirMapFlight>) -> Disposable in
			observer.onCompleted()
			return Disposables.create()
		}
	}

	// MARK: - Private Instance Methods

	fileprivate func addTraffic(_ traffic: [AirMapTraffic]) {

		guard let currentFlight = currentFlight.value else {
			disconnect()
			return
		}

		var addedTraffic = traffic
		var updatedTraffic = [AirMapTraffic]()

		for added in addedTraffic {

			let existingTraffic = activeTraffic.filter(hasAircractIdMatching(added.properties.aircraftId))

			for existing in existingTraffic {

				// Update values using KVO-compliant mechanisms

				existing.setValuesForKeys([
					"id":              added.id as Any,
					"direction":       added.direction,
					"altitude":        added.altitude,
					"groundSpeed":     added.groundSpeed,
					"timestamp":       added.timestamp,
					"properties":      added.properties,
					"createdAt":       added.createdAt
					])
		
				if existing.initialCoordinate != added.initialCoordinate{

					if let heading = CLLocation(coordinate: existing.initialCoordinate)?.initialBearing(to: CLLocation(coordinate: added.coordinate)) {
						existing.willChangeValue(forKey: "trueHeading")
						existing.trueHeading = Int(heading)
						existing.didChangeValue(forKey: "trueHeading")
					}

					existing.willChangeValue(forKey: "initialCoordinate")
					existing.initialCoordinate = added.initialCoordinate
					existing.didChangeValue(forKey: "initialCoordinate")

					existing.willChangeValue(forKey: "recordedTime")
					existing.recordedTime = added.recordedTime
					existing.didChangeValue(forKey: "recordedTime")
				}

				existing.willChangeValue(forKey: "trafficType")

				if existing.trafficType == .alert {
					existing.trafficTypeDidChangeToAlert = false
				} else {
					existing.trafficType = added.trafficType
				}

				let addedLocation = CLLocation(latitude: added.coordinate.latitude, longitude: added.coordinate.longitude)
				let trafficLocation = CLLocation(latitude: currentFlight.coordinate.latitude, longitude: currentFlight.coordinate.longitude)
				let distance = trafficLocation.distance(from: addedLocation)

				// FIXME: This is temporary
				if distance > 3000 {
					existing.trafficType = .situationalAwareness
				}

				existing.didChangeValue(forKey: "trafficType")

				updatedTraffic.append(existing)
				addedTraffic.removeObject(existing)
			}
		}

		if addedTraffic.count > 0 {
			delegate?.airMapTrafficServiceDidAdd(addedTraffic)
			activeTraffic += addedTraffic
		}

		if updatedTraffic.count > 0 {
			delegate?.airMapTrafficServiceDidUpdate(updatedTraffic)
		}
	}

	@objc fileprivate func purgeExpiredTraffic() {

		let expiredTraffic = activeTraffic.filter(isExpired)

		if expiredTraffic.count > 0 {
			activeTraffic.removeObjectsInArray(expiredTraffic)
			delegate?.airMapTrafficServiceDidRemove(expiredTraffic)
		}

	}

	fileprivate func removeAllTraffic() {
		if activeTraffic.count > 0 {
			delegate?.airMapTrafficServiceDidRemove(activeTraffic)
			activeTraffic.removeAll()
		}
	}

	fileprivate func updateTrafficProjections() {

		let updatedTraffic = activeTraffic
			.filter(isMoving)
			.map (projectedTraffic)

		for updated in updatedTraffic {

			if let index = activeTraffic.firstIndex(where: { $0.id == updated.id }) {
				let existing = activeTraffic[index]

				existing.willChangeValue(forKey: "coordinate")
				existing.coordinate = updated.coordinate
				existing.didChangeValue(forKey: "coordinate")

				if existing.trafficType == .alert {
					existing.trafficTypeDidChangeToAlert = false
				} 
			}
		}

		delegate?.airMapTrafficServiceDidUpdate(updatedTraffic)
	}

	func currentFlightLocation() -> CLLocation? {

		if let location = currentFlight.value?.coordinate {
			return CLLocation(latitude: location.latitude, longitude: location.longitude)
		}
		return nil
	}

	// MARK: - Filter/Map helper functions

	fileprivate func isMoving(_ traffic: AirMapTraffic) -> Bool {
		return traffic.groundSpeed > -1 && traffic.trueHeading > -1
	}

	fileprivate func hasAircractId(_ traffic: AirMapTraffic) -> Bool {
		return !traffic.properties.aircraftId.isEmpty
	}

	fileprivate func isExpired(_ traffic: AirMapTraffic) -> Bool {
		return traffic.createdAt.addingTimeInterval(expirationInterval) < Date()
	}

	fileprivate func hasAircractIdMatching(_ aircraftId: String) -> (AirMapTraffic) -> Bool {
		return { $0.properties.aircraftId == aircraftId }
	}

	/**
	Mapping function that projects the traffic's position
	*/
	fileprivate func projectedTraffic(_ traffic: AirMapTraffic) -> AirMapTraffic {
		let newPosition = projectedCoordinate(traffic)
		traffic.coordinate.latitude = newPosition.latitude
		traffic.coordinate.longitude = newPosition.longitude
		return traffic
	}

	/**
	Calculates the projected coordinate for the Manned Aircraft Traffic based upon distance and direction traveled.
	- returns: CLLocation
	*/
	fileprivate func projectedCoordinate(_ traffic: AirMapTraffic) -> CLLocationCoordinate2D {

		guard isMoving(traffic) else {
			return traffic.initialCoordinate
		}

		let elapsedTime = Double(Date().timeIntervalSince(traffic.recordedTime))
		let metersPerSecond = traffic.groundSpeed.metersPerSecond
		let distanceTraveledInMeters = metersPerSecond*elapsedTime
		let trafficLocation = CLLocation(latitude: traffic.initialCoordinate.latitude, longitude: traffic.initialCoordinate.longitude)

		return trafficLocation.destinationLocation(withInitialBearing: Double(traffic.trueHeading), distance: distanceTraveledInMeters).coordinate
	}

	/**
	Returns a TrafficType based upon a subscribed topic
	- parameter topic: String
	- returns: AirMapTraffic.TrafficType
	*/
	fileprivate func trafficTypeForTopic(_ topic: String) -> AirMapTraffic.TrafficType {

		if topic.hasPrefix(Constants.Traffic.alertTopic) {
			return .alert
		} else {
			return .situationalAwareness
		}
	}

	// MARK: - MQTTSessionDelegate {
	
	func mqttDidDisconnect(session: MQTTSession, error: MQTTSessionError) {

		switch error {
		case .none:
			AirMap.logger.trace("Successfully disconnected from MQTT service")
		default:
			AirMap.logger.trace("Failed to disconnect from MQTT service", metadata: ["error": .stringConvertible(error)])
		}
	}

	func mqttDidReceive(message: MQTTMessage, from session: MQTTSession) {

		AirMap.logger.trace("Received message from MQTT service")

		guard
			connectionState.value == .connected,
			let jsonString = String(data: message.payload, encoding: String.Encoding.utf8),
			let jsonDict = try? JSONSerialization.jsonObject(with: message.payload, options: []) as? [String: Any],
			let trafficArray = jsonDict["traffic"] as? [[String: Any]]
		else {
			AirMap.logger.error("Failed to parse MQTT traffic payload")
			return
		}
        
		let traffic = Mapper<AirMapTraffic>().mapArray(JSONArray: trafficArray)
        
		delegate?.airMapTrafficServiceDidReceive?(jsonString)

		let receivedTraffic = traffic.map { t -> AirMapTraffic in
			t.trafficType = self.trafficTypeForTopic(message.topic)
			return t
		}

		addTraffic(receivedTraffic)
	}

	func mqttDidAcknowledgePing(from session: MQTTSession) {
		AirMap.logger.trace("Receive pong from MQTT service")
	}

	func mqttDidDisconnect(session: MQTTSession) {
		AirMap.logger.trace("Disconnected from MQTT service")
		connectionState.accept(.disconnected)
	}
	
	func mqttSocketErrorOccurred(session: MQTTSession) {
		AirMap.logger.error("MQTTSession encountered socket error")
	}

	deinit {
		delegate = nil
	}

}
