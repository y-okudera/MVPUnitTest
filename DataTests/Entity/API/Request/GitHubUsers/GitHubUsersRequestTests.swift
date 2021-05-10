//
//  GitHubUsersRequestTests.swift
//  DataTests
//
//  Created by okudera on 2021/05/05.
//

@testable import Data
import Alamofire
import XCTest

final class GitHubUsersRequestTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - init(since: ) tests

    func testInit() throws {

        // Exercise SUT
        let gitHubUsersRequest = GitHubUsersRequest(since: 1)

        // Verify
        XCTAssertEqual(gitHubUsersRequest.baseURL, URL(string: "https://api.github.com")!)
        XCTAssertEqual(gitHubUsersRequest.method, .get)
        XCTAssertEqual(gitHubUsersRequest.path, "/users")
        XCTAssertEqual(gitHubUsersRequest.parameters as? [String: Int], ["since": 1])
        XCTAssertEqual(gitHubUsersRequest.encodingType, .urlEncoding)
        XCTAssertEqual(gitHubUsersRequest.httpHeaderFields, ["Accept": "application/vnd.github.v3+json"])
        XCTAssertEqual(gitHubUsersRequest.timeoutInterval, 30.0)
        XCTAssertEqual(gitHubUsersRequest.cachePolicy, .useProtocolCachePolicy)
        XCTAssertEqual(gitHubUsersRequest.allowsCellularAccess, true)

        let endPoint = URL(string: URL(string: "https://api.github.com")!.absoluteString + "/users")!
        var expectURLRequest = URLRequest(url: endPoint)
        expectURLRequest.httpMethod = HTTPMethod.get.rawValue
        expectURLRequest.allHTTPHeaderFields = ["Accept": "application/vnd.github.v3+json"]
        expectURLRequest.timeoutInterval = 30.0
        expectURLRequest.cachePolicy = .useProtocolCachePolicy
        expectURLRequest.allowsCellularAccess = true
        expectURLRequest = try! Alamofire.URLEncoding.default.encode(expectURLRequest, with: ["since": 1])

        XCTAssertEqual(gitHubUsersRequest.makeURLRequest(), expectURLRequest)
    }
}
