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

public class AirMapSystemStatusService: AirMapSystemStatusDelegate {

	public var delegate: AirMapSystemStatusDelegate?

	private let disposeBag = DisposeBag()
	private var client: AirMapSystemStatusClient?

	public init() {
		setupbindings()
	}

	private func setupbindings() {

		AirMap.authService.authState
			.catchErrorJustReturn(.loggedOut)
			.subscribeNext(weak: self, AirMapSystemStatusService.handle)
			.disposed(by: disposeBag)


		delegate = self

		rx.airMapSystemStatusUpdate
			.subscribe()
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
			connect(with: state.lastTokenResponse?.accessToken)

		}
	}

	private func connect(with accessToken: String?) {
		guard let accessToken = accessToken else { return }
		client = AirMapSystemStatusClient(accessToken: accessToken)
		client?.advancedDelegate = self
		client?.connect()
	}

	private func disconnect() {
		self.client?.disconnect()
	}
}

extension AirMapSystemStatusService: WebSocketAdvancedDelegate {
	public func websocketDidConnect(socket: WebSocket) {
		print("Did connect")
	}

	public func websocketDidDisconnect(socket: WebSocket, error: Error?) {
		print("Did disconnect err \(error)")
	}

	public func websocketDidReceiveMessage(socket: WebSocket, text: String, response: WebSocket.WSResponse) {
		print("did receive text \(text)")
		if let data = response.buffer as Data? {
			print("did receive text with data \(String(data: data, encoding: .utf8))")
		}
	}

	public func websocketDidReceiveData(socket: WebSocket, data: Data, response: WebSocket.WSResponse) {
		print("did receive data \(String(data: data, encoding: .utf8))")
	}

	public func websocketHttpUpgrade(socket: WebSocket, request: String) {
		print("upgrade req \(request)")
	}

	public func websocketHttpUpgrade(socket: WebSocket, response: String) {
		print("upgrade resp \(response)")
	}
}
