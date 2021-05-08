//
//  GitHubUser+.swift
//  PresentationTests
//
//  Created by okudera on 2021/05/07.
//

import Domain

extension GitHubUser {
    static var testUser: GitHubUser {
        .init(
            id: 1,
            name: "mojombo",
            thumbnailUrl: URL(string: "https://avatars.githubusercontent.com/u/1?v=4"),
            htmlUrl: "https://github.com/mojombo",
            reposUrl: "https://api.github.com/users/mojombo/repos"
        )
    }

    static var testOtherObject: GitHubUser {
        .init(
            id: 2,
            name: "defunkt",
            thumbnailUrl: URL(string: "https://avatars.githubusercontent.com/u/2?v=4"),
            htmlUrl: "https://github.com/defunkt",
            reposUrl: "https://api.github.com/users/defunkt/repos"
        )
    }
}
