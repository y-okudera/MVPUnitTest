//
//  HomePresenter.swift
//  MVPApp
//
//  Created by yuoku on 30/04/2021.
//  Copyright © 2021 yuoku. All rights reserved.
//

import Common
import Domain
import Foundation

enum HomePresenterProvider {

    static func provide(view: HomeView?,
                        wireframe: HomeWireframe,
                        homeUseCase: HomeUseCase) -> HomePresenter {
        return HomePresenterImpl(
            view: view,
            wireframe: wireframe,
            homeUseCase: homeUseCase
        )
    }
}

protocol HomePresenter: AnyObject {

    var view: HomeView? { get }
    var viewData: HomeViewData { get }

    func viewDidLoad()
    func reachedBottom()
    func pullToRefresh()
    func tappedUserPageButton(urlString: String)
    func tappedRepositoriesPageButton(urlString: String)
}

final class HomePresenterImpl: HomePresenter {

    weak var view: HomeView?
    var viewData = HomeViewData(data: [])

    private let wireframe: HomeWireframe
    private let homeUseCase: HomeUseCase

    private var since = 0
    private var loadingState = LoadingState.none {
        didSet {
            switch loadingState {
            case .none:
                view?.hideLoadingView()
                view?.hideRefreshControl()
            case .showLoading:
                view?.hideRefreshControl()
                view?.showLoadingView()
            case .showRefreshControl:
                view?.hideLoadingView()
                view?.showRefreshControl()
            }
        }
    }

    init(view: HomeView?, wireframe: HomeWireframe, homeUseCase: HomeUseCase) {
        self.view = view
        self.wireframe = wireframe
        self.homeUseCase = homeUseCase
    }

    func viewDidLoad() {
        resetSinceValue()
        requestHomeViewData(loadingState: .showLoading, deleteCache: false)
    }

    func reachedBottom() {
        guard !viewData.data.isEmpty else {
            Logger.debug("Initial request has not been completed.")
            return
        }
        guard !loadingState.isLoading() else {
            Logger.debug("isLoading")
            return
        }
        requestHomeViewData(loadingState: .showLoading, deleteCache: false)
    }

    func pullToRefresh() {
        homeUseCase.cancelHomeViewDataRequest()
        resetSinceValue()
        requestHomeViewData(loadingState: .showRefreshControl, deleteCache: true)
    }

    func tappedUserPageButton(urlString: String) {
        wireframe.openExternalBrowser(by: urlString)
    }

    func tappedRepositoriesPageButton(urlString: String) {
        // FIXME: Transit to the repository list screen.
    }
}

extension HomePresenterImpl {

    enum LoadingState {
        case none
        case showLoading
        case showRefreshControl

        func isLoading() -> Bool {
            switch self {
            case .none:
                return false
            case .showLoading:
                return true
            case .showRefreshControl:
                return true
            }
        }
    }

    func setLoadingState(_ loadingState: LoadingState) {
        self.loadingState = loadingState
    }

    func setSinceValue(lastUserId: Int) {
        since = lastUserId
    }

    private var isInitialRequest: Bool {
        since == 0
    }

    private func resetSinceValue() {
        setSinceValue(lastUserId: 0)
    }

    private func updateHomeViewData(_ viewData: HomeViewData) {
        if isInitialRequest {
            self.viewData = viewData
        } else {
            self.viewData.data.append(contentsOf: viewData.data)
        }
        setSinceValue(lastUserId: viewData.data.last?.id ?? 0)
    }

    private func requestHomeViewData(loadingState: LoadingState, currentDate: Date = .now(), deleteCache: Bool) {
        setLoadingState(loadingState)
        homeUseCase.getHomeViewData(since: since, currentDate: currentDate, deleteCache: deleteCache) { [weak self] result in
            switch result {
            case .success(let viewData):
                self?.updateHomeViewData(viewData)
                self?.view?.reloadData()
            case .failure(let error):
                Logger.error("error", error)
            }
            self?.setLoadingState(.none)
        }
    }
}
