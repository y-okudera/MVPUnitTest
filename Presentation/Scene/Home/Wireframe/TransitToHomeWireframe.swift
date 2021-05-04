//
//  TransitToHomeWireframe.swift
//  MVPApp
//
//  Created by yuoku on 30/04/2021.
//  Copyright © 2021 yuoku. All rights reserved.
//

import UIKit

protocol TransitToHomeWireframe: AnyObject {
    var viewController: UIViewController? { get }

    /*
     *  EXAMPLE:
     *
     *  func presentHome()
     *  func pushHome()
     */
}

extension TransitToHomeWireframe {
    /*
     *  EXAMPLE:
     *
     *  func pushHome() {
     *      let vc = HomeBuilder.build()
     *      viewController?.navigationController?.pushViewController(vc, animated: true)
     *  }
     *
     *  func presentHome() {
     *      let vc = HomeBuilder.build()
     *      viewController?.present(vc, animated: true)
     *  }
     */
}
