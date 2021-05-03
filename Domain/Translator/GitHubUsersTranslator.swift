//
//  GitHubUsersTranslator.swift
//  Domain
//
//  Created by okudera on 2021/05/03.
//

import Data
import Foundation

enum GitHubUsersTranslator: Translator {
    static func translate(_ entity: [GitHubUsersResponse]) -> HomeViewData {
        HomeViewData(data: entity.map {
            GitHubUser(id: $0.id, name: $0.login, thumbnailUrl: $0.avatarUrl, htmlUrl: $0.htmlUrl, reposUrl: $0.reposUrl)
        })
    }
}
