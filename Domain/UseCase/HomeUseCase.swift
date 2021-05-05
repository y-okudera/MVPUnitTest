//
//  HomeUseCase.swift
//  Domain
//
//  Created by okudera on 2021/05/03.
//

import Common
import Data
import Foundation

public enum HomeUseCaseProvider {

    public static func provide() -> HomeUseCase {
        return HomeUseCaseImpl(repository: GitHubUsersRepositoryProvider.provide(), refreshInterval: 60 * 30)
    }
}

public protocol HomeUseCase: AnyObject {
    typealias Completion = (Result<HomeViewData, Error>) -> Void
    func getHomeViewData(since: Int, deleteCache: Bool, completion: @escaping Completion)
    func cancelHomeViewDataRequest()
}

private final class HomeUseCaseImpl: HomeUseCase {

    let repository: GitHubUsersRepository
    let refreshInterval: TimeInterval

    init(repository: GitHubUsersRepository, refreshInterval: TimeInterval) {
        self.repository = repository
        self.refreshInterval = refreshInterval
    }

    func getHomeViewData(since: Int, deleteCache: Bool, completion: @escaping Completion) {
        Logger.debug()
        repository.getGitHubUsers(since: since, refreshInterval: refreshInterval, deleteCache: deleteCache) { result in
            let translatedResult = result.map { GitHubUsersTranslator.translate($0) }
            switch translatedResult {
            case .success(let homeViewData):
                completion(.success(homeViewData))
            case .failure(let apiError):
                completion(.failure(apiError))
            }
        }
    }

    func cancelHomeViewDataRequest() {
        repository.cancelRequest()
    }
}
