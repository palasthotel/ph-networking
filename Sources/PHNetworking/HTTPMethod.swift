//
//  File.swift
//  
//
//  Created by Benjamin Böcker on 31.08.22.
//

import Foundation


public enum HTTPMethod: Equatable {
	case get, post, update, delete
	case other(String)
}

public extension HTTPMethod {
	var description: String {
		switch self {
		case .get: return "GET"
		case .post: return "POST"
		case .update: return "UPDATE"
		case .delete: return "DELETE"
		case .other(let string): return string
		}
	}
	
//	var contentType: String {
//		switch self {
//		case .get: return "application/json"
//		case .post: return "application/x-www-form-urlencoded"
//		case .update: return "application/x-www-form-urlencoded"
//		case .delete: return "application/x-www-form-urlencoded"
//		case .other: return "application/json"
//		}
//	}
}
