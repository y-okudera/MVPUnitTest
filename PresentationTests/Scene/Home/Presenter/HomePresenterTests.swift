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
             expect: (homeViewSpyExpect: .init(showLoadingViewArgs: [()],
                                               hideLoadingViewArgs: [()],
                                               showRefreshControlArgs: [],
                                               hideRefreshControlArgs: [(), ()],
                                               reloadDataArgs: [()]),
                      homeWireframeSpyExpect: .init(openExternalBrowserArgs: []),
                      homeUseCaseSpyExpect: .init(getHomeViewDataArgs: [(since: 0, currentDate: currentDate, deleteCache: false)], cancelHomeViewDataRequestArgs: []))
            ),

            (input: (line: #line,
                     viewData: .init(data: []),
                     since: 0,
                     loadingState: .none,
                     htmlUrl: "",
                     getHomeViewDataResult: .failure(HomePresenterTests.notConnectedToInternetError)),
             expect: (homeViewSpyExpect: .init(showLoadingViewArgs: [()],
                                               hideLoadingViewArgs: [()],
                                               showRefreshControlArgs: [],
                                               hideRefreshControlArgs: [(), ()],
                                               reloadDataArgs: []),
                      homeWireframeSpyExpect: .init(openExternalBrowserArgs: []),
                      homeUseCaseSpyExpect: .init(getHomeViewDataArgs: [(since: 0, currentDate: currentDate, deleteCache: false)], cancelHomeViewDataRequestArgs: []))
            ),
        ]

        parameterizedTest(testCases: testCases, expectation: expectation) { _ in
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
             expect: (homeViewSpyExpect: .init(showLoadingViewArgs: [],
                                               hideLoadingViewArgs: [],
                                               showRefreshControlArgs: [],
                                               hideRefreshControlArgs: [],
                                               reloadDataArgs: []),
                      homeWireframeSpyExpect: .init(openExternalBrowserArgs: []),
                      homeUseCaseSpyExpect: .init(getHomeViewDataArgs: [], cancelHomeViewDataRequestArgs: []))
            ),

            // Presenter has ViewData. And the LoadingState is 'showLoading'.
            (input: (line: #line,
                     viewData: .init(data: [.testUser]),
                     since: 100,
                     loadingState: .showLoading,
                     htmlUrl: "",
                     getHomeViewDataResult: .success(HomeViewData(data: [.testOtherObject]))),
             expect: (homeViewSpyExpect: .init(showLoadingViewArgs: [],
                                               hideLoadingViewArgs: [],
                                               showRefreshControlArgs: [],
                                               hideRefreshControlArgs: [],
                                               reloadDataArgs: []),
                      homeWireframeSpyExpect: .init(openExternalBrowserArgs: []),
                      homeUseCaseSpyExpect: .init(getHomeViewDataArgs: [], cancelHomeViewDataRequestArgs: []))
            ),

            // Presenter has ViewData. And the LoadingState is 'showRefreshControl'.
            (input: (line: #line,
                     viewData: .init(data: [.testUser]),
                     since: 100,
                     loadingState: .showRefreshControl,
                     htmlUrl: "",
                     getHomeViewDataResult: .success(HomeViewData(data: [.testOtherObject]))),
             expect: (homeViewSpyExpect: .init(showLoadingViewArgs: [],
                                               hideLoadingViewArgs: [],
                                               showRefreshControlArgs: [],
                                               hideRefreshControlArgs: [],
                                               reloadDataArgs: []),
                      homeWireframeSpyExpect: .init(openExternalBrowserArgs: []),
                      homeUseCaseSpyExpect: .init(getHomeViewDataArgs: [], cancelHomeViewDataRequestArgs: []))
            ),

            // Presenter has ViewData. And the LoadingState is 'none'.
            // Expect reloadData to be called.
            (input: (line: #line,
                     viewData: .init(data: [.testUser]),
                     since: 100,
                     loadingState: .none,
                     htmlUrl: "",
                     getHomeViewDataResult: .success(HomeViewData(data: [.testOtherObject]))),
             expect: (homeViewSpyExpect: .init(showLoadingViewArgs: [()],
                                               hideLoadingViewArgs: [()],
                                               showRefreshControlArgs: [],
                                               hideRefreshControlArgs: [(), ()],
                                               reloadDataArgs: [()]),
                      homeWireframeSpyExpect: .init(openExternalBrowserArgs: []),
                      homeUseCaseSpyExpect: .init(getHomeViewDataArgs: [(since: 100, currentDate: currentDate, deleteCache: false)], cancelHomeViewDataRequestArgs: []))
            ),
        ]

        parameterizedTest(testCases: testCases, expectation: expectation) { _ in
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
             expect: (homeViewSpyExpect: .init(showLoadingViewArgs: [],
                                               hideLoadingViewArgs: [(), ()],
                                               showRefreshControlArgs: [()],
                                               hideRefreshControlArgs: [()],
                                               reloadDataArgs: [()]),
                      homeWireframeSpyExpect: .init(openExternalBrowserArgs: []),
                      homeUseCaseSpyExpect: .init(getHomeViewDataArgs: [(since: 0, currentDate: currentDate, deleteCache: true)], cancelHomeViewDataRequestArgs: [()]))
            ),

            // The request failed.
            // Expect reloadData not to be called.
            (input: (line: #line,
                     viewData: .init(data: [.testUser]),
                     since: 0,
                     loadingState: .none,
                     htmlUrl: "",
                     getHomeViewDataResult: .failure(HomePresenterTests.notConnectedToInternetError)),
             expect: (homeViewSpyExpect: .init(showLoadingViewArgs: [],
                                               hideLoadingViewArgs: [(), ()],
                                               showRefreshControlArgs: [()],
                                               hideRefreshControlArgs: [()],
                                               reloadDataArgs: []),
                      homeWireframeSpyExpect: .init(openExternalBrowserArgs: []),
                      homeUseCaseSpyExpect: .init(getHomeViewDataArgs: [(since: 0, currentDate: currentDate, deleteCache: true)], cancelHomeViewDataRequestArgs: [()]))
            ),
        ]

        parameterizedTest(testCases: testCases, expectation: expectation) { _ in
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
             expect: (homeViewSpyExpect: .init(showLoadingViewArgs: [],
                                               hideLoadingViewArgs: [],
                                               showRefreshControlArgs: [],
                                               hideRefreshControlArgs: [],
                                               reloadDataArgs: []),
                      homeWireframeSpyExpect: .init(openExternalBrowserArgs: [GitHubUser.testUser.htmlUrl]),
                      homeUseCaseSpyExpect: .init(getHomeViewDataArgs: [], cancelHomeViewDataRequestArgs: []))
            ),
        ]

        parameterizedTest(testCases: testCases, expectation: expectation) { testCase in
            presenter.tappedUserPageButton(urlString: testCase.input.htmlUrl)
        }
        wait(for: [expectation], timeout: 3.0)
    }
}

