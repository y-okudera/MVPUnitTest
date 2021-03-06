//
//  GitHubUserEntity+.swift
//  DataTests
//
//  Created by okudera on 2021/05/06.
//

import Data

extension GitHubUserEntity {

    static var testObject: GitHubUserEntity {
        GitHubUserEntity(
            login: "mojombo",
            id: 1,
            avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4",
            htmlUrl: "https://github.com/mojombo",
            reposUrl: "https://api.github.com/users/mojombo/repos"
        )
    }

    static var testOtherObject: GitHubUserEntity {
        GitHubUserEntity(
            login: "defunkt",
            id: 2,
            avatarUrl: "https://avatars.githubusercontent.com/u/2?v=4",
            htmlUrl: "https://github.com/defunkt",
            reposUrl: "https://api.github.com/users/defunkt/repos"
        )
    }
}
