//
//  GitHubUsersAPIDataStore.swift
//  Data
//
//  Created by okudera on 2021/05/03.
//

import Common
import Alamofire
import Foundation

enum GitHubUsersAPIDataStoreProvider {

    static func provide() -> GitHubUsersAPIDataStore {
        return GitHubUsersAPIDataStoreImpl()
    }
}

protocol GitHubUsersAPIDataStore {
    typealias Completion = (Result<GitHubUsersRequest.Response, APIError<GitHubUsersRequest.ErrorResponse>>) -> Void
    func getGitHubUsers(since: Int, completion: @escaping Completion)
    func cancelRequest()
}

private final class GitHubUsersAPIDataStoreImpl: GitHubUsersAPIDataStore {

    private let apiClient: APIClient
    private var dataRequest: DataRequest?

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func getGitHubUsers(since: Int, completion: @escaping Completion) {
        dataRequest = apiClient.request(GitHubUsersRequest(since: since)) { [weak self] result in
            self?.dataRequest = nil
            completion(result)
        }
    }

    func cancelRequest() {
        guard let dataRequest = self.dataRequest else {
            Logger.debug("The GitHub Users API has not been requested.")
            return
        }
        apiClient.cancelRequest(dataRequest)
    }
}
