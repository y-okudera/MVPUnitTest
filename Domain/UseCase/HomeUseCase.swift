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
    func get(since: Int, completion: @escaping(Result<HomeViewData, Error>) -> Void)
}

private final class HomeUseCaseImpl: HomeUseCase {

    let repository: GitHubUsersRepository

    init(repository: GitHubUsersRepository) {
        self.repository = repository
    }

    func get(since: Int, completion: @escaping(Result<HomeViewData, Error>) -> Void) {
        self.repository.get(since: since) { result in
            switch result {
            case .success(let response):
                completion(.success(GitHubUsersTranslator.translate(response)))
            case .failure(let apiError):
                completion(.failure(apiError))
            }
        }
    }
}
