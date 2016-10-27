//
//  TrafficService.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/29/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import SwiftMQTT
import CoreLocation
import ObjectMapper
import RxSwift
import RxSwiftExt

internal class TrafficService: MQTTSessionDelegate {

	enum Error: ErrorType {
		case InvalidCredentials
	}

	enum ConnectionState {
		case Connecting
		case Connected
		case Disconnected
	}

	enum TrafficServiceError: ErrorType {
		case InvalidCredentials
		case ConnectionFailed
		case SubscriptionFailed
	}

	internal weak var delegate: AirMapTrafficObserver?

	internal var authToken: String? {
		set { client.password = authToken }
		get { return client.password }
	}

	private var activeTraffic = [AirMapTraffic]()
	private var expirationInterval = Config.AirMapTraffic.expirationInterval
	private var client = TrafficClient()
	private var connectionState  = Variable(ConnectionState.Disconnected)
	private var currentFlight    = Variable(nil as AirMapFlight?)

	private let disposeBag = DisposeBag()

	// MARK: - Setup

	init() {

		client.delegate = self
		setupBindings()
		connect()
	}

	// MARK: - Instance Methods

	func setupBindings() {

		let state = connectionState.asObservable()

		let flight = currentFlight.asObservable()
			.distinctUntilChanged { flight in flight?.flightId ?? "" }

		let flightState = Observable.combineLatest(flight, state) { ($0, $1) }

		let whenConnected    = flightState.filter { $1 == .Connected }
		let whenDisconnected = flightState.filter { $1 == .Disconnected }

		func printError(error: ErrorType) {
			AirMap.logger.error(error)
		}

		whenDisconnected
			.retry()
			.throttle(1, scheduler: MainScheduler.instance)
			.map { flight, state in flight }
			.unwrap()
			.filter {[unowned self] _ in AirMap.hasValidCredentials() && self.delegate != nil}
			.flatMap(unowned(self, TrafficService.connectWithFlight))
			.doOnError(printError)
			.catchError({ _ in return Observable.just( .Disconnected) })
			.bindTo(connectionState)
			.addDisposableTo(disposeBag)

		whenConnected
			.retry()
			.throttle(1, scheduler: MainScheduler.instance)
			.filter {[unowned self] _ in AirMap.hasValidCredentials() && self.delegate != nil}
			.map { flight, state in flight }
			.unwrap()
			.flatMap(unowned(self, TrafficService.subscribeToTraffic))
			.doOnError(printError)
			.catchError({ _ in return Observable.empty() })
			.subscribe()
			.addDisposableTo(disposeBag)

		state
			.subscribeNext { [unowned self] state in
				switch state {
				case .Connecting:
					AirMap.logger.debug(TrafficService.self, "Connecting…")
				case .Connected:
					AirMap.logger.debug(TrafficService.self, "Connected")
					self.delegate?.airMapTrafficServiceDidConnect?()
				case .Disconnected:
					AirMap.logger.debug(TrafficService.self, "Disconnected")
					self.delegate?.airMapTrafficServiceDidDisconnect?()
				}
				AirMap.logger.debug(state)
			}
			.addDisposableTo(disposeBag)

		let refreshCurrentFlight = Observable<Int>.timer(0, period: 15, scheduler: MainScheduler.instance).mapToVoid()

		refreshCurrentFlight
			.skipWhile({[unowned self] _ in !AirMap.hasValidCredentials() && self.delegate == nil})
			.flatMap(AirMap.rx_getCurrentAuthenticatedPilotFlight)
			.bindTo(currentFlight)
			.addDisposableTo(disposeBag)

		let trafficProjectionTimer = Observable<Int>.interval(0.25, scheduler: MainScheduler.asyncInstance).mapToVoid()

		trafficProjectionTimer
			.doOnNext(unowned(self, TrafficService.updateTrafficProjections))
			.subscribe()
			.addDisposableTo(disposeBag)

		let purgeTrafficTimer = Observable<Int>.interval(5, scheduler: MainScheduler.asyncInstance).mapToVoid()

		purgeTrafficTimer
			.subscribeNext(unowned(self, TrafficService.purgeExpiredTraffic))
			.addDisposableTo(disposeBag)
	}

	func connect() {

		if AirMap.hasValidCredentials() && delegate != nil {

			if connectionState.value != .Disconnected {
				disconnect()
			}

			AirMap.rx_getCurrentAuthenticatedPilotFlight().bindTo(currentFlight).addDisposableTo(disposeBag)
		}
	}

