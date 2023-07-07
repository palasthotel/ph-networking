//
//  File.swift
//  
//
//  Created by Benjamin Böcker on 11.03.22.
//

import Foundation
import OSLog

public typealias Header = (field: String, value: String)

public protocol Endpoint {
	var path: String { get }
	var httpMethod: HTTPMethod { get }
	var body: Codable? { get }
	var parameters: [EndpointParameter] { get }
	var headers: [Header] { get }
}

public extension Endpoint {
	var httpMethod: HTTPMethod { .get }
	
	var body: Codable? { nil }
	
	func constructURLRequest(baseURL: URL, authentication: Authentication? = nil) -> URLRequest? {
		var components = URLComponents()
		let logger = Logger(subsystem: "PHNetworking", category: "Endpoint")
		
		if path.starts(with: "/") {
			components.path += path
		} else {
			components.path += "/" + path
		}
		components.queryItems = []
		components.queryItems? += parameters
			.map { parameter in
				URLQueryItem(name: parameter.key, value: "\(parameter.value)")
			}
		
		if case let .apiKey(apiKey) = authentication, case let .parameter(key, value) = apiKey {
			components.queryItems?.append(URLQueryItem(name: key, value: value))
		}
		
		if components.queryItems?.isEmpty == true {
			components.queryItems = nil
		}
		
		let _baseURL: URL
		if let baseURLEndpoint = self as? BaseURLEndpoint {
			_baseURL = baseURLEndpoint.baseURL
		} else {
			_baseURL = baseURL
		}
		
		guard let url = components.url(relativeTo: _baseURL) else {
			logger.error("couldn't create url from \(components)")
			return nil
		}
				
		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = httpMethod.description
		urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
		
		if let body {
			do {
				let data = try JSONEncoder().encode(body)
				urlRequest.httpBody = data
			} catch {
				return nil
//				throw NetworkingError.invalidBodyData
			}
		}
		
		for header in headers {
			urlRequest.addValue(header.value, forHTTPHeaderField: header.field)
		}
		
		if case let .apiKey(apiKey) = authentication, case let .header(key, value) = apiKey {
			urlRequest.addValue(value, forHTTPHeaderField: key)
		}
		
		logger.info("Constructing request '\(urlRequest)'")
		return urlRequest
	}
}



