//
//  File.swift
//  
//
//  Created by Benjamin Böcker on 11.03.22.
//

import Foundation


public enum NetworkingError: LocalizedError {
	case invalidEndpoint
	case status(code: Int, message: String?)
	case emptyData
	case invalidBodyData
	case decodingError(message: String)

	public var errorDescription: String? {
		switch self {
			case .invalidBodyData: return "body data could not be encoded (not codable?)"
			case .invalidEndpoint: return "invalid endpoint specified"
			case .status(let code, let message): return "status code \(code), message: \(message ?? "-")"
			case .emptyData: return "returned data was nil"
			case .decodingError(let message): return "decoding error: \(message)"
		}
		
	}
}
