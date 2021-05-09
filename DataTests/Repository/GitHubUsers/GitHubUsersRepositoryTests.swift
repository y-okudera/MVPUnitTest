//
//  GitHubUsersRepositoryTests.swift
//  DataTests
//
//  Created by okudera on 2021/05/06.
//

@testable import Data
import XCTest

typealias GetAPIResult = Result<GitHubUsersRequest.Response, APIError<GitHubUsersRequest.ErrorResponse>>

final class GitHubUsersRepositoryTests: XCTestCase {

    private var apiDataStoreSpy: GitHubUsersAPIDataStoreSpy!
    private var dbDataStoreSpy: GitHubUsersDBDataStoreSpy!
    private var repository: GitHubUsersRepositoryImpl!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
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

        // deleteCache: It is the input parameter for the function under test.
        // storedEntity: It is the result read from the dependent Database.
        // getResult: It is the processing result of the dependent API.
        typealias Input = (line: UInt, deleteCache: Bool, storedEntity: GitHubUsersCacheEntity, getResult: GetAPIResult)
        typealias Expect = (apiDataStoreSpyExpect: GitHubUsersAPIDataStoreSpy.Expect, dbDataStoreSpyExpect: GitHubUsersDBDataStoreSpy.Expect)

        let paramTest = ParameterizedTest<Input, Expect>(
            testCases: [
                (input: (line: #line, deleteCache: false, storedEntity: validCacheEntity, getResult: .success(successApiResponse)),
                 expect: (apiDataStoreSpyExpect: .init(getGitHubUsersCallCount: 0, cancelRequestCallCount: 0),
                          dbDataStoreSpyExpect: .init(addCallCount: 0, deleteCallCount: 0, deleteAllCallCount: 0, findCallCount: 1))),

                (input: (line: #line, deleteCache: false, storedEntity: validCacheEntity, getResult: .failure(apiError)),
                 expect: (apiDataStoreSpyExpect: .init(getGitHubUsersCallCount: 0, cancelRequestCallCount: 0),
                          dbDataStoreSpyExpect: .init(addCallCount: 0, deleteCallCount: 0, deleteAllCallCount: 0, findCallCount: 1))),

                (input: (line: #line, deleteCache: false, storedEntity: invalidCacheEntity, getResult: .success(successApiResponse)),
                 expect: (apiDataStoreSpyExpect: .init(getGitHubUsersCallCount: 1, cancelRequestCallCount: 0),
                          dbDataStoreSpyExpect: .init(addCallCount: 1, deleteCallCount: 1, deleteAllCallCount: 0, findCallCount: 1))),

                (input: (line: #line, deleteCache: false, storedEntity: invalidCacheEntity, getResult: .failure(apiError)),
                 expect: (apiDataStoreSpyExpect: .init(getGitHubUsersCallCount: 1, cancelRequestCallCount: 0),
                          dbDataStoreSpyExpect: .init(addCallCount: 0, deleteCallCount: 1, deleteAllCallCount: 0, findCallCount: 1))),

                (input: (line: #line, deleteCache: true, storedEntity: validCacheEntity, getResult: .success(successApiResponse)),
                 expect: (apiDataStoreSpyExpect: .init(getGitHubUsersCallCount: 1, cancelRequestCallCount: 0),
                          dbDataStoreSpyExpect: .init(addCallCount: 1, deleteCallCount: 0, deleteAllCallCount: 1, findCallCount: 0))),

                (input: (line: #line, deleteCache: true, storedEntity: validCacheEntity, getResult: .failure(apiError)),
                 expect: (apiDataStoreSpyExpect: .init(getGitHubUsersCallCount: 1, cancelRequestCallCount: 0),
                          dbDataStoreSpyExpect: .init(addCallCount: 0, deleteCallCount: 0, deleteAllCallCount: 1, findCallCount: 0))),
            ],
            expectation: expectation)

        paramTest.runTest { testCase in
            // Setup
            apiDataStoreSpy = .init(getResult: testCase.input.getResult, expect: testCase.expect.apiDataStoreSpyExpect)
            dbDataStoreSpy = .init(storedGitHubUsersCacheEntity: testCase.input.storedEntity, expect: testCase.expect.dbDataStoreSpyExpect)
            repository = .init(apiDataStore: apiDataStoreSpy, dbDataStore: dbDataStoreSpy)

            // Reset call counts before exercise.
            apiDataStoreSpy.resetCallCounts()
            dbDataStoreSpy.resetCallCounts()

            // Exercise SUT
            repository.getGitHubUsers(since: 0, currentDate: currentDate, refreshInterval: refreshInterval, deleteCache: testCase.input.deleteCache) { [unowned self] _ in
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

        // storedEntity: It is the result read from the dependent Database.
        // getResult: It is the processing result of the dependent API.
        typealias Input = (line: UInt, storedEntity: GitHubUsersCacheEntity, getResult: GetAPIResult)
        typealias Expect = (apiDataStoreSpyExpect: GitHubUsersAPIDataStoreSpy.Expect, dbDataStoreSpyExpect: GitHubUsersDBDataStoreSpy.Expect)

        let paramTest = ParameterizedTest<Input, Expect>(
            testCases: [
                (input: (line: #line, storedEntity: invalidCacheEntity, getResult: .success(successApiResponse)),
                 expect: (apiDataStoreSpyExpect: .init(getGitHubUsersCallCount: 0, cancelRequestCallCount: 1),
                          dbDataStoreSpyExpect: .init(addCallCount: 0, deleteCallCount: 0, deleteAllCallCount: 0, findCallCount: 0))),
            ],
            expectation: expectation)

        paramTest.runTest { testCase in
            // Setup
            apiDataStoreSpy = .init(getResult: testCase.input.getResult, expect: testCase.expect.apiDataStoreSpyExpect)
            dbDataStoreSpy = .init(storedGitHubUsersCacheEntity: testCase.input.storedEntity, expect: testCase.expect.dbDataStoreSpyExpect)
            repository = .init(apiDataStore: apiDataStoreSpy, dbDataStore: dbDataStoreSpy)

            // Reset call counts before exercise.
            apiDataStoreSpy.resetCallCounts()
            dbDataStoreSpy.resetCallCounts()

            // Exercise SUT
            repository.cancelRequest()

            // Verify
            apiDataStoreSpy.verify(line: testCase.input.line)
            dbDataStoreSpy.verify(line: testCase.input.line)
        }
    }
}

extension GitHubUsersRepositoryTests {

    private var currentDate: Date {
        Date.now(dateGenerator: { DateGenerator.generate(dateString: "20210509120000") })
    }

    private var refreshInterval: TimeInterval {
        60 * 30
    }

    private var validCacheEntity: GitHubUsersCacheEntity {
        let lastModified = Date(timeInterval: -refreshInterval + 1, since: currentDate)
        return GitHubUsersCacheEntity(since: 0, lastModified: lastModified, response: [.testObject])
    }

    private var invalidCacheEntity: GitHubUsersCacheEntity {
        let lastModified = Date(timeInterval: -refreshInterval - 1, since: currentDate)
        return GitHubUsersCacheEntity(since: 0, lastModified: lastModified, response: [.testObject])
    }

    private var successApiResponse: GitHubUsersRequest.Response {
        [.testObject, .testOtherObject]
    }

    private var apiError: APIError<GitHubUsersRequest.ErrorResponse> {
        .connectionError
    }
}

// MARK: - Spy

final class GitHubUsersAPIDataStoreSpy: GitHubUsersAPIDataStore {

    struct Expect {
        private(set) var getGitHubUsersCallCount: Int
        private(set) var cancelRequestCallCount: Int

        init(getGitHubUsersCallCount: Int, cancelRequestCallCount: Int) {
            self.getGitHubUsersCallCount = getGitHubUsersCallCount
            self.cancelRequestCallCount = cancelRequestCallCount
        }
    }

    private var getGitHubUsersCallCount: Int = 0
    private var cancelRequestCallCount: Int = 0
    private var getResult: GetAPIResult

    private var expect: Expect

    init(getResult: GetAPIResult, expect: Expect) {
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

    // Reset call counts

    func resetCallCounts() {
        getGitHubUsersCallCount = 0
        cancelRequestCallCount = 0
    }

    // Verify
    func verify(line: UInt) {
        XCTAssertEqual(getGitHubUsersCallCount, expect.getGitHubUsersCallCount, "getGitHubUsersCallCount", line: line)
        XCTAssertEqual(cancelRequestCallCount, expect.cancelRequestCallCount, "cancelRequestCallCount", line: line)
    }
}

final class GitHubUsersDBDataStoreSpy: GitHubUsersDBDataStore {

    struct Expect {
        private(set) var addCallCount: Int
        private(set) var deleteCallCount: Int
        private(set) var deleteAllCallCount: Int
        private(set) var findCallCount: Int

        init(addCallCount: Int, deleteCallCount: Int, deleteAllCallCount: Int, findCallCount: Int) {
            self.addCallCount = addCallCount
            self.deleteCallCount = deleteCallCount
            self.deleteAllCallCount = deleteAllCallCount
            self.findCallCount = findCallCount
        }
    }

    private var addCallCount: Int = 0
    private var deleteCallCount: Int = 0
    private var deleteAllCallCount: Int = 0
    private var findCallCount: Int = 0

    private var storedGitHubUsersCacheEntity: GitHubUsersCacheEntity
    private var expect: Expect

    init(storedGitHubUsersCacheEntity: GitHubUsersCacheEntity, expect: Expect) {
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

    // Reset call counts

    func resetCallCounts() {
        addCallCount = 0
        deleteCallCount = 0
        deleteAllCallCount = 0
        findCallCount = 0
    }

    // Verify
    func verify(line: UInt) {
        XCTAssertEqual(addCallCount, expect.addCallCount, "addCallCount", line: line)
        XCTAssertEqual(deleteCallCount, expect.deleteCallCount, "deleteCallCount", line: line)
        XCTAssertEqual(deleteAllCallCount, expect.deleteAllCallCount, "deleteAllCallCount", line: line)
        XCTAssertEqual(findCallCount, expect.findCallCount, "findCallCount", line: line)
    }
}
