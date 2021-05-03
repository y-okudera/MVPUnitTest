//
//  Translator.swift
//  Domain
//
//  Created by okudera on 2021/05/03.
//

import Foundation

protocol Translator {
    associatedtype Input
    associatedtype Output

    static func translate(_ entity: Input) -> Output
}
