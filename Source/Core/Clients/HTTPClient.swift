//
//  HTTPClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
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
import RxCocoa
import Alamofire
import ObjectMapper

internal class HTTPClient {
	
	static let activity = ActivityTracker()
	
	enum MimeType: String {
		case JSON = "application/json"
	}
	
	enum Header: String {
		case accept = "Accept"
		case apiKey = "X-API-Key"
		case authorization = "Authorization"
	}
	
	let basePath: String
	
	private lazy var manager: SessionManager = {
		
		let host = AirMap.configuration.domain
		let keys = ServerTrustPolicy.publicKeys(in: AirMapBundle.core)
		
		let serverTrustPolicies: [String: ServerTrustPolicy] = [
			host: ServerTrustPolicy.pinPublicKeys(publicKeys: keys, validateCertificateChain: true, validateHost: true)
		]

		let manager = AirMap.configuration.pinCertificates ?
			SessionManager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)) : SessionManager()

		return manager
	}()
	
	init(basePath: String) {
		self.basePath = basePath
	}

	func withCredentials() -> Observable<AuthService.Credentials> {
		return AirMap.authService.performWithCredentials()
	}

	private func defaultHeaders(with accessToken: String?) -> HTTPHeaders {
		var headers = [String: String]()
		headers[Header.accept.rawValue] = MimeType.JSON.rawValue
		headers[Header.apiKey.rawValue] = AirMap.configuration.apiKey
		headers[Header.authorization.rawValue] = "Bearer \(accessToken ?? "")"
		return headers
	}
		
	internal func perform<T: BaseMappable>(method: HTTPMethod, path: String = "", params: [String: Any] = [:], keyPath: String? = "data", update object: T? = nil, auth: AuthService.Credentials? = nil) -> Observable<T> {

		return Observable
			.create { (observer: AnyObserver<T>) -> Disposable in
				let headers = self.defaultHeaders(with: auth?.token)
				let request = self.manager
					.request(self.absolute(path), method: method, parameters: params, encoding: self.encoding(method), headers: headers)
					.airMapResponseObject(keyPath: keyPath, mapTo: object) { response in
						if let error = response.result.error {
							if let error = error as? AirMapError, case AirMapError.cancelled = error {
								AirMap.logger.trace(method, String(describing: T.self), path, error)
								observer.onCompleted()
							} else {
								AirMap.logger.error(method, String(describing: T.self), path, error)
								observer.onError(error)
							}
						} else {
							AirMap.logger.trace(String(describing: T.self))
							observer.on(.next(response.result.value!))
							observer.on(.completed)
						}
				}

				return Disposables.create {
					request.cancel()
				}
			}
			.trackActivity(HTTPClient.activity)
	}
	
	internal func perform<T: BaseMappable>(method: HTTPMethod, path: String = "", params: [String: Any] = [:], keyPath: String? = "data", update object: T? = nil, auth: AuthService.Credentials? = nil) -> Observable<T?> {
		
		return Observable
			.create { (observer: AnyObserver<T?>) -> Disposable in
				let headers = self.defaultHeaders(with: auth?.token)
				let request = self.manager
					.request(self.absolute(path), method: method, parameters: params, encoding: self.encoding(method), headers: headers)
					.airMapResponseObject(keyPath: keyPath, mapTo: object) { response in
						if let error = response.result.error {
							if let error = error as? AirMapError, case AirMapError.cancelled = error {
								AirMap.logger.trace(method, String(describing: T.self), path, error)
								observer.onCompleted()
							} else {
								AirMap.logger.error(method, String(describing: T.self), path, error)
								observer.onError(error)
							}
						} else {
							observer.on(.next(response.result.value ?? nil))
							observer.on(.completed)
						}
				}
				return Disposables.create {
					request.cancel()
				}
			}
			.trackActivity(HTTPClient.activity)
	}
	
	internal func perform<T: BaseMappable>(method: HTTPMethod, path: String = "", params: [String: Any] = [:], keyPath: String? = "data", auth: AuthService.Credentials? = nil) -> Observable<[T]> {

		return Observable
			.create { (observer: AnyObserver<[T]>) -> Disposable in
				let headers = self.defaultHeaders(with: auth?.token)
				let request = self.manager
					.request(self.absolute(path), method: method, parameters: params, encoding: self.encoding(method), headers: headers)
					.airMapResponseArray(keyPath: keyPath) { (response: DataResponse<[T]>) in
						if let error = response.result.error {
							if let error = error as? AirMapError, case AirMapError.cancelled = error {
								AirMap.logger.trace(method, String(describing: T.self), path, error)
								observer.onCompleted()
							} else {
								AirMap.logger.error(method, String(describing: T.self), path, error)
								observer.onError(error)
							}
						} else {
							let resultValue = response.result.value!
							AirMap.logger.debug("Response:", resultValue.count, String(describing: T.self)+"s")
							observer.on(.next(resultValue))
							observer.on(.completed)
						}
				}
				return Disposables.create() {
					request.cancel()
				}

			}
			.trackActivity(HTTPClient.activity)
	}
	
	internal func perform(method: HTTPMethod, path: String = "", params: [String: Any] = [:], keyPath: String? = "data", auth: AuthService.Credentials? = nil) -> Observable<Void> {

		return Observable
			.create { (observer: AnyObserver<Void>) -> Disposable in
				let headers = self.defaultHeaders(with: auth?.token)
				let request = self.manager
					.request(self.absolute(path), method: method, parameters: params, encoding: self.encoding(method), headers: headers)
					.airMapVoidResponse { (response: DataResponse<Void>) in
						if let error = response.error {
							if let error = error as? AirMapError, case AirMapError.cancelled = error {
								AirMap.logger.trace(method, path, error)
								observer.onCompleted()
							} else {
								AirMap.logger.error(method, path, error)
								observer.onError(error)
							}
						} else {
							observer.on(.next(()))
							observer.on(.completed)
						}
				}
				return Disposables.create() {
					request.cancel()
				}
			}
			.trackActivity(HTTPClient.activity)
	}
	
	private func encoding(_ method: HTTPMethod) -> ParameterEncoding {
		return (method == .get || method == .delete) ? URLEncoding.queryString : JSONEncoding.default
	}
	
	private func absolute(_ path: String) -> String {
		return self.basePath + path.urlEncoded
	}
	
}

