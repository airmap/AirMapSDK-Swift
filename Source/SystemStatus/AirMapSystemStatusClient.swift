//
//  AirMapSystemStatusClient.swift
//  AirMapSDK
//
//  Created by Michael Odere on 2/3/20.
//

import Foundation
import RxCocoa
import RxSwift
import Starscream

class AirMapSystemStatusClient: WebSocketAdvancedDelegate {

	private var socket: WebSocket?
	private let disposeBag = DisposeBag()

	init() {
		AirMap.authService.authState
			.map { $0.accessToken }
			.subscribe(onNext: { [weak self] (token) in
				self?.socket?.disconnect()
				guard let token = token else { return }
				AirMap.logger.debug("Monitor system stats")
				var request = URLRequest(url: URL(string: Constants.Api.systemUrl + "/status/monitor")!)
				request.timeoutInterval = 5 // Sets the timeout for the connection
				request.setValue(AirMap.configuration.apiKey, forHTTPHeaderField: "X-API-KEY")
				request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
				request.setValue("string", forHTTPHeaderField: "Accept-Language")

				self?.socket = WebSocket(request: request)
				self?.socket?.advancedDelegate = self
				self?.socket?.connect()
			})
			.disposed(by: disposeBag)
	}

	func websocketDidConnect(socket: WebSocket) {
		print("Did connect")
	}

	func websocketDidDisconnect(socket: WebSocket, error: Error?) {
		print("Did disconnect err \(error)")
	}

	func websocketDidReceiveMessage(socket: WebSocket, text: String, response: WebSocket.WSResponse) {
		print("did receive text \(text)")
		if let data = response.buffer as Data? {
			print("did receive text with data \(String(data: data, encoding: .utf8))")
		}
	}

	func websocketDidReceiveData(socket: WebSocket, data: Data, response: WebSocket.WSResponse) {
		print("did receive data \(String(data: data, encoding: .utf8))")
	}

	func websocketHttpUpgrade(socket: WebSocket, request: String) {
		print("upgrade req \(request)")
	}

	func websocketHttpUpgrade(socket: WebSocket, response: String) {
		print("upgrade resp \(response)")
	}

}

