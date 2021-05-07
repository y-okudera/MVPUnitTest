//
//  APIClientTests.swift
//  DataTests
//
//  Created by okudera on 2021/05/05.
//

@testable import Data
import Alamofire
import XCTest

final class APIClientTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - func request<T: APIRequestable>(_ request: , queue: , decoder: , completion: ) -> DataRequest tests

    /// API request test.
    ///
    /// Expectation: Result.success is passed to completion handler.
    /// - 200 OK
    /// - 299 Unknown Code
    func testAPIRequestWhenReturnedSuccess() throws {

        // Expect
        let expectation = XCTestExpectation(description: "Result.success is passed to completion handler.")

        typealias Input = (line: UInt, statusCode: Int, sleep: Int)
        typealias Expect = (code: Int, description: String)

        let paramTest = ParameterizedTest<Input, Expect>(
            testCases: [
                (input: (line: #line, statusCode: 200, sleep: 0),
                 expect: (code: 200, description: "OK")),

                (input: (line: #line, statusCode: 299, sleep: 0),
                 expect: (code: 299, description: "299 Unknown Code")),
            ], expectation: expectation)

        paramTest.runTest { testCase in
            // Setup
            let dummyRequest = DummyRequest(statusCode: testCase.input.statusCode, sleep: testCase.input.sleep)

            // Exercise SUT
            APIClient.shared.request(dummyRequest) { result in
                switch result {
                case .success(let response):
                    // Verify
                    XCTAssertEqual(response.code, testCase.expect.code, line: testCase.input.line)
                    XCTAssertEqual(response.description, testCase.expect.description, line: testCase.input.line)
                    expectation.fulfill()
                case .failure:
                    XCTFail("Unexpected case.")
                }
            }
        }
        wait(for: [expectation], timeout: 6.0)
    }

    /// API request test.
    ///
    /// Expectation: Result.failure is passed to completion handler.
    /// - .errorResponse
    /// - .connectionError
    func testAPIRequestWhenReturnedFailure() throws {

        // Expect
        let expectation = XCTestExpectation(description: "Result.failure is passed to completion handler.")

        typealias Input = (line: UInt, statusCode: Int, sleep: Int, timeoutInterval: TimeInterval)
        typealias Expect = (APIError<DummyErrorResponse>)

        let paramTest = ParameterizedTest<Input, Expect>(
            testCases: [
                (input: (line: #line, statusCode: 300, sleep: 0, timeoutInterval: 30.0),
                 expect: .errorResponse(.init(code: 300, description: "Multiple Choices"), statusCode: 300)),

                (input: (line: #line, statusCode: 399, sleep: 0, timeoutInterval: 30.0),
                 expect: .errorResponse(.init(code: 399, description: "399 Unknown Code"), statusCode: 399)),

                (input: (line: #line, statusCode: 400, sleep: 0, timeoutInterval: 30.0),
                 expect: .errorResponse(.init(code: 400, description: "Bad Request"), statusCode: 400)),

                (input: (line: #line, statusCode: 499, sleep: 0, timeoutInterval: 30.0),
                 expect: .errorResponse(.init(code: 499, description: "499 Unknown Code"), statusCode: 499)),

                (input: (line: #line, statusCode: 500, sleep: 0, timeoutInterval: 30.0),
                 expect: .errorResponse(.init(code: 500, description: "Internal Server Error"), statusCode: 500)),

                (input: (line: #line, statusCode: 599, sleep: 0, timeoutInterval: 30.0),
                 expect: .errorResponse(.init(code: 599, description: "599 Unknown Code"), statusCode: 599)),

                (input: (line: #line, statusCode: 200, sleep: 6_000, timeoutInterval: 5.0),
                 expect: .connectionError),

                (input: (line: #line, statusCode: 0, sleep: 0, timeoutInterval: 30.0),
                 expect: .others(error: APIClientTests.invalidJSONError)),
            ],
            expectation: expectation)

        paramTest.runTest { testCase in
            // Setup
            let dummyRequest = DummyRequest(
                statusCode: testCase.input.statusCode,
                sleep: testCase.input.sleep,
                timeoutInterval: testCase.input.timeoutInterval
            )

            // Exercise SUT
            APIClient.shared.request(dummyRequest) { result in
                switch result {
                case .success:
                    XCTFail("Unexpected case.")
                case .failure(let apiError):
                    // Verify
                    XCTAssertEqual(apiError, testCase.expect, line: testCase.input.line)
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 6.0)
    }

    // MARK: - func cancelRequest(_ dataRequest: ) tests

    /// Cancel API request test.
    ///
    /// Expectation: Result.failure is passed to completion handler.
    /// - .cancelled
    func testCancelAPIRequest() throws {

        // Expect
        let expectation = XCTestExpectation(description: "Result.failure is passed to completion handler.")

        // Setup
        let dummyRequest = DummyRequest(statusCode: 200, sleep: 5_000)

        let dataRequest = APIClient.shared.request(dummyRequest) { result in
            switch result {
            case .success:
                XCTFail("Unexpected case.")
            case .failure(let apiError):
                // Verify
                XCTAssertEqual(apiError, .cancelled)
                expectation.fulfill()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Exercise SUT
            APIClient.shared.cancelRequest(dataRequest)
        }
        wait(for: [expectation], timeout: 3.0)
    }

    // MARK: - func cancelAllRequests() tests
    
    /// Cancel all API requests test.
    ///
    /// Expectation: Result.failure is passed to completion handler.
    /// - .cancelled
    func testCancelAllAPIRequest() throws {

        // Expect
        let expectation = XCTestExpectation(description: "Result.failure is passed to completion handler.")

        // Setup
        let dummyRequests = [DummyRequest(statusCode: 200, sleep: 5_000), DummyRequest(statusCode: 200, sleep: 5_000)]
        expectation.expectedFulfillmentCount = dummyRequests.count

        for dummyRequest in dummyRequests {

            APIClient.shared.request(dummyRequest) { result in
                switch result {
                case .success:
                    XCTFail("Unexpected case.")
                case .failure(let apiError):
                    // Verify
                    XCTAssertEqual(apiError, .cancelled)
                    expectation.fulfill()
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Exercise SUT
            APIClient.shared.cancelAllRequests()
        }
        wait(for: [expectation], timeout: 3.0)
    }
}

// MARK: - DummyRequest

struct DummyResponse: Decodable {
    let code: Int
    let description: String
}

struct DummyErrorResponse: Decodable, Equatable {
    let code: Int
    let description: String
}

final class DummyRequest: APIRequestable {

    typealias Response = DummyResponse
    typealias ErrorResponse = DummyErrorResponse

    let baseURL = URL(string: "https://httpstat.us")!
    let path: String

    lazy var parameters: [String: Any] = {
        var parameters = [
            "sleep": sleep,
        ]
        return parameters
    }()

    var httpHeaderFields: [String: String] {
        return [
            "Accept": "application/json",
        ]
    }

    let timeoutInterval: TimeInterval

    let sleep: Int

    init(statusCode: Int, sleep: Int, timeoutInterval: TimeInterval = 30) {
        self.path = "/\(statusCode)"
        self.sleep = sleep
        self.timeoutInterval = timeoutInterval
    }
}

// MARK: - Private Error

extension APIClientTests {
    /// This error occurs when the response is empty.
    private static var invalidJSONError: Error {
        Alamofire.AFError.responseSerializationFailed(
            reason: Alamofire.AFError.ResponseSerializationFailureReason.decodingFailed(
                error: Swift.DecodingError.dataCorrupted(
                    Swift.DecodingError.Context(
                        codingPath: [],
                        debugDescription: "The given data was not valid JSON.",
                        underlyingError: NSError(
                            domain: NSCocoaErrorDomain,
                            code: 3840,
                            userInfo: [NSLocalizedDescriptionKey: "Invalid value around character 0."]
                        )
                    )
                )
            )
        )
    }
}
