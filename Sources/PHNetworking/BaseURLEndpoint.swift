//
//  File.swift
//  
//
//  Created by Benjamin Böcker on 01.10.22.
//

import Foundation


public protocol BaseURLEndpoint: Endpoint {
	var baseURL: URL { get }
}
