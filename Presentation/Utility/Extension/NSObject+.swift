//
//  NSObject+.swift
//  Presentation
//
//  Created by okudera on 2021/04/30.
//

import Foundation

extension NSObject {

    /// Get class name.
    static var className: String {
        return String(describing: self)
    }

    /// Get class name from the instance.
    var className: String {
        return type(of: self).className
    }
}
