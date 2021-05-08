//
//  HomePresenterTests.swift
//  PresentationTests
//
//  Created by okudera on 2021/05/07.
//

@testable import Presentation
import Domain
import XCTest

typealias GetHomeViewDataResult = Result<HomeViewData, Error>

typealias Input = (
    line: UInt,
    viewData: HomeViewData,
    since: Int,
    loadingState: HomePresenterImpl.LoadingState,
    htmlUrl: String,
    getHomeViewDataResult: GetHomeViewDataResult
)

typealias Expect = (
    homeViewSpyExpect: HomeViewSpy.Expect,
    homeWireframeSpyExpect: HomeWireframeSpy.Expect,
    homeUseCaseSpyExpect: HomeUseCaseSpy.Expect
)

typealias TestCase = (input: Input, expect: Expect)

final class HomePresenterTests: XCTestCase {

    private var viewSpy: HomeViewSpy!
    private var wireframeSpy: HomeWireframeSpy!
    private var useCaseSpy: HomeUseCaseSpy!
    private var presenter: HomePresenterImpl!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// Test how many times the dependent process has been called via 'viewDidLoad'.
    func testViewDidLoad() throws {

        // Expect
        let expectation = XCTestExpectation(description: "Home presenter Parameterized-Tests.")

        let testCases: [TestCase] = [
            (input: (line: #line,
                     viewData: .init(data: []),
                     since: 0,
                     loadingState: .none,
                     htmlUrl: "",
                     getHomeViewDataResult: .success(HomeViewData(data: []))),
             expect: (homeViewSpyExpect: .init(showLoadingViewCallCount: 1,
                                               hideLoadingViewCallCount: 1,
                                               showRefreshControlCallCount: 0,
                                               hideRefreshControlCallCount: 2,
                                               reloadDataCallCount: 1),
                      homeWireframeSpyExpect: .init(openExternalBrowserCallCount: 0),
                      homeUseCaseSpyExpect: .init(getHomeViewDataCallCount: 1, cancelHomeViewDataRequestCallCount: 0))
            ),

            (input: (line: #line,
                     viewData: .init(data: []),
                     since: 0,
                     loadingState: .none,
                     htmlUrl: "",
                     getHomeViewDataResult: .failure(HomePresenterTests.notConnectedToInternetError)),
             expect: (homeViewSpyExpect: .init(showLoadingViewCallCount: 1,
                                               hideLoadingViewCallCount: 1,
                                               showRefreshControlCallCount: 0,
                                               hideRefreshControlCallCount: 2,
                                               reloadDataCallCount: 0),
                      homeWireframeSpyExpect: .init(openExternalBrowserCallCount: 0),
                      homeUseCaseSpyExpect: .init(getHomeViewDataCallCount: 1, cancelHomeViewDataRequestCallCount: 0))
            ),
        ]

        parameterizedTest(testCases: testCases, expectation: expectation) { (testCase) in
            presenter.viewDidLoad()
        }
        wait(for: [expectation], timeout: 3.0)
    }

