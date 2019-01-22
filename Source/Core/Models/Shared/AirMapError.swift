//
//  AirMapError.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 2/3/17.
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
import ObjectMapper

public enum AirMapError: Error {
	case cancelled
	case network(Error)
	case unauthorized
	case conflict
	case invalidRequest(Error)
	case client(Error)
	case server
	case serialization(AirMapSerializationError)
	case unknown(underlying: Error)
}

extension AirMapError: RawRepresentable {
	
	public typealias RawValue = (request: URLRequest?, response: HTTPURLResponse, data: Data)
	
	public var rawValue: RawValue {
		fatalError("RawValue getter unavailable")
	}
	
	public init?(rawValue: RawValue) {
		
		let code = rawValue.response.statusCode
		
		switch code {
			
		case 400:
			let error = AirMapError.error(from: rawValue)
			self = .invalidRequest(error)
			
		case 401:
			self = .unauthorized
			
		case 404:
			let error = AirMapApiError(message: "Not Found", code: code)
			self = .client(error)
			
		case 409:
			self = .conflict
			
		case 422:
			let error = AirMapError.error(from: rawValue)
			self = .invalidRequest(error)
			
		case 400..<500:
			let error = AirMapError.error(from: rawValue)
			self = .client(error)
			
		case 500..<600:
			self = .server
			
		default:
			return nil
		}
	}
	
	private static func error(from rawValue: RawValue) -> AirMapApiError {
		
		if let json = try? JSONSerialization.jsonObject(with: rawValue.data, options: .allowFragments),
			let error = Mapper<AirMapApiError>().map(JSONObject: json) {
			return error
		} else {
			let code = rawValue.response.statusCode
			return AirMapApiError(message: String(format: LocalizedStrings.Error.genericFormat, code.description), code: code)
		}
	}
}

extension AirMapError: CustomStringConvertible {
	
	public var description: String {
		
		let localized = LocalizedStrings.Error.self
		
		switch self {
		case .cancelled:
			return localized.cancelled
		case .network(let error):
			return error.localizedDescription
		case .unauthorized:
			return localized.unauthorized
		case .conflict:
			return localized.conflict
		case .invalidRequest(let error):
			return error.localizedDescription
		case .client(let error):
			return error.localizedDescription
		case .server:
			return localized.server
		case .serialization:
			return localized.serialization
		case .unknown(let error):
			return error.localizedDescription
		}
	}
}

extension AirMapError: LocalizedError {
	
	public var errorDescription: String? {
		return description
	}
}

public enum AirMapSerializationError: Error {
	case invalidData
	case invalidJson
	case invalidObject
}

public struct AirMapApiError: Mappable, LocalizedError {
	
	public internal(set) var message: String?
	public internal(set) var messages = [AirMapApiParameterError]()
	public internal(set) var code: Int?
	
	internal init(message: String, code: Int) {
		self.message = message
		self.code = code
	}
	
	public init?(map: Map) {
		
		if let status = map.JSON["status"] as? String {
			if status != "fail" {
				return nil
			}
		}
	}
	
	public mutating func mapping(map: Map) {
		message   <-  map["data.message"]
		messages  <-  map["data.errors"]
		code      <-  map["data.code"]		
	}
	
	public var description: String {
		return localizedDescription
	}
	
	public var errorDescription: String? {
		return localizedDescription
	}
	
	public var localizedDescription: String {
		if messages.count == 0 {
			return message ?? LocalizedStrings.Error.server
		} else {
			return messages.map { $0.name + ": " + $0.message }.joined(separator: "\n")
		}
	}
}

public struct AirMapApiParameterError: Mappable {
	
	public internal(set) var name: String!
	public internal(set) var message: String!
	
	public init?(map: Map) {
		guard (map.JSON["name"] as? String != nil || map.JSON["param"] as? String != nil), (map.JSON["message"] as? String != nil || map.JSON["msg"] as? String != nil) else {
			return nil
		}
	}
	
	public mutating func mapping(map: Map) {
		name     <-  map["name"]
		message  <-  map["message"]
		
		if name == nil { name <- map["param"] }
		if message == nil { message <- map["msg"]}
	}
}

