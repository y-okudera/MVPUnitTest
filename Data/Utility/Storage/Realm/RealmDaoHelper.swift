//
//  RealmDaoHelper.swift
//  Data
//
//  Created by okudera on 2021/05/04.
//

import Common
import Foundation
import RealmSwift

final class RealmDaoHelper<T: RealmSwift.Object>: ExceptionCatchable {

    var realm: Realm

    init(realm: Realm) {
        self.realm = realm
    }

    // MARK: - Create a new primary key

    /// Create a new primary key like AUTO_INCREMENT.
    func newId() -> Int? {
        guard let primaryKey = T.primaryKey() else {
            Logger.error("The primary key is undefined.")
            return nil
        }
        if let maxValue = realm.objects(T.self).max(ofProperty: primaryKey) as Int? {
            return maxValue + 1
        } else {
            return 1
        }
    }

    // MARK: - Add record

    func add(object: T) throws {
        let executionError = executionBlock(realm: realm) { [weak self] in
            self?.realm.add(object)
        }
        if let executionError = executionError {
            throw executionError
        }
    }

    func add(objects: [T]) throws {
        let executionError = executionBlock(realm: realm) { [weak self] in
            self?.realm.add(objects)
        }
        if let executionError = executionError {
            throw executionError
        }
    }

    // MARK: - Update record

    /// - Precondition: Valid only when `primaryKey()` is implemented in T.
    func update(object: T, block:((T) -> Void)? = nil) throws {
        let executionError = executionBlock(realm: realm) { [weak self] in
            block?(object)
            self?.realm.add(object, update: .modified)
        }
        if let executionError = executionError {
            throw executionError
        }
    }

    // MARK: - Delete records

    func deleteAll() throws {
        let objects = realm.objects(T.self)

        let executionError = executionBlock(realm: realm) { [weak self] in
            self?.realm.delete(objects)
        }
        if let executionError = executionError {
            throw executionError
        }
    }

    func delete(object: T) throws {
        let executionError = executionBlock(realm: realm) { [weak self] in
            self?.realm.delete(object)
        }
        if let executionError = executionError {
            throw executionError
        }
    }

    func delete(objects: Results<T>) throws {
        let executionError = executionBlock(realm: realm) { [weak self] in
            self?.realm.delete(objects)
        }
        if let executionError = executionError {
            throw executionError
        }
    }

    // MARK: - Find records

    func findAll() -> Results<T> {
        return realm.objects(T.self)
    }

    func findAllConvertedToArray() -> [T] {
        return Array(findAll())
    }

    func find(id: Any) -> T? {
        return realm.object(ofType: T.self, forPrimaryKey: id)
    }

    func find(ids: [Any]) -> Results<T>? {
        guard let pk = T.primaryKey() else {
            return nil
        }
        let predicate = NSPredicate(format: "\(pk) IN %@", ids)
        let results = realm.objects(T.self).filter(predicate)
        return results
    }

    // MARK: - Write transaction

    func transaction(block: @escaping () throws -> Void, completion: (() -> Void)? = nil) throws {
        realm.beginWrite()
        do {
            try block()
            try realm.commitWrite()
            completion?()
        } catch {
            Logger.error("transaction", error, "realm.cancelWrite()")
            realm.cancelWrite()
            throw error
        }
    }
}

// MARK: - private
private extension RealmDaoHelper {

    func executionBlock(realm: Realm, block:(() -> Void)? = nil) -> Swift.Error? {
        if !realm.isInWriteTransaction {
            return outsideOfTransactionBlock(realm: realm, block: block)
        }

        do {
            try execute {
                block?()
            }
            return nil

        } catch {
            Logger.error("executionBlock error:", error)
            return error
        }
    }

    func outsideOfTransactionBlock(realm: Realm, block:(() -> Void)? = nil) -> Swift.Error? {
        do {
            try realm.write {
                try execute {
                    block?()
                }
            }
            return nil

        } catch {
            Logger.error("outsideOfTransactionBlock error:", error)
            return error
        }
    }
}
