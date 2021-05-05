//
//  RealmDaoHelper+.swift
//  Data
//
//  Created by okudera on 2021/05/04.
//

import Foundation
import RealmSwift

private func threadSharedObject<T: AnyObject>(key: String, create: () -> T) -> T {
    if let cachedObj = Thread.current.threadDictionary[key] as? T {
        Logger.debug(Thread.current, cachedObj)
        return cachedObj
    }
    let newObject = create()
    Thread.current.threadDictionary[key] = newObject
    return newObject
}

extension RealmDaoHelper {

    static func shared(realmInitializer: RealmInitializer = RealmInitializerProvider.provide()) -> RealmDaoHelper<T> {
        let key = Bundle.main.bundleIdentifier! + ".RealmDaoHelper." + T.className()
        Logger.debug(Thread.current, "key", key)
        let realmDaoHelper: RealmDaoHelper<T> = threadSharedObject(key: key) {
            Logger.debug(Thread.current, "New RealmDaoHelper instance.")
            do {
                if let configuration = realmInitializer.configuration {
                    let realm = try Realm(configuration: configuration)
                    return RealmDaoHelper<T>(realm: realm)
                } else {
                    let realm = try Realm()
                    return RealmDaoHelper<T>(realm: realm)
                }

            } catch {
                fatalError("Realm initialize error: \(error)")
            }
        }
        return realmDaoHelper
    }
}
