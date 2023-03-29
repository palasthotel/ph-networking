//
//  File.swift
//  
//
//  Created by Benjamin Böcker on 11.03.22.
//

import Foundation


public typealias Header = (field: String, value: String)

public protocol Endpoint {
	var path: String { get }
	var httpMethod: HTTPMethod { get }
	var parameters: [EndpointParameter] { get }
	var headers: [Header] { get }
}

public extension Endpoint {
	var httpMethod: HTTPMethod { .get }
	
	func constructURLRequest(baseURL: URL, authentication: Authentication? = nil) -> URLRequest? {
		var components = URLComponents()

		if path.starts(with: "/") {
			components.path += path
		} else {
			components.path += "/" + path
		}
		components.queryItems = []
		components.queryItems? += parameters
			.compactMap { parameter in
				parameter.query
			}
			.map { (key: String, value: Any) in
				URLQueryItem(name: key, value: "\(value)")
			}
		
		if case let .apiKey(apiKey) = authentication, case let .parameter(key, value) = apiKey {
			components.queryItems?.append(URLQueryItem(name: key, value: value))
		}
		
		if components.queryItems?.isEmpty == true {
			components.queryItems = nil
		}
		
		guard let url = components.url(relativeTo: baseURL) else {
			print("couldn't create url from \(components)")
			return nil
		}
				
		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = httpMethod.description
		urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
		
		let bodyParameters = parameters.compactMap { $0.body }
		if !bodyParameters.isEmpty {
			let body = bodyParameters
				.map { (key, value) in
					if value is String {
						return "\"\(key)\":\"\(value)\""
					} else {
						return "\"\(key)\":\(value)"
					}
				}
				.joined(separator: ",")
			urlRequest.httpBody = "{\(body)}".data(using: .utf8)
		}
		
		for header in headers {
			urlRequest.addValue(header.value, forHTTPHeaderField: header.field)
		}
		
		if case let .apiKey(apiKey) = authentication, case let .header(key, value) = apiKey {
			urlRequest.addValue(value, forHTTPHeaderField: key)
		}
		
		print("Constructing request '\(urlRequest)'")
		return urlRequest
	}
}