	func disconnect() {
		unsubscribeFromAllChannels()
		currentFlight.value = nil
		removeAllTraffic()
		client.disconnect()
	}

	// MARK: - Observable Methods

	func connectWithFlight(flight: AirMapFlight) -> Observable<ConnectionState> {

		return Observable.create { (observer: AnyObserver<ConnectionState>) -> Disposable in

			observer.onNext(.Connecting)

			self.client.username = flight.flightId
			self.client.password = AirMap.authSession.authToken

			self.client.connect { succeeded, error in
				if succeeded {
					observer.onNext(.Connected)
				} else {
					AirMap.logger.error(error)
					observer.onError(TrafficServiceError.ConnectionFailed)
					observer.onNext(.Disconnected)
				}
			}

			return AnonymousDisposable {
			}
		}
	}

	func subscribeToTraffic(flight: AirMapFlight) -> Observable<Void> {

		let sa    = self.subscribe(flight, to: Config.AirMapTraffic.trafficSituationalAwarenessChannel + flight.flightId)
		let alert = self.subscribe(flight, to: Config.AirMapTraffic.trafficAlertChannel + flight.flightId)

		return unsubscribeFromAllChannels().concat(sa).concat(alert)
	}

	func subscribe(flight: AirMapFlight, to channel: String) -> Observable<Void> {
		return Observable.create { (observer: AnyObserver<Void>) -> Disposable in
			self.client.subscribe(channel, qos: .AtLeastOnce) { succeeded, error in
				if succeeded {
					self.client.currentChannels.append(channel)
					AirMap.logger.debug(TrafficService.self, "Subscribed to \(channel)")
					observer.onCompleted()
				} else {
					observer.onError(TrafficServiceError.SubscriptionFailed)
				}
			}
			return NopDisposable.instance
		}
	}

	func unsubscribeFromAllChannels() -> Observable<Void> {
		return Observable.create { observer in
			let channels = self.client.currentChannels
			guard channels.count > 0 else {
				observer.onCompleted()
				return NopDisposable.instance
			}
			self.client.unSubscribe(channels) { succeeded, error in
				if succeeded {
					AirMap.logger.debug(TrafficService.self, "Unsubscribed from channels", channels)
				} else {
					AirMap.logger.debug(TrafficService.self, error)
					observer.onError(TrafficServiceError.SubscriptionFailed)
				}
				self.client.currentChannels = []
				observer.onCompleted()
			}
			return NopDisposable.instance
		}
	}

	func startPurgingExpiredTraffic(flight: AirMapFlight) -> Observable<AirMapFlight> {
		return Observable.create { (observer: AnyObserver<AirMapFlight>) -> Disposable in
			observer.onCompleted()
			return NopDisposable.instance
		}
	}

	// MARK: - Private Instance Methods

