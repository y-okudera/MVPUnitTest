//
//  ExceptionCatchable.swift
//  Data
//
//  Created by okudera on 2021/05/04.
//

import Foundation

protocol ExceptionCatchable {}

extension ExceptionCatchable {
    func execute(_ tryBlock: () -> Void) throws {
        try ExceptionHandler.catchException(try: tryBlock)
    }
}
