//
//  HomeViewController.swift
//  MVPApp
//
//  Created by yuoku on 30/04/2021.
//  Copyright © 2021 yuoku. All rights reserved.
//

import UIKit

protocol HomeView: AnyObject {

}

final class HomeViewController: UIViewController {

    var presenter: HomePresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.debug()
    }
}

// MARK: - HomeView
extension HomeViewController: HomeView {

}