    /// Test how many times the dependent process has been called via 'reachedBottom'.
    func testReachedBottom() throws {

        // Expect
        let expectation = XCTestExpectation(description: "Home presenter Parameterized-Tests.")

        let testCases: [TestCase] = [

            // Presenter has no ViewData.
            (input: (line: #line,
                     viewData: .init(data: []),
                     since: 0,
                     loadingState: .none,
                     htmlUrl: "",
                     getHomeViewDataResult: .success(HomeViewData(data: []))),
             expect: (homeViewSpyExpect: .init(showLoadingViewCallCount: 0,
                                               hideLoadingViewCallCount: 0,
                                               showRefreshControlCallCount: 0,
                                               hideRefreshControlCallCount: 0,
                                               reloadDataCallCount: 0),
                      homeWireframeSpyExpect: .init(openExternalBrowserCallCount: 0),
                      homeUseCaseSpyExpect: .init(getHomeViewDataCallCount: 0, cancelHomeViewDataRequestCallCount: 0))
            ),

            // Presenter has ViewData. And the LoadingState is 'showLoading'.
            (input: (line: #line,
                     viewData: .init(data: [.testUser]),
                     since: 100,
                     loadingState: .showLoading,
                     htmlUrl: "",
                     getHomeViewDataResult: .success(HomeViewData(data: [.testOtherObject]))),
             expect: (homeViewSpyExpect: .init(showLoadingViewCallCount: 0,
                                               hideLoadingViewCallCount: 0,
                                               showRefreshControlCallCount: 0,
                                               hideRefreshControlCallCount: 0,
                                               reloadDataCallCount: 0),
                      homeWireframeSpyExpect: .init(openExternalBrowserCallCount: 0),
                      homeUseCaseSpyExpect: .init(getHomeViewDataCallCount: 0, cancelHomeViewDataRequestCallCount: 0))
            ),

            // Presenter has ViewData. And the LoadingState is 'showRefreshControl'.
            (input: (line: #line,
                     viewData: .init(data: [.testUser]),
                     since: 100,
                     loadingState: .showRefreshControl,
                     htmlUrl: "",
                     getHomeViewDataResult: .success(HomeViewData(data: [.testOtherObject]))),
             expect: (homeViewSpyExpect: .init(showLoadingViewCallCount: 0,
                                               hideLoadingViewCallCount: 0,
                                               showRefreshControlCallCount: 0,
                                               hideRefreshControlCallCount: 0,
                                               reloadDataCallCount: 0),
                      homeWireframeSpyExpect: .init(openExternalBrowserCallCount: 0),
                      homeUseCaseSpyExpect: .init(getHomeViewDataCallCount: 0, cancelHomeViewDataRequestCallCount: 0))
            ),

            // Presenter has ViewData. And the LoadingState is 'none'.
            // Expect reloadData to be called.
            (input: (line: #line,
                     viewData: .init(data: [.testUser]),
                     since: 100,
                     loadingState: .none,
                     htmlUrl: "",
                     getHomeViewDataResult: .success(HomeViewData(data: [.testOtherObject]))),
             expect: (homeViewSpyExpect: .init(showLoadingViewCallCount: 1,
                                               hideLoadingViewCallCount: 1,
                                               showRefreshControlCallCount: 0,
                                               hideRefreshControlCallCount: 2,
                                               reloadDataCallCount: 1),
                      homeWireframeSpyExpect: .init(openExternalBrowserCallCount: 0),
                      homeUseCaseSpyExpect: .init(getHomeViewDataCallCount: 1, cancelHomeViewDataRequestCallCount: 0))
            ),
        ]

        parameterizedTest(testCases: testCases, expectation: expectation) { (testCase) in
            presenter.reachedBottom()
        }
        wait(for: [expectation], timeout: 3.0)
    }

    /// Test how many times the dependent process has been called via 'pullToRefresh'.
    func testPullToRefresh() throws {

        // Expect
        let expectation = XCTestExpectation(description: "Home presenter Parameterized-Tests.")

        let testCases: [TestCase] = [

            // The request succeed.
            // Expect reloadData to be called.
            (input: (line: #line,
                     viewData: .init(data: [.testUser]),
                     since: 0,
                     loadingState: .none,
                     htmlUrl: "",
                     getHomeViewDataResult: .success(HomeViewData(data: [.testOtherObject]))),
             expect: (homeViewSpyExpect: .init(showLoadingViewCallCount: 0,
                                               hideLoadingViewCallCount: 2,
                                               showRefreshControlCallCount: 1,
                                               hideRefreshControlCallCount: 1,
                                               reloadDataCallCount: 1),
                      homeWireframeSpyExpect: .init(openExternalBrowserCallCount: 0),
                      homeUseCaseSpyExpect: .init(getHomeViewDataCallCount: 1, cancelHomeViewDataRequestCallCount: 1))
            ),

            // The request failed.
            // Expect reloadData not to be called.
            (input: (line: #line,
                     viewData: .init(data: [.testUser]),
                     since: 0,
                     loadingState: .none,
                     htmlUrl: "",
                     getHomeViewDataResult: .failure(HomePresenterTests.notConnectedToInternetError)),
             expect: (homeViewSpyExpect: .init(showLoadingViewCallCount: 0,
                                               hideLoadingViewCallCount: 2,
                                               showRefreshControlCallCount: 1,
                                               hideRefreshControlCallCount: 1,
                                               reloadDataCallCount: 0),
                      homeWireframeSpyExpect: .init(openExternalBrowserCallCount: 0),
                      homeUseCaseSpyExpect: .init(getHomeViewDataCallCount: 1, cancelHomeViewDataRequestCallCount: 1))
            ),
        ]

        parameterizedTest(testCases: testCases, expectation: expectation) { (testCase) in
            presenter.pullToRefresh()
        }
        wait(for: [expectation], timeout: 3.0)
    }

