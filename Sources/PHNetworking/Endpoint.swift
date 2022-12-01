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
		
		let body = parameters
			.compactMap { param -> String? in
				guard let body = param.body,
					  let key = "\(body.key)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
					  let value = "\(body.value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
				else { return nil }
				return "\(key)=\(value)"
			}
			.joined(separator: "&")
		urlRequest.httpBody = body.data(using: .utf8)
		
		for header in headers {
			urlRequest.addValue(header.value, forHTTPHeaderField: header.field)
		}
		
		if case let .apiKey(apiKey) = authentication, case let .header(key, value) = apiKey {
			urlRequest.addValue(value, forHTTPHeaderField: key)
		}
		
		return urlRequest
	}
}



