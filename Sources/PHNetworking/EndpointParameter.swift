//
//  File.swift
//  
//
//  Created by Benjamin Böcker on 11.03.22.
//

import Foundation


public enum EndpointParameter {
	case query(key: String, value: Any)
	case body(key: String, value: Any)
}

extension EndpointParameter {
	var query: (key: String, value: Any)? {
		guard case let .query(key, value) = self else {
			return nil
		}
		return (key: key, value: value)
	}
	
	var body: (key: String, value: Any)? {
		guard case let .body(key, value) = self else {
			return nil
		}
		return (key: key, value: value)
	}
}
