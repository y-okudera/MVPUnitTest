//
//  GitHubUsersRepository.swift
//  Data
//
//  Created by okudera on 2021/05/03.
//

import Common
import Foundation

public enum GitHubUsersRepositoryProvider {

    public static func provide() -> GitHubUsersRepository {
        return GitHubUsersRepositoryImpl(
            apiDataStore: GitHubUsersAPIDataStoreProvider.provide(),
            dbDataStore: GitHubUsersDBDataStoreProvider.provide()
        )
    }
}

public protocol GitHubUsersRepository {
    typealias Response = [GitHubUserEntity]
    typealias ErrorResponse = CommonErrorResponse
    typealias Completion = (Result<Response, APIError<ErrorResponse>>) -> Void
    func getGitHubUsers(since: Int, refreshInterval: TimeInterval, deleteCache: Bool, completion: @escaping Completion)
    func cancelRequest()
}

final class GitHubUsersRepositoryImpl: GitHubUsersRepository {

    private let apiDataStore: GitHubUsersAPIDataStore
    private let dbDataStore: GitHubUsersDBDataStore

    init(apiDataStore: GitHubUsersAPIDataStore, dbDataStore: GitHubUsersDBDataStore) {
        self.apiDataStore = apiDataStore
        self.dbDataStore = dbDataStore
    }

    func getGitHubUsers(since: Int, refreshInterval: TimeInterval, deleteCache: Bool, completion: @escaping Completion) {

        if deleteCache {
            dbDataStore.deleteAll(completion: nil)
        } else if let cachedData = dbDataStore.find(since: since) {
            let elapsedTime = Date().timeIntervalSince(cachedData.lastModified)
            if elapsedTime < refreshInterval {
                Logger.debug("Get the GitHub Users from DB.")
                completion(.success(Array(cachedData.responseList)))
                return
            } else {
                dbDataStore.delete(since: since, completion: nil)
            }
        }
        apiDataStore.getGitHubUsers(since: since) { [weak self] result in
            switch result {
            case .success(let response):
                let usersCacheEntity = GitHubUsersCacheEntity(since: since, lastModified: Date(), response: response)
                self?.dbDataStore.add(entity: usersCacheEntity, completion: nil)
            case .failure:
                break
            }
            completion(result)
        }
    }

    func cancelRequest() {
        apiDataStore.cancelRequest()
    }
}
