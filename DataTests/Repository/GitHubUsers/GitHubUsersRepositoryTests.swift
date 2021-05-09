//
//  GitHubUsersRepositoryTests.swift
//  DataTests
//
//  Created by okudera on 2021/05/06.
//

@testable import Data
import Common
import XCTest

typealias GetAPIResult = Result<GitHubUsersRequest.Response, APIError<GitHubUsersRequest.ErrorResponse>>
let AddToDBIsCompletion = Notification.Name("AddToDBIsCompletion")

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
                 expect: (apiDataStoreSpyExpect: .init(getGitHubUsersArgs: [], cancelRequestArgs: []),
                          dbDataStoreSpyExpect: .init(addArgs: [], deleteArgs: [], deleteAllArgs: [], findArgs: [since]))),

                (input: (line: #line, deleteCache: false, storedEntity: validCacheEntity, getResult: .failure(apiError)),
                 expect: (apiDataStoreSpyExpect: .init(getGitHubUsersArgs: [], cancelRequestArgs: []),
                          dbDataStoreSpyExpect: .init(addArgs: [], deleteArgs: [], deleteAllArgs: [], findArgs: [since]))),

                (input: (line: #line, deleteCache: false, storedEntity: invalidCacheEntity, getResult: .success(successApiResponse)),
                 expect: (apiDataStoreSpyExpect: .init(getGitHubUsersArgs: [since], cancelRequestArgs: []),
                          dbDataStoreSpyExpect: .init(addArgs: [cacheEntity], deleteArgs: [since], deleteAllArgs: [], findArgs: [since]))),

                (input: (line: #line, deleteCache: false, storedEntity: invalidCacheEntity, getResult: .failure(apiError)),
                 expect: (apiDataStoreSpyExpect: .init(getGitHubUsersArgs: [since], cancelRequestArgs: []),
                          dbDataStoreSpyExpect: .init(addArgs: [], deleteArgs: [since], deleteAllArgs: [], findArgs: [since]))),

                (input: (line: #line, deleteCache: true, storedEntity: validCacheEntity, getResult: .success(successApiResponse)),
                 expect: (apiDataStoreSpyExpect: .init(getGitHubUsersArgs: [since], cancelRequestArgs: []),
                          dbDataStoreSpyExpect: .init(addArgs: [cacheEntity], deleteArgs: [], deleteAllArgs: [()], findArgs: []))),

                (input: (line: #line, deleteCache: true, storedEntity: validCacheEntity, getResult: .failure(apiError)),
                 expect: (apiDataStoreSpyExpect: .init(getGitHubUsersArgs: [since], cancelRequestArgs: []),
                          dbDataStoreSpyExpect: .init(addArgs: [], deleteArgs: [], deleteAllArgs: [()], findArgs: []))),
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

                if testCase.expect.dbDataStoreSpyExpect.addArgs.isEmpty {
                    // Verify
                    apiDataStoreSpy.verify(line: testCase.input.line)
                    dbDataStoreSpy.verify(line: testCase.input.line)
                    expectation.fulfill()
                } else {
                    // The DBDataStore Spy will notify when the object has been added to the database.
                    NotificationCenter.default.addObserver(forName: AddToDBIsCompletion, object: nil, queue: .main) { _ in
                        // Verify
                        apiDataStoreSpy.verify(line: testCase.input.line)
                        dbDataStoreSpy.verifyIfAdded(line: testCase.input.line)
                        expectation.fulfill()
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 4.0)
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
                 expect: (apiDataStoreSpyExpect: .init(getGitHubUsersArgs: [], cancelRequestArgs: [()]),
                          dbDataStoreSpyExpect: .init(addArgs: [], deleteArgs: [], deleteAllArgs: [], findArgs: []))),
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

    private var since: Int {
        0
    }

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

    private var cacheEntity: GitHubUsersCacheEntity {
        .init(since: since, lastModified: currentDate, response: successApiResponse)
    }
}

// MARK: - Spy

final class GitHubUsersAPIDataStoreSpy: GitHubUsersAPIDataStore {

    struct Expect {
        private(set) var getGitHubUsersArgs: [Int]
        private(set) var cancelRequestArgs: [Void]

        init(getGitHubUsersArgs: [Int], cancelRequestArgs: [Void]) {
            self.getGitHubUsersArgs = getGitHubUsersArgs
            self.cancelRequestArgs = cancelRequestArgs
        }
    }

    private var getGitHubUsersArgs: [Int] = []
    private var cancelRequestArgs: [Void] = []
    private var getResult: GetAPIResult

    private var expect: Expect

    init(getResult: GetAPIResult, expect: Expect) {
        self.getResult = getResult
        self.expect = expect
    }

    func getGitHubUsers(since: Int, completion: @escaping Completion) {
        getGitHubUsersArgs.append(since)
        completion(getResult)
    }

    func cancelRequest() {
        cancelRequestArgs.append(())
    }

    // Reset call counts

    func resetCallCounts() {
        getGitHubUsersArgs = []
        cancelRequestArgs = []
    }

    // Verify
    func verify(line: UInt) {
        XCTAssertEqual(getGitHubUsersArgs, expect.getGitHubUsersArgs, "getGitHubUsersArgs", line: line)
        XCTAssertEqual(cancelRequestArgs.count, expect.cancelRequestArgs.count, "cancelRequestArgs", line: line)
    }
}

final class GitHubUsersDBDataStoreSpy: GitHubUsersDBDataStore {

    struct Expect {
        private(set) var addArgs: [GitHubUsersCacheEntity]
        private(set) var deleteArgs: [Int]
        private(set) var deleteAllArgs: [Void]
        private(set) var findArgs: [Int]

        init(addArgs: [GitHubUsersCacheEntity], deleteArgs: [Int], deleteAllArgs: [Void], findArgs: [Int]) {
            self.addArgs = addArgs
            self.deleteArgs = deleteArgs
            self.deleteAllArgs = deleteAllArgs
            self.findArgs = findArgs
        }
    }

    private var addArgs: [GitHubUsersCacheEntity] = []
    private var deleteArgs: [Int] = []
    private var deleteAllArgs: [Void] = []
    private var findArgs: [Int] = []

    private var storedGitHubUsersCacheEntity: GitHubUsersCacheEntity
    private var expect: Expect

    init(storedGitHubUsersCacheEntity: GitHubUsersCacheEntity, expect: Expect) {
        self.storedGitHubUsersCacheEntity = storedGitHubUsersCacheEntity
        self.expect = expect
    }

    func add(entity: GitHubUsersCacheEntity, completion: Completion?) {
        addArgs.append(entity)
        completion?(.success(()))
        NotificationCenter.default.post(name: AddToDBIsCompletion, object: nil)
    }

    func delete(since: Int, completion: Completion?) {
        deleteArgs.append(since)
        completion?(.success(()))
    }

    func deleteAll(completion: Completion?) {
        deleteAllArgs.append(())
        completion?(.success(()))
    }

    func find(since: Int) -> GitHubUsersCacheEntity? {
        findArgs.append(since)
        return storedGitHubUsersCacheEntity
    }

    // Reset call counts

    func resetCallCounts() {
        addArgs = []
        deleteArgs = []
        deleteAllArgs = []
        findArgs = []
    }

    // Verify
    func verify(line: UInt) {
        XCTAssertEqual(addArgs, expect.addArgs, "addArgs", line: line)
        XCTAssertEqual(deleteArgs, expect.deleteArgs, "deleteArgs", line: line)
        XCTAssertEqual(deleteAllArgs.count, expect.deleteAllArgs.count, "deleteAllArgs", line: line)
        XCTAssertEqual(findArgs, expect.findArgs, "findArgs", line: line)
    }

    func verifyIfAdded(line: UInt) {
        XCTAssertEqual(addArgs.count, expect.addArgs.count, "addArgs.count", line: line)
        XCTAssertEqual(addArgs[0].since, expect.addArgs[0].since, "addArgs[0].since", line: line)
        XCTAssertEqual(addArgs[0].lastModified, expect.addArgs[0].lastModified, "addArgs[0].lastModified", line: line)

        let responseList = Array(addArgs[0].responseList)
        let expectResponseList = Array(expect.addArgs[0].responseList)
        XCTAssertEqual(responseList[0].id, expectResponseList[0].id, "responseList[0].id", line: line)
        XCTAssertEqual(responseList[1].id, expectResponseList[1].id, "responseList[1].id", line: line)

        XCTAssertEqual(deleteArgs, expect.deleteArgs, "deleteArgs", line: line)
        XCTAssertEqual(deleteAllArgs.count, expect.deleteAllArgs.count, "deleteAllArgs", line: line)
        XCTAssertEqual(findArgs, expect.findArgs, "findArgs", line: line)
    }
}
