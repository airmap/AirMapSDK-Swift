//
//  SystemStatusService.swift
//  AirMapSDK
//
//  Created by Michael Odere on 1/30/20.
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
import RxCocoa
import RxSwift
import Starscream

class SystemStatusService {

	weak var delegate: AirMapSystemStatusDelegate?

	private let connectionState = BehaviorSubject(value: ConnectionState.disconnected)
	private let disposeBag = DisposeBag()
	private var client: SystemStatusClient?

	enum ConnectionState {
		case connected
		case disconnected
	}

	init() {
		setupBindings()
	}

	func connect() {
		connectionState.onNext(.connected)
	}

	func disconnect() {
		connectionState.onNext(.disconnected)
	}

	private func setupBindings() {
		let authState = AirMap.authService.authState
			.catchErrorJustReturn(.loggedOut)

		Observable.combineLatest(connectionState, authState)
			.debounce(.seconds(1), scheduler: MainScheduler.instance)
			.subscribe(onNext: { [weak self] (data) in
				self?.handle(data: data)
			})
			.disposed(by: disposeBag)
	}

	private func handle(data: (connection: ConnectionState, auth: AuthService.AuthState)) {
		switch data.connection {
		case .connected:
			client = SystemStatusClient(accessToken: data.auth.accessToken)
			client?.delegate = self
			client?.connect()
		case .disconnected:
			client?.disconnect()
			client = nil

		}
	}
}

extension SystemStatusService: WebSocketDelegate {
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
		if let status = try? AirMapSystemStatus(JSONString: text) {
			delegate?.airMapSystemStatusDidUpdate(status)
		} else {
			AirMap.logger.error("Failed to parse AirMapSystemStatus", metadata: ["raw text": .stringConvertible(text)])
		}
	}

    public func websocketDidConnect(socket: WebSocketClient) {
		delegate?.airMapSystemStatusDidConnect()
	}

    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
		delegate?.airMapSystemStatusDidDisconnect(error: error)
	}

    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {}
}