extension DataRequest {
	
	/// Converts the response into a BaseMappable object
	func airMapResponseObject<T: BaseMappable>(keyPath: String? = nil, mapTo object: T? = nil, context: MapContext? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
		
		let serializer: DataResponseSerializer<T> = DataRequest.airMapSerializer(keyPath, mapToObject: object, context: context)
		return response(queue: nil, responseSerializer: serializer, completionHandler: completionHandler)
	}

	/// Converts the response into an array of BaseMappable objects
	func airMapResponseArray<T: BaseMappable>(keyPath: String? = nil, context: MapContext? = nil, completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
		
		let serializer: DataResponseSerializer<[T]> = DataRequest.airMapSerializer(keyPath, context: context)
		return response(queue: nil, responseSerializer: serializer, completionHandler: completionHandler)
	}
	
	/// Converts the response into Void
	func airMapVoidResponse(completionHandler: @escaping (DataResponse<Void>) -> Void) -> Self {
		
		let serializer: DataResponseSerializer<Void> = DataRequest.airMapSerializer()
		return response(queue: nil, responseSerializer: serializer, completionHandler: completionHandler)
	}

	/// Void serializer
	public static func airMapSerializer() -> DataResponseSerializer<Void> {
		
		return DataResponseSerializer { request, response, data, error in
			
			do {
				// Ensure we received a reponse, else throw error
				guard let response = response else {
					throw AirMapError.network(error!)
				}
				// Ensure we have a valid data response (not nil)
				let data = try validatedData(from: response, data: data)

				// Catch any error-related http codes and body
				try catchApiError(with: response, from: request, with: data)
				
				return .success(())
			}
			catch {
				return .failure(error)
			}
		}
	}