extension HomePresenterTests {

    private static var notConnectedToInternetError: Error {
        NSError(domain: URLError.errorDomain, code: URLError.notConnectedToInternet.rawValue)
    }

    private var currentDate: Date {
        Date.now()
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
        private(set) var showLoadingViewArgs: [Void]
        private(set) var hideLoadingViewArgs: [Void]
        private(set) var showRefreshControlArgs: [Void]
        private(set) var hideRefreshControlArgs: [Void]
        private(set) var reloadDataArgs: [Void]

        init(showLoadingViewArgs: [Void],
             hideLoadingViewArgs: [Void],
             showRefreshControlArgs: [Void],
             hideRefreshControlArgs: [Void],
             reloadDataArgs: [Void]) {
            self.showLoadingViewArgs = showLoadingViewArgs
            self.hideLoadingViewArgs = hideLoadingViewArgs
            self.showRefreshControlArgs = showRefreshControlArgs
            self.hideRefreshControlArgs = hideRefreshControlArgs
            self.reloadDataArgs = reloadDataArgs
        }
    }

    private var showLoadingViewArgs: [Void] = []
    private var hideLoadingViewArgs: [Void] = []
    private var showRefreshControlArgs: [Void] = []
    private var hideRefreshControlArgs: [Void] = []
    private var reloadDataArgs: [Void] = []

    private var expect: Expect

    init(expect: Expect) {
        self.expect = expect
    }

    func showLoadingView() {
        showLoadingViewArgs.append(())
    }

    func hideLoadingView() {
        hideLoadingViewArgs.append(())
    }

    func showRefreshControl() {
        showRefreshControlArgs.append(())
    }

    func hideRefreshControl() {
        hideRefreshControlArgs.append(())
    }

    func reloadData() {
        reloadDataArgs.append(())
    }

    // Reset call counts

    func resetCallCounts() {
        showLoadingViewArgs = []
        hideLoadingViewArgs = []
        showRefreshControlArgs = []
        hideRefreshControlArgs = []
        reloadDataArgs = []
    }

