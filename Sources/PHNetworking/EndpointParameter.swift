//
//  File.swift
//  
//
//  Created by Benjamin Böcker on 11.03.22.
//

import Foundation


public struct EndpointParameter {
	let key: String
	let value: Any
}

public extension EndpointParameter {
	static func query(key: String, value: Any) -> EndpointParameter {
		EndpointParameter(key: key, value: value)
	}
}
