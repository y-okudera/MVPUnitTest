//
//  Date+.swift
//  Common
//
//  Created by okudera on 2021/05/09.
//

import Foundation

extension Date {
    public static func now(dateGenerator: () -> Date = Date.init) -> Date {
        return dateGenerator()
    }
}
