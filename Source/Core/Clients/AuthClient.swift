//
//  AuthUserClient.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 2/24/17.
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

import Foundation
import RxSwift
import AppAuth

internal class AuthClient: HTTPClient {
    
    init() {
        super.init(basePath: Constants.Api.authUrl)
    }
    
    func performAnonymousLogin(withForeign id: String) -> Observable<AirMapToken> {
        
        let params = ["user_id": id]
        
        return perform(method: .post, path: "/anonymous/token", params: params, keyPath: "data")
            .do(onNext: { token in
				// FIXME:
				assertionFailure("not implemented")
            }, onError: { error in
                AirMap.logger.debug("ERROR:", error)
            })
    }
}
