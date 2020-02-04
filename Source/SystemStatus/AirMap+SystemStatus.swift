//
//  AirMap+SystemStatus.swift
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

@objc public protocol AirMapSystemStatusDelegate {
	@objc optional func airMapSystemStatusUpdate(_ status: AirMapSystemStatus)
}

extension AirMap {
	public static var systemStatusDelegate: AirMapSystemStatusDelegate? {
		didSet { systemStatusService.delegate = systemStatusDelegate }
	}

	/// Suspend all active status alerts
	/// Typically called when the app enters the background.
	public static func suspendSystemStatus() {
//		systemStatusService.disconnect()
	}

	/// Resume all active status alerts
	/// Typically called when the app enters the foreground.
	public static func resumeSystemStatus() {
//		systemStatusService.connect()
	}
}

import RxSwift
import RxCocoa
import RxSwiftExt

extension AirMapSystemStatusService: HasDelegate {
	public typealias Delegate = AirMapSystemStatusDelegate
}

public class RxAirMapSystemStatusDelegateProxy: DelegateProxy<AirMapSystemStatusService, AirMapSystemStatusDelegate>, DelegateProxyType, AirMapSystemStatusDelegate {

	public init(service: AirMapSystemStatusService) {
		super.init(parentObject: service, delegateProxy: RxAirMapSystemStatusDelegateProxy.self)
	}

	public static func registerKnownImplementations() {
		register(make: RxAirMapSystemStatusDelegateProxy.init)
	}
}

extension AirMapSystemStatusService: ReactiveCompatible {}

extension Reactive where Base: AirMapSystemStatusService {

	public var delegate: DelegateProxy<AirMapSystemStatusService, AirMapSystemStatusDelegate> {
		return RxAirMapSystemStatusDelegateProxy.proxy(for: base)
	}

	public func setDelegate(_ delegate: AirMapSystemStatusDelegate) -> Disposable {
		return RxAirMapSystemStatusDelegateProxy.installForwardDelegate(delegate, retainDelegate: true, onProxyForObject: self.base)
	}

	public var airMapSystemStatusUpdate: Observable<AirMapSystemStatus> {
		return delegate.methodInvoked(#selector(AirMapSystemStatusDelegate.airMapSystemStatusUpdate(_:)))
			.map { $0[0] as! AirMapSystemStatus}
	}
}
