//
//  File.swift
//  
//
//  Created by Benjamin Böcker on 01.10.22.
//

import Foundation
import OSLog


public protocol APIService {
	var baseURL: URL { get }
	var authentication: Authentication? { get }
	var useDataCache: Bool { get }
}

public extension APIService {
	var authentication: Authentication? { nil }
	var useDataCache: Bool { false }
	
	func performCachedRequest<T: Decodable>(to endpoint: Endpoint, using decoder: JSONDecoder = .init()) async throws -> T {
		guard
			let request = endpoint.constructURLRequest(baseURL: baseURL, authentication: authentication),
			let url = request.url
		else {
			throw NetworkingError.invalidEndpoint
		}
		
		do {
			let data: Data
			if let cachedData = await DataCache.shared.get(url) {
				data = cachedData
			} else {
				data = try await performRequest(to: endpoint, using: decoder)
			}
			
			return try decoder.decode(T.self, from: data)
		} catch {
			throw error
		}
	}

	func performRequest<T: Decodable>(
		to endpoint: Endpoint,
		using decoder: JSONDecoder = .init(),
		logResponse: Bool = false
	) async throws -> T {
		guard let request = endpoint.constructURLRequest(baseURL: baseURL, authentication: authentication) else {
			throw NetworkingError.invalidEndpoint
		}

		do {
			let logger = Logger(subsystem: "PHNetworking", category: "APIService")
			logger.info("Perform call to \(request.url?.absoluteString ?? "")")

			let data = try await URLSession.shared.data(for: request)

			if let response = data.1 as? HTTPURLResponse, response.statusCode != 200 {
				logger.error("\(response)")
				throw NetworkingError.status(code: response.statusCode, message: String(data: data.0, encoding: .utf8))
			} else if logResponse {
				logger.info("\(String(data: data.0, encoding: .utf8) ?? "")")
			}
			
			if useDataCache, let url = request.url {
				await DataCache.shared.set(data.0, for: url)
			}
			
			let decoded = try decoder.decode(T.self, from: data.0)
			return decoded
		} catch {
			throw error
		}
	}
	
	func performRequest(to endpoint: Endpoint, using decoder: JSONDecoder = .init(), logResponse: Bool = false) async throws {
		guard let request = endpoint.constructURLRequest(baseURL: baseURL, authentication: authentication) else {
			throw NetworkingError.invalidEndpoint
		}
		
		do {
			let logger = Logger(subsystem: "PHNetworking", category: "APIService")
			logger.info("Perform call to \(request.url?.absoluteString ?? "")")
			let data = try await URLSession.shared.data(for: request)

			if let response = data.1 as? HTTPURLResponse, response.statusCode != 200 {
				logger.error("\(response)")
				throw NetworkingError.status(code: response.statusCode, message: String(data: data.0, encoding: .utf8))
			} else if logResponse {
				logger.info("\(String(data: data.0, encoding: .utf8) ?? "")")
			}
		} catch {
			throw error
		}
	}
}



