//
//  DataCache.swift
//  PHNetworking
//
//  Created by Benjamin Böcker on 28.09.24.
//

import Foundation
import OSLog


actor DataCache {
	struct CachedData: Codable {
		let date: Date
		let data: Data
	}

	static let shared = DataCache()
	
	private var cache: [URL: CachedData] = [:]
	private let expirationInterval: TimeInterval
	private let logger = Logger(subsystem: "PHNetworking", category: "DataCache")
	private static let defaultExpirationInterval: TimeInterval = 60 * 60 * 24 * 28
	
	private init(expirationInterval: TimeInterval = DataCache.defaultExpirationInterval) {
		self.expirationInterval = expirationInterval
		cache = getCache()
	}
	
	func set(_ data: Data, for url: URL) {
		cache[url] = CachedData(date: .now, data: data)
		saveCache()
	}
	
	func get(_ url: URL) -> Data? {
		cache[url]?.data
	}
}

private extension DataCache {
	func saveCache() {
		do {
			let encoded = try JSONEncoder().encode(cache)
			try encoded.write(to: try fileURL)
		} catch {
			logger.error("\(error)")
		}
	}
	
	func getCache() -> [URL: CachedData] {
		do {
			let data = try Data(contentsOf: try fileURL)
			let decoded = try JSONDecoder().decode([URL: CachedData].self, from: data)
			return decoded
		} catch {
			return [:]
		}
	}
	
	var fileURL: URL {
		get throws {
			try FileManager.default
				.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
				.appendingPathComponent("data-cache.json")
		}
	}
}
