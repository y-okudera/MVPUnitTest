//
//  GitHubUsersTranslatorTests.swift
//  DomainTests
//
//  Created by okudera on 2021/05/07.
//

@testable import Domain
import XCTest

final class GitHubUsersTranslatorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - static func translate(_ entity: ) -> HomeViewData tests

    func testTranslate() throws {

        // Exercise SUT
        let homeViewData = GitHubUsersTranslator.translate([.testObject])

        // Verify
        XCTAssertEqual(homeViewData.data.count, 1)
        XCTAssertEqual(homeViewData.data[0].id, 1)
        XCTAssertEqual(homeViewData.data[0].name, "mojombo")
        XCTAssertEqual(homeViewData.data[0].thumbnailUrl, URL(string: "https://avatars.githubusercontent.com/u/1?v=4"))
        XCTAssertEqual(homeViewData.data[0].htmlUrl, "https://github.com/mojombo")
        XCTAssertEqual(homeViewData.data[0].reposUrl, "https://api.github.com/users/mojombo/repos")
    }
}
