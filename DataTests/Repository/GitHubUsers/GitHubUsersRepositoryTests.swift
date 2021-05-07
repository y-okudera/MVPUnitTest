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
typealias GitHubUsersDBDataStoreSpyExpect = (addCallCount: Int, deleteCallCount: Int, deleteAllCallCount: Int, findCallCount: Int)

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
        let description = "If there is a valid cache, get it from the cache, if not, request to server. If the deleteCache flag is true, delete the cache and then request to server."
        let expectation = XCTestExpectation(description: description)

        typealias Input = (line: UInt, deleteCache: Bool, storedEntity: GitHubUsersCacheEntity, getResult: GetAPIResult)
        typealias Expect = (apiDataStoreSpyExpect: GitHubUsersAPIDataStoreSpyExpect, dbDataStoreSpyExpect: GitHubUsersDBDataStoreSpyExpect)

        let paramTest = ParameterizedTest<Input, Expect>(
            testCases: [
                (input: (line: #line, deleteCache: false, storedEntity: validCacheEntity, getResult: .success([.testObject, .testOtherObject])),
                 expect: (apiDataStoreSpyExpect: (getGitHubUsersCallCount: 0, cancelRequestCallCount: 0),
                          dbDataStoreSpyExpect: (addCallCount: 0, deleteCallCount: 0, deleteAllCallCount: 0, findCallCount: 1))),

                (input: (line: #line, deleteCache: false, storedEntity: validCacheEntity, getResult: .failure(.connectionError)),
                 expect: (apiDataStoreSpyExpect: (getGitHubUsersCallCount: 0, cancelRequestCallCount: 0),
                          dbDataStoreSpyExpect: (addCallCount: 0, deleteCallCount: 0, deleteAllCallCount: 0, findCallCount: 1))),

                (input: (line: #line, deleteCache: false, storedEntity: invalidCacheEntity, getResult: .success([.testObject, .testOtherObject])),
                 expect: (apiDataStoreSpyExpect: (getGitHubUsersCallCount: 1, cancelRequestCallCount: 0),
                          dbDataStoreSpyExpect: (addCallCount: 1, deleteCallCount: 1, deleteAllCallCount: 0, findCallCount: 1))),

                (input: (line: #line, deleteCache: false, storedEntity: invalidCacheEntity, getResult: .failure(.connectionError)),
                 expect: (apiDataStoreSpyExpect: (getGitHubUsersCallCount: 1, cancelRequestCallCount: 0),
                          dbDataStoreSpyExpect: (addCallCount: 0, deleteCallCount: 1, deleteAllCallCount: 0, findCallCount: 1))),

                (input: (line: #line, deleteCache: true, storedEntity: validCacheEntity, getResult: .success([.testObject, .testOtherObject])),
                 expect: (apiDataStoreSpyExpect: (getGitHubUsersCallCount: 1, cancelRequestCallCount: 0),
                          dbDataStoreSpyExpect: (addCallCount: 1, deleteCallCount: 0, deleteAllCallCount: 1, findCallCount: 0))),

                (input: (line: #line, deleteCache: true, storedEntity: validCacheEntity, getResult: .failure(.connectionError)),
                 expect: (apiDataStoreSpyExpect: (getGitHubUsersCallCount: 1, cancelRequestCallCount: 0),
                          dbDataStoreSpyExpect: (addCallCount: 0, deleteCallCount: 0, deleteAllCallCount: 1, findCallCount: 0))),
            ],
            expectation: expectation)

        paramTest.runTest { testCase in
            // Setup
            apiDataStoreSpy = .init(getResult: testCase.input.getResult, expect: testCase.expect.apiDataStoreSpyExpect)
            dbDataStoreSpy = .init(storedGitHubUsersCacheEntity: testCase.input.storedEntity, expect: testCase.expect.dbDataStoreSpyExpect)
            repository = .init(apiDataStore: apiDataStoreSpy, dbDataStore: dbDataStoreSpy)

            // Exercise SUT
            repository.getGitHubUsers(since: 0, refreshInterval: defaultRefreshInterval, deleteCache: testCase.input.deleteCache) { [unowned self] getResult in
                // Verify
                apiDataStoreSpy.verify(line: testCase.input.line)
                dbDataStoreSpy.verify(line: testCase.input.line)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 6.0)
    }

    /// Cancelled api request test.
    func testCancelRequest() {

        // Expect
        let expectation = XCTestExpectation(description: "Cancelled api request.")

        typealias Input = (line: UInt, storedEntity: GitHubUsersCacheEntity, getResult: GetAPIResult)
        typealias Expect = (apiDataStoreSpyExpect: GitHubUsersAPIDataStoreSpyExpect, dbDataStoreSpyExpect: GitHubUsersDBDataStoreSpyExpect)

        let paramTest = ParameterizedTest<Input, Expect>(
            testCases: [
                (input: (line: #line, storedEntity: validCacheEntity, getResult: .success([.testObject, .testOtherObject])),
                 expect: (apiDataStoreSpyExpect: (getGitHubUsersCallCount: 0, cancelRequestCallCount: 1),
                          dbDataStoreSpyExpect: (addCallCount: 0, deleteCallCount: 0, deleteAllCallCount: 0, findCallCount: 0))),
            ],
            expectation: expectation)

        paramTest.runTest { testCase in
            // Setup
            apiDataStoreSpy = .init(getResult: testCase.input.getResult, expect: testCase.expect.apiDataStoreSpyExpect)
            dbDataStoreSpy = .init(storedGitHubUsersCacheEntity: testCase.input.storedEntity, expect: testCase.expect.dbDataStoreSpyExpect)
            repository = .init(apiDataStore: apiDataStoreSpy, dbDataStore: dbDataStoreSpy)

            // Exercise SUT
            repository.cancelRequest()

            // Verify
            apiDataStoreSpy.verify(line: testCase.input.line)
            dbDataStoreSpy.verify(line: testCase.input.line)
        }
    }
}

extension GitHubUsersRepositoryTests {
    var defaultRefreshInterval: TimeInterval {
        60 * 30
    }

    var validCacheEntity: GitHubUsersCacheEntity {
        .init(since: 0, lastModified: Date(timeIntervalSinceNow: -defaultRefreshInterval + 1), response: [.testObject])
    }

    var invalidCacheEntity: GitHubUsersCacheEntity {
        .init(since: 0, lastModified: Date(timeIntervalSinceNow: -defaultRefreshInterval - 1), response: [.testObject])
    }
}

// MARK: - Spy

final class GitHubUsersAPIDataStoreSpy: GitHubUsersAPIDataStore {

    private var getGitHubUsersCallCount: Int = 0
    private var cancelRequestCallCount: Int = 0
    private var getResult: GetAPIResult

    private var expect: GitHubUsersAPIDataStoreSpyExpect

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

    private var addCallCount: Int = 0
    private var deleteCallCount: Int = 0
    private var deleteAllCallCount: Int = 0
    private var findCallCount: Int = 0

    private var storedGitHubUsersCacheEntity: GitHubUsersCacheEntity
    private var expect: GitHubUsersDBDataStoreSpyExpect

    init(storedGitHubUsersCacheEntity: GitHubUsersCacheEntity, expect: GitHubUsersDBDataStoreSpyExpect) {
        self.storedGitHubUsersCacheEntity = storedGitHubUsersCacheEntity
        self.expect = expect
    }

    func add(entity: GitHubUsersCacheEntity, completion: Completion?) {
        addCallCount += 1
    }

    func delete(since: Int, completion: Completion?) {
        deleteCallCount += 1
    }

    func deleteAll(completion: Completion?) {
        deleteAllCallCount += 1
    }

    func find(since: Int) -> GitHubUsersCacheEntity? {
        findCallCount += 1
        return storedGitHubUsersCacheEntity
    }

    // Verify
    func verify(line: UInt) {
        XCTAssertEqual(addCallCount, expect.addCallCount, "addCallCount", line: line)
        XCTAssertEqual(deleteCallCount, expect.deleteCallCount, "deleteCallCount", line: line)
        XCTAssertEqual(deleteAllCallCount, expect.deleteAllCallCount, "deleteAllCallCount", line: line)
        XCTAssertEqual(findCallCount, expect.findCallCount, "findCallCount", line: line)
    }
}