    // Verify
    func verify(line: UInt) {
        XCTAssertEqual(showLoadingViewArgs.count, expect.showLoadingViewArgs.count, "showLoadingViewArgs.count", line: line)
        XCTAssertEqual(hideLoadingViewArgs.count, expect.hideLoadingViewArgs.count, "hideLoadingViewArgs.count", line: line)
        XCTAssertEqual(showRefreshControlArgs.count, expect.showRefreshControlArgs.count, "showRefreshControlArgs.count", line: line)
        XCTAssertEqual(hideRefreshControlArgs.count, expect.hideRefreshControlArgs.count, "hideRefreshControlArgs.count", line: line)
        XCTAssertEqual(reloadDataArgs.count, expect.reloadDataArgs.count, "reloadDataArgs.count", line: line)
    }
}

final class HomeWireframeSpy: HomeWireframe {

    struct Expect {
        private(set) var openExternalBrowserArgs: [String]

        init(openExternalBrowserArgs: [String]) {
            self.openExternalBrowserArgs = openExternalBrowserArgs
        }
    }

    weak var viewController: UIViewController?
    private var openExternalBrowserArgs: [String] = []

    private var expect: Expect

    init(viewController: UIViewController?, expect: Expect) {
        self.viewController = viewController
        self.expect = expect
    }

    func openExternalBrowser(by urlString: String) {
        openExternalBrowserArgs.append(urlString)
    }

    // Reset call counts

    func resetCallCounts() {
        openExternalBrowserArgs = []
    }

    // Verify
    func verify(line: UInt) {
        if expect.openExternalBrowserArgs.isEmpty {
            XCTAssertEqual(openExternalBrowserArgs.count, expect.openExternalBrowserArgs.count, "openExternalBrowserArgs.count", line: line)
        } else {
            XCTAssertEqual(openExternalBrowserArgs[0], expect.openExternalBrowserArgs[0], "openExternalBrowserArgs[0]", line: line)
        }
    }
}

final class HomeUseCaseSpy: HomeUseCase {

    struct Expect {
        private(set) var getHomeViewDataArgs: [(since: Int, currentDate: Date, deleteCache: Bool)]
        private(set) var cancelHomeViewDataRequestArgs: [Void]

        init(getHomeViewDataArgs: [(since: Int, currentDate: Date, deleteCache: Bool)], cancelHomeViewDataRequestArgs: [Void]) {
            self.getHomeViewDataArgs = getHomeViewDataArgs
            self.cancelHomeViewDataRequestArgs = cancelHomeViewDataRequestArgs
        }
    }

    private var getHomeViewDataArgs: [(since: Int, currentDate: Date, deleteCache: Bool)] = []
    private var cancelHomeViewDataRequestArgs: [Void] = []
    private var getHomeViewDataResult: GetHomeViewDataResult

    private var expect: Expect

    init(getHomeViewDataResult: GetHomeViewDataResult, expect: Expect) {
        self.getHomeViewDataResult = getHomeViewDataResult
        self.expect = expect
    }

    func getHomeViewData(since: Int, currentDate: Date, deleteCache: Bool, completion: @escaping Completion) {
        getHomeViewDataArgs.append((since: since, currentDate: currentDate, deleteCache: deleteCache))
        completion(self.getHomeViewDataResult)
    }

    func cancelHomeViewDataRequest() {
        cancelHomeViewDataRequestArgs.append(())
    }

    // Reset call counts

    func resetCallCounts() {
        getHomeViewDataArgs = []
        cancelHomeViewDataRequestArgs = []
    }

    // Verify
    func verify(line: UInt) {
        if expect.getHomeViewDataArgs.isEmpty {
            XCTAssertEqual(getHomeViewDataArgs.count, expect.getHomeViewDataArgs.count, "getHomeViewDataArgs.count", line: line)
        } else {
            // Verifying of the currentDate parameter has been omitted because it was verified in the UseCase test.
            XCTAssertEqual(getHomeViewDataArgs[0].since, expect.getHomeViewDataArgs[0].since, "getHomeViewDataArgs[0].since", line: line)
            XCTAssertEqual(getHomeViewDataArgs[0].deleteCache, expect.getHomeViewDataArgs[0].deleteCache, "getHomeViewDataArgs[0].deleteCache", line: line)
        }
        XCTAssertEqual(cancelHomeViewDataRequestArgs.count, expect.cancelHomeViewDataRequestArgs.count, "cancelHomeViewDataRequestArgs", line: line)
    }
}
