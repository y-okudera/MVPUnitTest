//
//  DateGenerator.swift
//  Common
//
//  Created by okudera on 2021/05/09.
//

import Foundation

public enum DateGenerator {

    public static func generate(dateString: String,
                                dateFormat: String = "yyyyMMddHHmmss",
                                timeZone: TimeZone! = TimeZone(identifier: "Asia/Tokyo")) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat

        // Locale setting that does not depend on the device calendar setting.
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        // Explicit setting that does not depend on the device timezone setting.
        dateFormatter.timeZone = timeZone

        return dateFormatter.date(from: dateString)!
    }
}
