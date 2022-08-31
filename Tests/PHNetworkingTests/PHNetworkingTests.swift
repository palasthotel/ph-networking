import XCTest
@testable import PHNetworking

final class PHNetworkingTests: XCTestCase {
    func testExample() async throws {
		
		let testEndpoint = TestEndpoint.login
		
		let result = try await URLSession.shared.post(to: testEndpoint)
		
		print(result)
	}
}


struct TestEndpoint: Endpoint {
	var baseURL: URL
	var path: String
	var httpMethod: HTTPMethod
	var parameters: [PHNetworking.EndpointParameter]
	var headers: [PHNetworking.Header]
	
	static let login = TestEndpoint(
		baseURL: URL(string: "http://eatsmarter:dxt+2583@api.playground.eatsmarter.de/v1/json")!,
		path: "auth",
		httpMethod: .post,
		parameters: [
			.body(key: "username", value: "apps@ben-boecker.de"),
			.body(key: "password", value: "mad-dog-burrito"),
			.query(key: "api_key", value: "c7f8ab363cdb3cd405cb41f79464d7b3d8089eab")
		],
		headers: [
			Header(field: "Content-Type", value: "application/x-www-form-urlencoded")
		]
	)
	
	static let receipe = TestEndpoint(
		baseURL: URL(string: "http://eatsmarter:dxt+2583@api.playground.eatsmarter.de/v1/json")!,
		path: "node/5139",
		httpMethod: .post,
		parameters: [
			.query(key: "api_key", value: "c7f8ab363cdb3cd405cb41f79464d7b3d8089eab")
		],
		headers: [
			Header(field: "Content-Type", value: "application/json")
		]
	)
}
