//
//  HomeWireframe.swift
//  MVPApp
//
//  Created by yuoku on 30/04/2021.
//  Copyright © 2021 yuoku. All rights reserved.
//

import UIKit

enum HomeWireframeProvider {

    static func provide(viewController: UIViewController?) -> HomeWireframe {
        return HomeWireframeImpl(viewController: viewController)
    }
}

protocol HomeWireframe: AnyObject {
    var viewController: UIViewController? { get set }
}

final class HomeWireframeImpl: HomeWireframe {

    weak var viewController: UIViewController?
    weak var delegate: HomeWireframeDelegate?

    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
}

protocol HomeWireframeDelegate: AnyObject {}
