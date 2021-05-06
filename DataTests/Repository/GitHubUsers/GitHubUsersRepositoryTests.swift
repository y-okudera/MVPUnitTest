//
//  GitHubUsersRepositoryTests.swift
//  DataTests
//
//  Created by okudera on 2021/05/06.
//

@testable import Data
import XCTest

typealias GetAPIResult = Result<GitHubUsersRequest.Response, APIError<GitHubUsersRequest.ErrorResponse>>
typealias GitHubUsersAPIDataStoreSpyExpect = (getGitHubUsersCallCount: Int, cancelRequestCallCount: Int)

typealias GitHubUsersDBDataStoreSpyExpect = (addEntityCallCount: Int, deleteEntityCallCount: Int, deleteAllEntitiesCallCount: Int, findEntityCallCount: Int)

final class GitHubUsersRepositoryTests: XCTestCase {

    private var apiDataStoreSpy: GitHubUsersAPIDataStoreSpy!
    private var dbDataStoreSpy: GitHubUsersDBDataStoreSpy!
    private var repository: GitHubUsersRepositoryImpl!

    override func setUpWithError() throws {
        apiDataStoreSpy = nil
        dbDataStoreSpy = nil
        repository = nil
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - func add(entity: , completion: ) tests

    /// Get GitHubUsers test.
    /// Expectation:
    /// If there is a valid cache, get it from the cache, if not, request to server.
    /// If the deleteCache flag is true, delete the cache and then request to server.
    func testGetGitHubUsers() {
        // Expect
        let expectation = XCTestExpectation(description: "If there is a valid cache, get it from the cache, if not, request to server. If the deleteCache flag is true, delete the cache and then request to server.")

        typealias TestCase = (
            line: UInt,
            deleteCache: Bool,
            storedEntity: GitHubUsersCacheEntity,
            getResult: GetAPIResult,
            apiDataStoreSpyExpect: GitHubUsersAPIDataStoreSpyExpect,
            dbDataStoreSpyExpect: GitHubUsersDBDataStoreSpyExpect
        )

        let defaultRefreshInterval: TimeInterval = 60 * 30
        let validCacheEntity = GitHubUsersCacheEntity(
            since: 0,
            lastModified: Date(timeIntervalSinceNow: -defaultRefreshInterval + 1),
            response: [.testObject]
        )
        let invalidCacheEntity = GitHubUsersCacheEntity(
            since: 0,
            lastModified: Date(timeIntervalSinceNow: -defaultRefreshInterval - 1),
            response: [.testObject]
        )

        let testCases: [TestCase] = [
            (
                #line,
                false,
                validCacheEntity,
                .success([.testObject, .testOtherObject]),
                (getGitHubUsersCallCount: 0, cancelRequestCallCount: 0),
                (addEntityCallCount: 0, deleteEntityCallCount: 0, deleteAllEntitiesCallCount: 0, findEntityCallCount: 1)
            ),
            (
                #line,
                false,
                validCacheEntity,
                .failure(.connectionError),
                (getGitHubUsersCallCount: 0, cancelRequestCallCount: 0),
                (addEntityCallCount: 0, deleteEntityCallCount: 0, deleteAllEntitiesCallCount: 0, findEntityCallCount: 1)
            ),
            (
                #line,
                false,
                invalidCacheEntity,
                .success([.testObject, .testOtherObject]),
                (getGitHubUsersCallCount: 1, cancelRequestCallCount: 0),
                (addEntityCallCount: 1, deleteEntityCallCount: 1, deleteAllEntitiesCallCount: 0, findEntityCallCount: 1)
            ),
            (
                #line,
                false,
                invalidCacheEntity,
                .failure(.connectionError),
                (getGitHubUsersCallCount: 1, cancelRequestCallCount: 0),
                (addEntityCallCount: 0, deleteEntityCallCount: 1, deleteAllEntitiesCallCount: 0, findEntityCallCount: 1)
            ),
            (
                #line,
                true,
                validCacheEntity,
                .success([.testObject, .testOtherObject]),
                (getGitHubUsersCallCount: 1, cancelRequestCallCount: 0),
                (addEntityCallCount: 1, deleteEntityCallCount: 0, deleteAllEntitiesCallCount: 1, findEntityCallCount: 0)
            ),
            (
                #line,
                true,
                validCacheEntity,
                .failure(.connectionError),
                (getGitHubUsersCallCount: 1, cancelRequestCallCount: 0),
                (addEntityCallCount: 0, deleteEntityCallCount: 0, deleteAllEntitiesCallCount: 1, findEntityCallCount: 0)
            ),
        ]

        expectation.expectedFulfillmentCount = testCases.count

        for (line, deleteCache, storedEntity, getResult, apiDataStoreSpyExpect, dbDataStoreSpyExpect) in testCases {
            // Setup
            apiDataStoreSpy = .init(getResult: getResult, expect: apiDataStoreSpyExpect)
            dbDataStoreSpy = .init(storedGitHubUsersCacheEntity: storedEntity, expect: dbDataStoreSpyExpect)
            repository = .init(apiDataStore: apiDataStoreSpy, dbDataStore: dbDataStoreSpy)

            // Exercise SUT
            repository.getGitHubUsers(since: 0, refreshInterval: defaultRefreshInterval, deleteCache: deleteCache) { [unowned self] getResult in
                // Verify
                apiDataStoreSpy.verify(line: line)
                dbDataStoreSpy.verify(line: line)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 6.0)
    }

    /// Cancelled api request test.
    func testCancelRequest() {
        // Expect
        let expectation = XCTestExpectation(description: "Cancelled api request.")

        typealias TestCase = (
            line: UInt,
            storedEntity: GitHubUsersCacheEntity,
            getResult: GetAPIResult,
            apiDataStoreSpyExpect: GitHubUsersAPIDataStoreSpyExpect,
            dbDataStoreSpyExpect: GitHubUsersDBDataStoreSpyExpect
        )

        let defaultRefreshInterval: TimeInterval = 60 * 30
        let validCacheEntity = GitHubUsersCacheEntity(
            since: 0,
            lastModified: Date(timeIntervalSinceNow: -defaultRefreshInterval + 1),
            response: [.testObject]
        )

        let testCases: [TestCase] = [
            (
                #line,
                validCacheEntity,
                .success([.testObject, .testOtherObject]),
                (getGitHubUsersCallCount: 0, cancelRequestCallCount: 1),
                (addEntityCallCount: 0, deleteEntityCallCount: 0, deleteAllEntitiesCallCount: 0, findEntityCallCount: 0)
            )
        ]

        for (line, storedEntity, getResult, apiDataStoreSpyExpect, dbDataStoreSpyExpect) in testCases {
            // Setup
            apiDataStoreSpy = .init(getResult: getResult, expect: apiDataStoreSpyExpect)
            dbDataStoreSpy = .init(storedGitHubUsersCacheEntity: storedEntity, expect: dbDataStoreSpyExpect)
            repository = .init(apiDataStore: apiDataStoreSpy, dbDataStore: dbDataStoreSpy)

            // Exercise SUT
            repository.cancelRequest()

            // Verify
            apiDataStoreSpy.verify(line: line)
            dbDataStoreSpy.verify(line: line)
        }
    }
}

// MARK: - Spy

final class GitHubUsersAPIDataStoreSpy: GitHubUsersAPIDataStore {

    var getGitHubUsersCallCount: Int = 0
    var cancelRequestCallCount: Int = 0
    var getResult: GetAPIResult

    var expect: GitHubUsersAPIDataStoreSpyExpect

    init(getResult: GetAPIResult, expect: GitHubUsersAPIDataStoreSpyExpect) {
        self.getResult = getResult
        self.expect = expect
    }

    func getGitHubUsers(since: Int, completion: @escaping Completion) {
        getGitHubUsersCallCount += 1
        completion(getResult)
    }

    func cancelRequest() {
        cancelRequestCallCount += 1
    }

    // Verify
    func verify(line: UInt) {
        XCTAssertEqual(getGitHubUsersCallCount, expect.getGitHubUsersCallCount, "getGitHubUsersCallCount", line: line)
        XCTAssertEqual(cancelRequestCallCount, expect.cancelRequestCallCount, "cancelRequestCallCount", line: line)
    }
}

final class GitHubUsersDBDataStoreSpy: GitHubUsersDBDataStore {

    var addEntityCallCount: Int = 0
    var deleteEntityCallCount: Int = 0
    var deleteAllEntitiesCallCount: Int = 0
    var findEntityCallCount: Int = 0

    var storedGitHubUsersCacheEntity: GitHubUsersCacheEntity
    var expect: GitHubUsersDBDataStoreSpyExpect

    init(storedGitHubUsersCacheEntity: GitHubUsersCacheEntity, expect: GitHubUsersDBDataStoreSpyExpect) {
        self.storedGitHubUsersCacheEntity = storedGitHubUsersCacheEntity
        self.expect = expect
    }

    func add(entity: GitHubUsersCacheEntity, completion: Completion?) {
        addEntityCallCount += 1
    }

    func delete(since: Int, completion: Completion?) {
        deleteEntityCallCount += 1
    }

    func deleteAll(completion: Completion?) {
        deleteAllEntitiesCallCount += 1
    }

    func find(since: Int) -> GitHubUsersCacheEntity? {
        findEntityCallCount += 1
        return storedGitHubUsersCacheEntity
    }

    // Verify
    func verify(line: UInt) {
        XCTAssertEqual(addEntityCallCount, expect.addEntityCallCount, "addEntityCallCount", line: line)
        XCTAssertEqual(deleteEntityCallCount, expect.deleteEntityCallCount, "deleteEntityCallCount", line: line)
        XCTAssertEqual(deleteAllEntitiesCallCount, expect.deleteAllEntitiesCallCount, "deleteAllEntitiesCallCount", line: line)
        XCTAssertEqual(findEntityCallCount, expect.findEntityCallCount, "findEntityCallCount", line: line)
    }
}
