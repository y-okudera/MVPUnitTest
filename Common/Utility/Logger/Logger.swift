//
//  Logger.swift
//  Common
//
//  Created by okudera on 2021/03/20.
//

import Foundation

public enum Logger {

    public static func verbose(_ items: Any..., file: NSString = #file, function: String = #function, line: Int = #line) {
        #if PROD
        #else
        let now = DateFormatter.shared.string(from: Date())
        let fileName = (file.deletingPathExtension as NSString).lastPathComponent
        print("💁‍♂️Verbose💁‍♂️ \(now) \(fileName) \(function) L\(line) >", items.toString)
        #endif
    }

    public static func debug(_ items: Any..., file: NSString = #file, function: String = #function, line: Int = #line) {
        #if PROD
        #else
        let now = DateFormatter.shared.string(from: Date())
        let fileName = (file.deletingPathExtension as NSString).lastPathComponent
        print("🐸Debug🐸 \(now) \(fileName) \(function) L\(line) >", items.toString)
        #endif
    }

    public static func info(_ items: Any..., file: NSString = #file, function: String = #function, line: Int = #line) {
        #if PROD
        #else
        let now = DateFormatter.shared.string(from: Date())
        let fileName = (file.deletingPathExtension as NSString).lastPathComponent
        print("🐒Info🐒 \(now) \(fileName) \(function) L\(line) >", items.toString)
        #endif
    }

    public static func warning(_ items: Any..., file: NSString = #file, function: String = #function, line: Int = #line) {
        #if PROD
        #else
        let now = DateFormatter.shared.string(from: Date())
        let fileName = (file.deletingPathExtension as NSString).lastPathComponent
        print("⚠️Warning⚠️ \(now) \(fileName) \(function) L\(line) >", items.toString)
        #endif
    }

    public static func error(_ items: Any..., file: NSString = #file, function: String = #function, line: Int = #line) {
        #if PROD
        #else
        let now = DateFormatter.shared.string(from: Date())
        let fileName = (file.deletingPathExtension as NSString).lastPathComponent
        print("🔥Error🔥 \(now) \(fileName) \(function) L\(line) >", items.toString)
        #endif
    }

    public static func fatal(_ items: Any..., file: NSString = #file, function: String = #function, line: Int = #line) {
        #if PROD
        #else
        let now = DateFormatter.shared.string(from: Date())
        let fileName = (file.deletingPathExtension as NSString).lastPathComponent
        print("👹Fatal👹 \(now) \(fileName) \(function) L\(line) >", items.toString)
        #endif
    }

    private func log(_ items: Any..., file: NSString = #file, function: String = #function, line: Int = #line) {
        #if PROD
        #else
        let now = DateFormatter.shared.string(from: Date())
        let fileName = (file.deletingPathExtension as NSString).lastPathComponent
        print("\(now) \(fileName) \(function) L\(line) >", items.toString)
        #endif
    }
}

private extension Array {
    var toString: String {
        var str = ""
        self.forEach {
            str += "\($0) "
        }
        return String(str.dropLast())
    }
}

private extension DateFormatter {
    static let shared: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "HmsSSS", options: 0, locale: .current)
        return dateFormatter
    }()
}
