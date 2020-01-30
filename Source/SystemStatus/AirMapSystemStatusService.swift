//
//  AirMapSystemStatusService.swift
//  AirMapSDK
//
//  Created by Michael Odere on 1/30/20.
//

import Foundation
import RxCocoa
import RxSwift

class AirMapSystemStatusService {

	var delegate: AirMapSystemStatusDelegate?
	private let disposeBag = DisposeBag()

	init() {
		Observable<Int>.interval(5, scheduler: MainScheduler.instance)
			.subscribe(onNext: { [weak self] (val) in
				let level = AirMapSystemStatus.Level.allCases.randomElement()!
				self?.delegate?.airMapSystemStatusUpdate(AirMapSystemStatus(level: level, message: "Message!"))
			})
			.disposed(by: disposeBag)
	}
}
