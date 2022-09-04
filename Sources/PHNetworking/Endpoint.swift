//
//  File.swift
//  
//
//  Created by Benjamin Böcker on 11.03.22.
//

import Foundation


public typealias Header = (field: String, value: String)

public protocol Endpoint {
	
	
	var baseURL: URL { get }
	var path: String { get }
	var httpMethod: HTTPMethod { get }
	var parameters: [EndpointParameter] { get }
	var headers: [Header] { get }
	
	/// Optional parameters that get sent with every request. This is useful for adding api keys to every request.
	var defaultParameters: [EndpointParameter] { get }
}

public extension Endpoint {
	var httpMethod: HTTPMethod { .get }
}

public extension Endpoint {
	var defaultParameters: [EndpointParameter] { [] }
}

extension Endpoint {	
	func constructURLRequest() -> URLRequest? {
		guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
			return nil
		}
		if path.starts(with: "/") {
			components.path += path
		} else {
			components.path += "/" + path
		}
		
		components.queryItems = defaultParameters
			.compactMap { parameter in
				parameter.query
			}
			.map { (key: String, value: Any) in
				URLQueryItem(name: key, value: "\(value)")
			}
		
		components.queryItems? += parameters
			.compactMap { parameter in
				parameter.query
			}
			.map { (key: String, value: Any) in
				URLQueryItem(name: key, value: "\(value)")
			}
		
		if components.queryItems?.isEmpty == true {
			components.queryItems = nil
		}
		
		guard let url = components.url else {
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
		return urlRequest

	}
}

private extension Endpoint {
	
}
