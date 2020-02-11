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

	var delegate: AirMapSystemStatusDelegate?

	private let connectSubject = PublishSubject<Void>()
	private let disposeBag = DisposeBag()
	private var client: AirMapSystemStatusClient?

	init() {
		setupBindings()
	}

	func connect() {
		connectSubject.onNext(())
	}

	private func connect(with accessToken: String) {
		client = SystemStatusClient(accessToken: accessToken)
		client?.delegate = self
		client?.connect()
	}

	func disconnect() {
		self.client = nil
		self.client?.disconnect()
	}

	private func setupBindings() {
		let connect = connectSubject
			.withLatestFrom(AirMap.authService.authState)

		Observable.merge(connect, AirMap.authService.authState.asObservable())
			.debounce(.seconds(1), scheduler: MainScheduler.instance)
			.catchErrorJustReturn(.loggedOut)
			.subscribeNext(weak: self, SystemStatusService.handle)
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

extension SystemStatusService: WebSocketDelegate {
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
		if let status = AirMapSystemStatus(JSONString: text) {
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
