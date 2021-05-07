//
//  ParameterizedTest.swift
//  DomainTests
//
//  Created by okudera on 2021/05/07.
//

import XCTest

final class ParameterizedTest<Input, Expect> {
    typealias TestCase = (input: Input, expect: Expect)
    typealias TestingBlock = (TestCase) -> Void

    private var testCases = [TestCase]()

    func setTestCases(_ testCases: [TestCase], expectation: XCTestExpectation) {
        self.testCases = testCases
        expectation.expectedFulfillmentCount = testCases.count
    }

    func runTest(testingBlock: TestingBlock) {
        for testCase in testCases {
            testingBlock(testCase)
        }
    }
}
