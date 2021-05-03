//
//  Bundle+.swift
//  Presentation
//
//  Created by okudera on 2021/04/30.
//

import Foundation

extension Bundle {
    static var current: Bundle {
        class DummyClass {}
        return Bundle(for: type(of: DummyClass()))
    }
}
