//
//  HomeUseCaseTests.swift
//  DomainTests
//
//  Created by okudera on 2021/05/07.
//

import Data
@testable import Domain
import XCTest

typealias Response = [GitHubUserEntity]
typealias ErrorResponse = CommonErrorResponse
typealias GetAPIResult = Result<Response, APIError<CommonErrorResponse>>
typealias GitHubUsersRepositorySpyExpect = (getGitHubUsersCallCount: Int, cancelRequestCallCount: Int)

final class HomeUseCaseTests: XCTestCase {

    private var repositorySpy: GitHubUsersRepositorySpy!
    private var useCase: HomeUseCaseImpl!

    override func setUpWithError() throws {
        repositorySpy = nil
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
        typealias Expect = (GitHubUsersRepositorySpyExpect)

        let paramTest = ParameterizedTest<Input, Expect>(
            testCases: [
                (input: (line: #line, getResult: .success([])),
                 expect: (getGitHubUsersCallCount: 1, cancelRequestCallCount: 0)),
                (input: (line: #line, getResult: .failure(.connectionError)),
                 expect: (getGitHubUsersCallCount: 1, cancelRequestCallCount: 0)),
            ],
            expectation: expectation)

        paramTest.runTest { testCase in
            // Setup
            repositorySpy = .init(getResult: testCase.input.getResult, expect: testCase.expect)
            useCase = .init(repository: repositorySpy, refreshInterval: 60 * 30)

            // Exercise SUT
            useCase.getHomeViewData(since: 0, deleteCache: false) { [unowned self] getResult in
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
        typealias Expect = (GitHubUsersRepositorySpyExpect)

        let paramTest = ParameterizedTest<Input, Expect>(
            testCases: [
                (input: (#line),
                 expect: (getGitHubUsersCallCount: 0, cancelRequestCallCount: 1)),
            ],
            expectation: expectation)

        paramTest.runTest { testCase in
            // Setup
            repositorySpy = .init(getResult: .failure(.connectionError), expect: testCase.expect)
            useCase = .init(repository: repositorySpy, refreshInterval: 60 * 30)

            // Exercise SUT
            useCase.cancelHomeViewDataRequest()

            // Verify
            repositorySpy.verify(line: testCase.input)
        }
    }
}

// MARK: - Spy

final class GitHubUsersRepositorySpy: GitHubUsersRepository {

    private var getGitHubUsersCallCount: Int = 0
    private var cancelRequestCallCount: Int = 0
    private var getResult: GetAPIResult

    private var expect: GitHubUsersRepositorySpyExpect

    init(getResult: GetAPIResult, expect: GitHubUsersRepositorySpyExpect) {
        self.getResult = getResult
        self.expect = expect
    }

    func getGitHubUsers(since: Int, refreshInterval: TimeInterval, deleteCache: Bool, completion: @escaping Completion) {
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
