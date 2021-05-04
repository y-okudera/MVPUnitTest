//
//  HomeUseCase.swift
//  Domain
//
//  Created by okudera on 2021/05/03.
//

import Data
import Foundation

public enum HomeUseCaseProvider {

    public static func provide() -> HomeUseCase {
        return HomeUseCaseImpl(repository: GitHubUsersRepositoryProvider.provide())
    }
}

public protocol HomeUseCase: AnyObject {
    typealias Completion = (Result<HomeViewData, Error>) -> Void
    func getHomeViewData(since: Int, completion: @escaping Completion)
    func cancelHomeViewDataRequest()
}

private final class HomeUseCaseImpl: HomeUseCase {

    let repository: GitHubUsersRepository

    init(repository: GitHubUsersRepository) {
        self.repository = repository
    }

    func getHomeViewData(since: Int, completion: @escaping Completion) {
        repository.getGitHubUsers(since: since) { result in
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
