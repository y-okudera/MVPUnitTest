//
//  GitHubUsersAPIDataStore.swift
//  Data
//
//  Created by okudera on 2021/05/03.
//

import Foundation

enum GitHubUsersAPIDataStoreProvider {

    static func provide() -> GitHubUsersAPIDataStore {
        return GitHubUsersAPIDataStoreImpl()
    }
}

protocol GitHubUsersAPIDataStore {
    func get(since: Int, completion: @escaping(Result<GitHubUsersRequest.Response, APIError<GitHubUsersRequest.ErrorResponse>>) -> Void)
}

private final class GitHubUsersAPIDataStoreImpl: GitHubUsersAPIDataStore {

    var apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func get(since: Int, completion: @escaping(Result<GitHubUsersRequest.Response, APIError<GitHubUsersRequest.ErrorResponse>>) -> Void) {
        apiClient.request(GitHubUsersRequest(since: since), completion: completion)
    }
}
