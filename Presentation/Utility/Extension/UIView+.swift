//
//  UIView+.swift
//  Presentation
//
//  Created by okudera on 2021/05/04.
//

import UIKit

extension UIView {

    var recursiveSubviews: [UIView] {
        return subviews + subviews.flatMap { $0.recursiveSubviews }
    }

    func findViews<T: UIView>(subclassOf: T.Type) -> [T] {
        return recursiveSubviews.compactMap { $0 as? T }
    }
}
