//
//  HomePresenter.swift
//  MVPApp
//
//  Created by yuoku on 30/04/2021.
//  Copyright © 2021 yuoku. All rights reserved.
//

import Domain

enum HomePresenterProvider {

    static func provide(view: HomeView?, wireframe: HomeWireframe) -> HomePresenter {
        return HomePresenterImpl(view: view, wireframe: wireframe)
    }
}

protocol HomePresenter: AnyObject {

    var view: HomeView? { get set }
    var wireframe: HomeWireframe { get set }
}

final class HomePresenterImpl: HomePresenter {

    weak var view: HomeView?
    var wireframe: HomeWireframe

    init(view: HomeView?, wireframe: HomeWireframe) {
        self.view = view
        self.wireframe = wireframe
    }
}
