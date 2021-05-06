//
//  RealmInitializerForTest.swift
//  DataTests
//
//  Created by okudera on 2021/05/06.
//

@testable import Data
import RealmSwift

// MARK: - RealmInitializer for unit test

final class RealmInitializerForTest: RealmInitializer {

    let configuration: Realm.Configuration?

    init(configuration: Realm.Configuration? = defaultConfiguration()) {
        self.configuration = configuration
    }

    static func defaultConfiguration() -> Realm.Configuration {
        let configuration = Realm.Configuration(
            inMemoryIdentifier: "UnitTestInMemoryRealm",
            encryptionKey: encryptionKey()
        )
        return configuration
    }

    static func encryptionKey() -> Data? {
        let keyString = "3kE8v5fVtAfskQvJNLUJtRMdyfwzbNbq54V732AoYUjmWrHiZg75zjIZL92Erf6D"
        return keyString.data(using: .utf8)
    }
}
