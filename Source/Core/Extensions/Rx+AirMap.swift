//
//  Rx+AirMap.swift
//  AirMap
//
//  Created by Adolfo Martinelli on 7/11/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

extension ObservableType {
	
	public func mapToVoid() -> Observable<Void> {
		return self.map { _ -> Void in }
	}

	public func asOptional() -> Observable<E?> {
		return self.map {
			Optional.Some($0)
		}
	}
	
}

extension Driver {
	
	public func mapToVoid() -> Driver<Void> {
		return self.map { _ -> Void in }
	}

}
