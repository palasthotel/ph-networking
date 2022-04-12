//
//  File.swift
//  
//
//  Created by Benjamin Böcker on 11.03.22.
//

import Foundation


public extension URLSession {
	@available(iOS 13.0.0, *)
	func downloadData(from endpoint: Endpoint) async throws -> Data {
		return try await withCheckedThrowingContinuation { continuation in
			self.downloadData(from: endpoint) { result in
				switch result {
				case .failure(let error):
					continuation.resume(throwing: error)
				case .success(let data):
					continuation.resume(returning: data)
				}
			}
		}
	}
	
	func downloadData(from endpoint: Endpoint, completion: @escaping (Result<Data, Error>) -> Void) {
		guard let request = endpoint.constructURLRequest() else {
			completion(.failure(NetworkingError.invalidEndpoint))
			return
		}
		
		self.dataTask(with: request) { data, response, error in
			if let error = error {
				completion(.failure(error))
			} else if let response = response as? HTTPURLResponse, response.statusCode > 300 {
				completion(.failure(NetworkingError.status(code: response.statusCode)))
			} else if let data = data {
				completion(.success(data))
			} else {
				completion(.failure(NetworkingError.emptyData))
			}
		}.resume()
	}
	
	@available(iOS 13.0.0, *)
	func downloadData<T: Decodable>(from endpoint: Endpoint, using decoder: JSONDecoder = JSONDecoder()) async throws -> T {
		return try await withCheckedThrowingContinuation { continuation in
			self.downloadData(from: endpoint, using: decoder) { (result: Result<T, Error>) in
				switch result {
				case .failure(let error): continuation.resume(throwing: error)
				case .success(let data): continuation.resume(returning: data)
				}
			}
		}
	}
	
	func downloadData<T: Decodable>(from endpoint: Endpoint, using decoder: JSONDecoder = JSONDecoder(), completion: @escaping (Result<T, Error>) -> Void) {
		downloadData(from: endpoint) { result in
			switch result {
			case .failure(let error):
				completion(.failure(error))
			case .success(let data):
				do {
					let decoded = try decoder.decode(T.self, from: data)
					completion(.success(decoded))
				} catch {
					print(error)
					completion(.failure(NetworkingError.decodingError(message: error.localizedDescription)))
				}
			}
		}
	}
}
