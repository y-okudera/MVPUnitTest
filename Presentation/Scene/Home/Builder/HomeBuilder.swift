//
//  HomeBuilder.swift
//  MVPApp
//
//  Created by yuoku on 30/04/2021.
//  Copyright © 2021 yuoku. All rights reserved.
//

import Domain
import UIKit

public enum HomeBuilder {

    public static func build() -> UIViewController {
        let viewController = HomeViewController.instantiate()
        let wireframe = HomeWireframeProvider.provide(viewController: viewController)
        let presenter = HomePresenterProvider.provide(view: viewController, wireframe: wireframe)

        viewController.presenter = presenter

        return viewController
    }
}
