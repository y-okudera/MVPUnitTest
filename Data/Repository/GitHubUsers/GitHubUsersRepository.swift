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
    typealias Completion = (Result<Response, APIError<ErrorResponse>>) -> Void
    func getGitHubUsers(since: Int, completion: @escaping Completion)
    func cancelRequest()
}

private final class GitHubUsersRepositoryImpl: GitHubUsersRepository {

    private let apiDataStore: GitHubUsersAPIDataStore

    init(apiDataStore: GitHubUsersAPIDataStore) {
        self.apiDataStore = apiDataStore
    }

    func getGitHubUsers(since: Int, completion: @escaping Completion) {
        return apiDataStore.getGitHubUsers(since: since, completion: completion)
    }

    func cancelRequest() {
        apiDataStore.cancelRequest()
    }
}