    /// Test how many times the dependent process has been called via 'tappedUserPageButton'.
    func testTappedUserPageButton() throws {

        // Expect
        let expectation = XCTestExpectation(description: "Home presenter Parameterized-Tests.")

        let testCases: [TestCase] = [

            // Expect openExternalBrowser to be called.
            (input: (line: #line,
                     viewData: .init(data: [.testUser]),
                     since: 0,
                     loadingState: .none,
                     htmlUrl: GitHubUser.testUser.htmlUrl,
                     getHomeViewDataResult: .success(HomeViewData(data: []))),
             expect: (homeViewSpyExpect: .init(showLoadingViewCallCount: 0,
                                               hideLoadingViewCallCount: 0,
                                               showRefreshControlCallCount: 0,
                                               hideRefreshControlCallCount: 0,
                                               reloadDataCallCount: 0),
                      homeWireframeSpyExpect: .init(openExternalBrowserCallCount: 1),
                      homeUseCaseSpyExpect: .init(getHomeViewDataCallCount: 0, cancelHomeViewDataRequestCallCount: 0))
            ),
        ]

        parameterizedTest(testCases: testCases, expectation: expectation) { (testCase) in
            presenter.tappedUserPageButton(urlString: testCase.input.htmlUrl)
        }
        wait(for: [expectation], timeout: 3.0)
    }
}

extension HomePresenterTests {

    private static var notConnectedToInternetError: Error {
        NSError(domain: URLError.errorDomain, code: URLError.notConnectedToInternet.rawValue)
    }

    func parameterizedTest(testCases: [TestCase], expectation: XCTestExpectation, exerciseSUT: (TestCase) -> Void) {

        let paramTest = ParameterizedTest(testCases: testCases, expectation: expectation)
        paramTest.runTest { testCase in
            // Setup
            viewSpy = .init(expect: testCase.expect.homeViewSpyExpect)
            wireframeSpy = .init(viewController: nil, expect: testCase.expect.homeWireframeSpyExpect)
            useCaseSpy = .init(getHomeViewDataResult: testCase.input.getHomeViewDataResult, expect: testCase.expect.homeUseCaseSpyExpect)
            presenter = .init(view: viewSpy, wireframe: wireframeSpy, homeUseCase: useCaseSpy)
            presenter.viewData = testCase.input.viewData

            presenter.setSinceValue(lastUserId: testCase.input.since)
            presenter.setLoadingState(testCase.input.loadingState)

            // Reset call counts before exercise.
            viewSpy.resetCallCounts()
            wireframeSpy.resetCallCounts()
            useCaseSpy.resetCallCounts()

            // Exercise SUT
            exerciseSUT(testCase)

            sleep(1)

            // Verify
            viewSpy.verify(line: testCase.input.line)
            wireframeSpy.verify(line: testCase.input.line)
            useCaseSpy.verify(line: testCase.input.line)
            expectation.fulfill()
        }
    }
}

// MARK: - Spy

final class HomeViewSpy: HomeView {

    struct Expect {
        private(set) var showLoadingViewCallCount: Int
        private(set) var hideLoadingViewCallCount: Int
        private(set) var showRefreshControlCallCount: Int
        private(set) var hideRefreshControlCallCount: Int
        private(set) var reloadDataCallCount: Int

        init(showLoadingViewCallCount: Int,
             hideLoadingViewCallCount: Int,
             showRefreshControlCallCount: Int,
             hideRefreshControlCallCount: Int,
             reloadDataCallCount: Int) {
            self.showLoadingViewCallCount = showLoadingViewCallCount
            self.hideLoadingViewCallCount = hideLoadingViewCallCount
            self.showRefreshControlCallCount = showRefreshControlCallCount
            self.hideRefreshControlCallCount = hideRefreshControlCallCount
            self.reloadDataCallCount = reloadDataCallCount
        }
    }

