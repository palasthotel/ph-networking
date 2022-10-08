//
//  File.swift
//  
//
//  Created by Benjamin Böcker on 08.10.22.
//

import Foundation


public enum Authentication {
	case apiKey(ApiKey)
}


public extension Authentication {
	enum ApiKey {
		case parameter(key: String, value: String)
		case header(key: String, value: String)
	}
}
