//
//  File.swift
//  
//
//  Created by Benjamin Böcker on 01.10.22.
//

import Foundation


public protocol APIService {
	var baseURL: URL { get }
	var authentication: Authentication? { get }
}

public extension APIService {
	var authentication: Authentication? { nil }
	
	func performRequest<T: Decodable>(to endpoint: Endpoint, using decoder: JSONDecoder = .init()) async throws -> T {
		guard let request = endpoint.constructURLRequest(baseURL: baseURL, authentication: authentication) else {
			throw NetworkingError.invalidEndpoint
		}

		do {
			let data = try await URLSession.shared.data(for: request)

			if let response = data.1 as? HTTPURLResponse, response.statusCode != 200 {
				print(response)
				throw NetworkingError.status(code: response.statusCode)
			}

			let decoded = try decoder.decode(T.self, from: data.0)
			return decoded
		} catch {
			print("\(error)")
			throw error
		}
	}
	
	func performRequest(to endpoint: Endpoint, using decoder: JSONDecoder = .init()) async throws {
		guard let request = endpoint.constructURLRequest(baseURL: baseURL, authentication: authentication) else {
			throw NetworkingError.invalidEndpoint
		}

		do {
			let data = try await URLSession.shared.data(for: request)

			if let response = data.1 as? HTTPURLResponse, response.statusCode != 200 {
				print(response)
				throw NetworkingError.status(code: response.statusCode)
			}
		} catch {
			print("\(error)")
			throw error
		}
	}
}