    private var showLoadingViewCallCount: Int = 0
    private var hideLoadingViewCallCount: Int = 0
    private var showRefreshControlCallCount: Int = 0
    private var hideRefreshControlCallCount: Int = 0
    private var reloadDataCallCount: Int = 0

    private var expect: Expect

    init(expect: Expect) {
        self.expect = expect
    }

    func showLoadingView() {
        showLoadingViewCallCount += 1
    }

    func hideLoadingView() {
        hideLoadingViewCallCount += 1
    }

    func showRefreshControl() {
        showRefreshControlCallCount += 1
    }

    func hideRefreshControl() {
        hideRefreshControlCallCount += 1
    }

    func reloadData() {
        reloadDataCallCount += 1
    }

    // Reset call counts

    func resetCallCounts() {
        showLoadingViewCallCount = 0
        hideLoadingViewCallCount = 0
        showRefreshControlCallCount = 0
        hideRefreshControlCallCount = 0
        reloadDataCallCount = 0
    }

    // Verify
    func verify(line: UInt) {
        XCTAssertEqual(showLoadingViewCallCount, expect.showLoadingViewCallCount, "showLoadingViewCallCount", line: line)
        XCTAssertEqual(hideLoadingViewCallCount, expect.hideLoadingViewCallCount, "hideLoadingViewCallCount", line: line)
        XCTAssertEqual(showRefreshControlCallCount, expect.showRefreshControlCallCount, "showRefreshControlCallCount", line: line)
        XCTAssertEqual(hideRefreshControlCallCount, expect.hideRefreshControlCallCount, "hideRefreshControlCallCount", line: line)
        XCTAssertEqual(reloadDataCallCount, expect.reloadDataCallCount, "reloadDataCallCount", line: line)
    }
}

final class HomeWireframeSpy: HomeWireframe {

    struct Expect {
        private(set) var openExternalBrowserCallCount: Int

        init(openExternalBrowserCallCount: Int) {
            self.openExternalBrowserCallCount = openExternalBrowserCallCount
        }
    }

    weak var viewController: UIViewController?
    private var openExternalBrowserCallCount: Int = 0

    private var expect: Expect

    init(viewController: UIViewController?, expect: Expect) {
        self.viewController = viewController
        self.expect = expect
    }

    func openExternalBrowser(by urlString: String) {
        openExternalBrowserCallCount += 1
    }

    // Reset call counts

    func resetCallCounts() {
        openExternalBrowserCallCount = 0
    }

    // Verify
    func verify(line: UInt) {
        XCTAssertEqual(openExternalBrowserCallCount, expect.openExternalBrowserCallCount, "openExternalBrowserCallCount", line: line)
    }
}

final class HomeUseCaseSpy: HomeUseCase {

    struct Expect {
        private(set) var getHomeViewDataCallCount: Int
        private(set) var cancelHomeViewDataRequestCallCount: Int

        init(getHomeViewDataCallCount: Int, cancelHomeViewDataRequestCallCount: Int) {
            self.getHomeViewDataCallCount = getHomeViewDataCallCount
            self.cancelHomeViewDataRequestCallCount = cancelHomeViewDataRequestCallCount
        }
    }

    private var getHomeViewDataCallCount: Int = 0
    private var cancelHomeViewDataRequestCallCount: Int = 0
    private var getHomeViewDataResult: GetHomeViewDataResult

    private var expect: Expect

    init(getHomeViewDataResult: GetHomeViewDataResult, expect: Expect) {
        self.getHomeViewDataResult = getHomeViewDataResult
        self.expect = expect
    }

    func getHomeViewData(since: Int, deleteCache: Bool, completion: @escaping Completion) {
        getHomeViewDataCallCount += 1
        completion(self.getHomeViewDataResult)
    }

    func cancelHomeViewDataRequest() {
        cancelHomeViewDataRequestCallCount += 1
    }

    // Reset call counts

    func resetCallCounts() {
        getHomeViewDataCallCount = 0
        cancelHomeViewDataRequestCallCount = 0
    }

    // Verify
    func verify(line: UInt) {
        XCTAssertEqual(getHomeViewDataCallCount, expect.getHomeViewDataCallCount, "getHomeViewDataCallCount", line: line)
        XCTAssertEqual(cancelHomeViewDataRequestCallCount, expect.cancelHomeViewDataRequestCallCount, "cancelHomeViewDataRequestCallCount", line: line)
    }
}
