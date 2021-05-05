//
//  GitHubUsersDBDataStore.swift
//  Data
//
//  Created by okudera on 2021/05/04.
//

import Foundation

enum GitHubUsersDBDataStoreProvider {

    static func provide() -> GitHubUsersDBDataStore {
        return GitHubUsersDBDataStoreImpl()
    }
}

protocol GitHubUsersDBDataStore {
    typealias Completion = (Result<Void, Error>) -> Void
    func add(entity: GitHubUsersCacheEntity, completion: Completion?)
    func delete(since: Int, completion: Completion?)
    func deleteAll(completion: Completion?)
    func find(since: Int) -> GitHubUsersCacheEntity?
}

private final class GitHubUsersDBDataStoreImpl: GitHubUsersDBDataStore {

    private let usersCacheDao: RealmDaoHelper<GitHubUsersCacheEntity>
    private let userDao: RealmDaoHelper<GitHubUserEntity>

    init(usersCacheDao: RealmDaoHelper<GitHubUsersCacheEntity> = .shared(), userDao: RealmDaoHelper<GitHubUserEntity> = .shared()) {
        self.usersCacheDao = usersCacheDao
        self.userDao = userDao
    }

    func add(entity: GitHubUsersCacheEntity, completion: Completion?) {
        let object = GitHubUsersCacheEntity(value: entity)
        do {
            try usersCacheDao.add(object: object)
            Logger.debug("Added successfully. since:", entity.since)
            completion?(.success(()))
        } catch {
            Logger.error(error)
            completion?(.failure(error))
        }
    }

    func delete(since: Int, completion: Completion?) {
        guard let usersCache = find(since: since) else {
            Logger.debug("The primaryKey is not implemented in the GitHubUsersCacheEntity.")
            return
        }

        let ids = Array(usersCache.responseList).map { $0.id }
        guard let users = userDao.find(ids: ids) else {
            Logger.debug("The primaryKey is not implemented in the GitHubUserEntity.")
            return
        }

        do {
            try usersCacheDao.delete(object: usersCache)
            try userDao.delete(objects: users)
            Logger.debug("Deleted successfully. since:", since)
            completion?(.success(()))
        } catch {
            Logger.error(error)
            completion?(.failure(error))
        }
    }

    func deleteAll(completion: Completion?) {
        do {
            try usersCacheDao.deleteAll()
            try userDao.deleteAll()
            Logger.debug("All data deleted successfully.")
            completion?(.success(()))
        } catch {
            Logger.error(error)
            completion?(.failure(error))
        }
    }

    func find(since: Int) -> GitHubUsersCacheEntity? {
        return usersCacheDao.find(id: since)
    }
}
