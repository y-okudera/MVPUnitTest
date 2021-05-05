//
//  HomeViewController.swift
//  MVPApp
//
//  Created by yuoku on 30/04/2021.
//  Copyright © 2021 yuoku. All rights reserved.
//

import Domain
import Nuke
import UIKit

protocol HomeView: AnyObject {
    func showLoadingView()
    func hideLoadingView()
    func showRefreshControl()
    func hideRefreshControl()
    func reloadData()
}

final class HomeViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var tableView: UITableView! {
        willSet {
            newValue.register(cellTypes: [GitHubUserTableViewCell.self])
            newValue.tableFooterView = UIView()
            let refreshControl = UIRefreshControl()
            refreshControl.attributedTitle = .init(string: "Pull To Refresh")
            refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
            newValue.refreshControl = refreshControl
        }
    }

    // MARK: - Properties

    var presenter: HomePresenter!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addActivityIndicatorView()
        presenter.viewDidLoad()
    }

    // MARK: - Selectors

    @objc
    private func refresh(_ sender: UIRefreshControl) {
        presenter.pullToRefresh()
    }
}

// MARK: - HomeView
extension HomeViewController: HomeView {

    func showLoadingView() {
        startAnimating()
    }

    func hideLoadingView() {
        stopAnimating()
    }

    func showRefreshControl() {
        tableView.refreshControl?.beginRefreshing()
    }

    func hideRefreshControl() {
        tableView.refreshControl?.endRefreshing()
    }

    func reloadData() {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.viewData.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: GitHubUserTableViewCell.self, for: indexPath)
        cell.configure(data: presenter.viewData.data[indexPath.row])

        cell.userPageButtonHandler = { [weak self] urlString in
            guard let urlString = urlString else {
                return
            }
            self?.presenter.tappedUserPageButton(urlString: urlString)
        }

        cell.repositoriesPageButtonHandler = { [weak self] urlString in
            guard let urlString = urlString else {
                return
            }
            self?.presenter.tappedRepositoriesPageButton(urlString: urlString)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {

}

// MARK: - UITableViewDataSourcePrefetching
extension HomeViewController: UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap { presenter.viewData.data[$0.row].thumbnailUrl }
        ImagePrefetcher().startPrefetching(with: urls)
    }

    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        ImagePrefetcher().stopPrefetching()
    }
}

// MARK: - UIScrollViewDelegate
extension HomeViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isNearBottomEdge() {
            presenter.reachedBottom()
        }
    }
}
