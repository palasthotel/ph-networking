//
//  File.swift
//  
//
//  Created by Benjamin Böcker on 11.03.22.
//

import Foundation


public enum NetworkingError: LocalizedError {
	case invalidEndpoint
	case status(code: Int)
	case emptyData
	case decodingError(message: String)

	public var errorDescription: String? {
		switch self {
		case .invalidEndpoint: return "invalid endpoint specified"
		case .status(let code): return "status code \(code)"
		case .emptyData: return "returned data was nil"
		case .decodingError(let message): return "decoding error: \(message)"
		}
		
	}
}