	/// Single object serializer
	public static func airMapSerializer<T: BaseMappable>(_ keyPath: String?, mapToObject object: T? = nil, context: MapContext? = nil) -> DataResponseSerializer<T> {
		
		return DataResponseSerializer { request, response, data, error in
			
			do {
				// Catch cancelled requests
				if let error = error as NSError?, error.code == -999 {
					throw AirMapError.cancelled
				}

				// Ensure we received a reponse, else throw error
				guard let response = response else {
					throw AirMapError.network(error!)
				}
				// Ensure we have a valid data response (not nil)
				let data = try validatedData(from: response, data: data)

				// Catch any error-related http codes and body
				try catchApiError(with: response, from: request, with: data)

				// Parse json from response body
				let json = try jsonObjectFrom(response: response, json: data, keyPath: keyPath)
				
				// Map the json to the target object if provided else return a new object
				if let object = object {
					_ = Mapper<T>().map(JSONObject: json, toObject: object)
					return .success(object)
				} else if let mappedObject = Mapper<T>(context: context).map(JSONObject: json) {
					return .success(mappedObject)
				} else {
					return .failure(AirMapError.serialization(.invalidObject))
				}
			}
			catch {
				return .failure(error)
			}
		}
	}
	
	/// Array serializer
	public static func airMapSerializer<T: BaseMappable>(_ keyPath: String?, context: MapContext? = nil) -> DataResponseSerializer<[T]> {
		
		return DataResponseSerializer { request, response, data, error in
			
			do {
				// Ensure we received a reponse, else throw error
				guard let response = response else {
					throw AirMapError.network(error!)
				}
				// Ensure we have a valid data response (not nil)
				let data = try validatedData(from: response, data: data)
				
				// Catch any error-related http codes and body
				try catchApiError(with: response, from: request, with: data)

				// Parse json from response body
				let json = try jsonObjectFrom(response: response, json: data, keyPath: keyPath)
				
				// Map the json to a new object
				if let parsedObjects: [T] = Mapper<T>(context: context).mapArray(JSONObject: json) {
					return .success(parsedObjects)
				} else {
					return .failure(AirMapError.serialization(.invalidObject))
				}
			}
			catch {
				return .failure(error)
			}
		}
	}
	
	/// Returns a json object from the response payload. Throws an error if unable to serialize.
	private static func jsonObjectFrom(response: HTTPURLResponse, json data: Data, keyPath: String?) throws -> Any? {

		if let url = response.url {
			AirMap.logger.trace(url)
		}
		
		if data.count > 0, let body = String(data: data, encoding: .utf8) {
			AirMap.logger.trace("HTTP Response:", body)
		}
		
		let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
		let result = jsonResponseSerializer.serializeResponse(nil, response, data, nil)
		
		guard case .success = result else {
			throw AirMapError.serialization(.invalidJson)
		}
		
		let JSONToMap: Any?
		if let keyPath = keyPath, !keyPath.isEmpty {
			JSONToMap = (result.value as AnyObject?)?.value(forKeyPath: keyPath)
		} else {
			JSONToMap = result.value
		}
		
		return JSONToMap
	}
	
	/// 
	private static func validatedData(from response: HTTPURLResponse, data: Data?) throws -> Data {
		
		let serializedData = Request.serializeResponseData(response: response, data: data, error: nil)

		switch serializedData {
		case .success(let data):
			return data
		case .failure:
			throw AirMapError.serialization(.invalidData)
		}
	}
	
	/// Adapts a generic underlying error to an AirMapError
	private static func catchApiError(with response: HTTPURLResponse, from request: URLRequest?, with data: Data) throws {
		
		if let error = AirMapError(rawValue: (request, response, data)) {
			throw error
		}
	}
	
}
