//
//  AirMapSystemStatusService.swift
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

class AirMapSystemStatusService {

	var delegate: AirMapSystemStatusDelegate?

	private let disposeBag = DisposeBag()
	private var client: AirMapSystemStatusClient?

	init() {
		setupBindings()
	}

	func connect(with accessToken: String) {
		client = AirMapSystemStatusClient(accessToken: accessToken)
		client?.delegate = self
		client?.connect()
	}

	func disconnect() {
		self.client = nil
		self.client?.disconnect()
	}

	private func setupBindings() {
		AirMap.authService.authState
			.catchErrorJustReturn(.loggedOut)
			.subscribeNext(weak: self, AirMapSystemStatusService.handle)
			.disposed(by: disposeBag)
	}

	private func handle(state: AuthService.AuthState) {
		disconnect()
		switch state {
		case .loggedOut:
			break
		case .anonymous(let token):
			connect(with: token.idToken)
		case .authenticated(let state):
			guard let accessToken = state.lastTokenResponse?.accessToken else { return }
			connect(with: accessToken)
		}
	}
}

extension AirMapSystemStatusService: WebSocketDelegate {
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
		if let status = AirMapSystemStatus(JSONString: text) {
			delegate?.airMapSystemStatusDidUpdate(status)
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