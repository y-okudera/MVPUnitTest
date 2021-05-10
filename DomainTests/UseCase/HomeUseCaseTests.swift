//
//  HomeUseCaseTests.swift
//  DomainTests
//
//  Created by okudera on 2021/05/07.
//

@testable import Domain
import Common
import Data
import XCTest

typealias Response = [GitHubUserEntity]
typealias ErrorResponse = CommonErrorResponse
typealias GetAPIResult = Result<Response, APIError<CommonErrorResponse>>

final class HomeUseCaseTests: XCTestCase {

    private var repositorySpy: GitHubUsersRepositorySpy!
    private var useCase: HomeUseCaseImpl!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - func getHomeViewData(since: , deleteCache: , completion: ) tests

    /// Test to get GitHubUsers via the repository.
    func testGetHomeViewData() {

        // Expect
        let expectation = XCTestExpectation(description: "Get GitHubUsers via the repository.")

        typealias Input = (line: UInt, getResult: GetAPIResult)
        typealias Expect = (GitHubUsersRepositorySpy.Expect)

        let paramTest = ParameterizedTest<Input, Expect>(
            testCases: [
                (input: (line: #line, getResult: .success([])),
                 expect: .init(getGitHubUsersArgs: [(since: since, currentDate: currentDate, refreshInterval: refreshInterval, deleteCache: deleteCache)], cancelRequestArgs: [])),
                (input: (line: #line, getResult: .failure(.connectionError)),
                 expect: .init(getGitHubUsersArgs: [(since: since, currentDate: currentDate, refreshInterval: refreshInterval, deleteCache: deleteCache)], cancelRequestArgs: [])),
            ],
            expectation: expectation)

        paramTest.runTest { testCase in
            // Setup
            repositorySpy = .init(getResult: testCase.input.getResult, expect: testCase.expect)
            useCase = .init(repository: repositorySpy, refreshInterval: refreshInterval)

            // Reset call counts before exercise.
            repositorySpy.resetCallCounts()

            // Exercise SUT
            useCase.getHomeViewData(since: since, currentDate: currentDate, deleteCache: deleteCache) { [unowned self] _ in
                // Verify
                repositorySpy.verify(line: testCase.input.line)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

    // MARK: - func cancelHomeViewDataRequest() tests

    /// Test to cancel the HomeViewData get request.
    func testCancelHomeViewDataRequest() {

        // Expect
        let expectation = XCTestExpectation(description: "Cancel the HomeViewData get request.")

        typealias Input = (UInt)
        typealias Expect = (GitHubUsersRepositorySpy.Expect)

        let paramTest = ParameterizedTest<Input, Expect>(
            testCases: [
                (input: (#line),
                 expect: .init(getGitHubUsersArgs: [], cancelRequestArgs: [()])),
            ],
            expectation: expectation)

        paramTest.runTest { testCase in
            // Setup
            repositorySpy = .init(getResult: .failure(.connectionError), expect: testCase.expect)
            useCase = .init(repository: repositorySpy, refreshInterval: 60 * 30)

            // Reset call counts before exercise.
            repositorySpy.resetCallCounts()

            // Exercise SUT
            useCase.cancelHomeViewDataRequest()

            // Verify
            repositorySpy.verify(line: testCase.input)
        }
    }
}

extension HomeUseCaseTests {

    private var since: Int {
        0
    }

    private var currentDate: Date {
        Date.now(dateGenerator: { DateGenerator.generate(dateString: "20210509120000") })
    }

    private var refreshInterval: TimeInterval {
        60 * 30
    }

    private var deleteCache: Bool {
        false
    }
}

// MARK: - Spy

final class GitHubUsersRepositorySpy: GitHubUsersRepository {

    struct Expect {
        private(set) var getGitHubUsersArgs: [(since: Int, currentDate: Date, refreshInterval: TimeInterval, deleteCache: Bool)]
        private(set) var cancelRequestArgs: [Void]

        init(getGitHubUsersArgs: [(since: Int, currentDate: Date, refreshInterval: TimeInterval, deleteCache: Bool)], cancelRequestArgs: [Void]) {
            self.getGitHubUsersArgs = getGitHubUsersArgs
            self.cancelRequestArgs = cancelRequestArgs
        }
    }

    private var getGitHubUsersArgs: [(since: Int, currentDate: Date, refreshInterval: TimeInterval, deleteCache: Bool)] = []
    private var cancelRequestArgs: [Void] = []
    private var getResult: GetAPIResult

    private var expect: Expect

    init(getResult: GetAPIResult, expect: Expect) {
        self.getResult = getResult
        self.expect = expect
    }

    func getGitHubUsers(since: Int, currentDate: Date, refreshInterval: TimeInterval, deleteCache: Bool, completion: @escaping Completion) {
        getGitHubUsersArgs.append((since: since, currentDate: currentDate, refreshInterval: refreshInterval, deleteCache: deleteCache))
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

        if expect.getGitHubUsersArgs.isEmpty {
            XCTAssertEqual(getGitHubUsersArgs.count, expect.getGitHubUsersArgs.count, "getGitHubUsersArgs.count", line: line)
        } else {
            XCTAssertEqual(getGitHubUsersArgs[0].since, expect.getGitHubUsersArgs[0].since, "getGitHubUsersArgs[0].since", line: line)
            XCTAssertEqual(getGitHubUsersArgs[0].currentDate, expect.getGitHubUsersArgs[0].currentDate, "getGitHubUsersArgs[0].currentDate", line: line)
            XCTAssertEqual(getGitHubUsersArgs[0].refreshInterval, expect.getGitHubUsersArgs[0].refreshInterval, "getGitHubUsersArgs[0].refreshInterval", line: line)
            XCTAssertEqual(getGitHubUsersArgs[0].deleteCache, expect.getGitHubUsersArgs[0].deleteCache, "getGitHubUsersArgs[0].deleteCache", line: line)
        }
        XCTAssertEqual(cancelRequestArgs.count, expect.cancelRequestArgs.count, "cancelRequestArgs.count", line: line)
    }
}
