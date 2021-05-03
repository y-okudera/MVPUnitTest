//
//  GitHubUsersRepository.swift
//  Data
//
//  Created by okudera on 2021/05/03.
//

import Foundation

public enum GitHubUsersRepositoryProvider {

    public static func provide() -> GitHubUsersRepository {
        return GitHubUsersRepositoryImpl(apiDataStore: GitHubUsersAPIDataStoreProvider.provide())
    }
}

public protocol GitHubUsersRepository {
    typealias Response = [GitHubUsersResponse]
    typealias ErrorResponse = CommonErrorResponse
    func get(since: Int, completion: @escaping(Result<Response, APIError<ErrorResponse>>) -> Void)
}

private final class GitHubUsersRepositoryImpl: GitHubUsersRepository {

    private let apiDataStore: GitHubUsersAPIDataStore

    init(apiDataStore: GitHubUsersAPIDataStore) {
        self.apiDataStore = apiDataStore
    }

    func get(since: Int, completion: @escaping(Result<GitHubUsersRequest.Response, APIError<GitHubUsersRequest.ErrorResponse>>) -> Void) {
        return apiDataStore.get(since: since, completion: completion)
    }
}