	private func addTraffic(traffic: [AirMapTraffic]) {

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

				existing.setValuesForKeysWithDictionary([
					"id":              added.id,
					"direction":       added.direction,
					"altitude":        added.altitude,
					"groundSpeedKt":   added.groundSpeedKt,
					"trueHeading":     added.trueHeading,
					"timestamp":       added.timestamp,
					"recordedTime":    added.recordedTime,
					"properties":      added.properties,
					"createdAt":       added.createdAt
					])

				existing.willChangeValueForKey("coordinate")
				existing.coordinate = added.coordinate
				existing.didChangeValueForKey("coordinate")

				existing.willChangeValueForKey("initialCoordinate")
				existing.initialCoordinate = added.initialCoordinate
				existing.didChangeValueForKey("initialCoordinate")

				existing.willChangeValueForKey("trafficType")

				if existing.trafficType == .Alert {
					existing.trafficTypeDidChangeToAlert = false
				} else {
					existing.trafficType = added.trafficType
				}


				let addedLocation = CLLocation(latitude: added.coordinate.latitude, longitude: added.coordinate.longitude)
				let trafficLocation = CLLocation(latitude: currentFlight.coordinate.latitude, longitude: currentFlight.coordinate.longitude)
				let distance = trafficLocation.distanceFromLocation(addedLocation)

				//FIXME: This is temporary
				if distance > 3000 {
					existing.trafficType = .SituationalAwareness
				}

				existing.didChangeValueForKey("trafficType")

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

	@objc private func purgeExpiredTraffic() {

		let expiredTraffic = activeTraffic.filter(isExpired)

		if expiredTraffic.count > 0 {
			activeTraffic.removeObjectsInArray(expiredTraffic)
			delegate?.airMapTrafficServiceDidRemove(expiredTraffic)
		}

		updateTrafficProjections()
	}

	private func removeAllTraffic() {
		if activeTraffic.count > 0 {
			delegate?.airMapTrafficServiceDidRemove(activeTraffic)
			activeTraffic.removeAll()
		}
	}

	private func updateTrafficProjections() {

		let updatedTraffic = activeTraffic
			.filter(isMoving)
			.map (projectedTraffic)

		if updatedTraffic.count > 0 {
			addTraffic(updatedTraffic)
		}
	}

	func currentFlightLocation() -> CLLocation? {

		if let location = currentFlight.value?.coordinate {
			return CLLocation(latitude: location.latitude, longitude: location.longitude)
		}
		return nil
	}

	// MARK: - Filter/Map helper functions

	private func isMoving(traffic: AirMapTraffic) -> Bool {
		return traffic.groundSpeedKt > -1 && traffic.trueHeading > -1
	}

	private func hasAircractId(traffic: AirMapTraffic) -> Bool {
		return !traffic.properties.aircraftId.isEmpty
	}

	private func isExpired(traffic: AirMapTraffic) -> Bool {
		return traffic.createdAt.dateByAddingTimeInterval(expirationInterval).lessThanDate(NSDate())
	}

	private func hasAircractIdMatching(aircraftId: String) -> (AirMapTraffic) -> Bool {
		return { $0.properties.aircraftId == aircraftId }
	}

	/**
	Mapping function that projects the traffic's position
	*/
	private func projectedTraffic(traffic: AirMapTraffic) -> AirMapTraffic {
		let newPosition = projectedCoordinate(traffic)
		traffic.coordinate.latitude = newPosition.latitude
		traffic.coordinate.longitude = newPosition.longitude
		return traffic
	}

	/**
	Calculates the projected coordinate for the Manned Aircraft Traffic based upon distance and direction traveled.
	- returns: CLLocation
	*/
	private func projectedCoordinate(traffic: AirMapTraffic) -> CLLocationCoordinate2D {

		guard isMoving(traffic) else {
			return traffic.initialCoordinate
		}

		let elapsedTime = Double(NSDate().timeIntervalSinceDate(traffic.recordedTime))
		let metersPerSecond = Double(traffic.groundSpeedKt) * 0.514444
		let distanceTraveledInMeters = metersPerSecond*elapsedTime
		let trafficLocation = CLLocation(latitude: traffic.initialCoordinate.latitude, longitude: traffic.initialCoordinate.longitude)

		return trafficLocation.destinationLocationWithInitialBearing(Double(traffic.trueHeading), distance:distanceTraveledInMeters).coordinate
	}

	/**
	Returns a TrafficType based upon a subscribed topic
	- parameter topic: String
	- returns: AirMapTraffic.TrafficType
	*/
	private func trafficTypeForTopic(topic: String) -> AirMapTraffic.TrafficType {

		if topic.hasPrefix(Config.AirMapTraffic.trafficAlertChannel) {
			return .Alert
		} else {
			return .SituationalAwareness
		}
	}

	// MARK: - MQTTSessionDelegate {

	func mqttSession(session: MQTTSession, didReceiveMessage message: NSData, onTopic topic: String) {

		AirMap.logger.trace(TrafficService.self, "Did receive data")

		guard
			connectionState.value == .Connected,
			let jsonString = String(data: message, encoding: NSUTF8StringEncoding),
			let jsonDict = try? NSJSONSerialization.JSONObjectWithData(message, options: []),
			let traffic = Mapper<AirMapTraffic>().mapArray(jsonDict["traffic"])
		else {
			AirMap.logger.error(TrafficService.self, "Failed to parse JSON message")
			return
		}

		delegate?.airMapTrafficServiceDidReceive?(jsonString)

		let receivedTraffic = traffic.map { t -> AirMapTraffic in
			t.trafficType = self.trafficTypeForTopic(topic)
			t.coordinate = self.projectedCoordinate(t)
			return t
		}

		addTraffic(receivedTraffic)
	}

	func didDisconnectSession(session: MQTTSession) {
		AirMap.logger.debug(TrafficService.self, "Disconnected from MQTT")
		connectionState.value = .Disconnected
	}

	func socketErrorOccurred(session: MQTTSession) {
		AirMap.logger.error(TrafficService.self, "MQTTSession socket error")
//		disconnect()
	}

	deinit {
		delegate = nil
	}

}
