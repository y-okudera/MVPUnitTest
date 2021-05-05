//
//  RealmInitializer.swift
//  Data
//
//  Created by okudera on 2021/05/04.
//

import Common
import Foundation
import RealmSwift

enum RealmInitializerProvider {

    static func provide() -> RealmInitializer {
        return RealmInitializerImpl()
    }
}

protocol RealmInitializer {
    var configuration: Realm.Configuration? { get }

    static func defaultConfiguration() -> Realm.Configuration
    static func encryptionKey() -> Data?
}

private final class RealmInitializerImpl: RealmInitializer {

    let configuration: Realm.Configuration?

    init(configuration: Realm.Configuration? = defaultConfiguration()) {
        self.configuration = configuration
        Logger.debug("Realm fileURL:", configuration?.fileURL?.path ?? "")
    }

    static func defaultConfiguration() -> Realm.Configuration {
        let configuration = Realm.Configuration(encryptionKey: encryptionKey())
        return configuration
    }

    static func encryptionKey() -> Data? {
        let keyString = "3kE8v5fVtAfskQvJNLUJtRMdyfwzbNbq54V732AoYUjmWrHiZg75zjIZL92Erf6D"
        let keyData = keyString.data(using: .utf8)

        Logger.debug(keyData!.map { String(format: "%.2hhx", $0) }.joined())

        return keyData
    }
}
