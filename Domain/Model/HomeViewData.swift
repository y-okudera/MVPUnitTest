//
//  HomeViewData.swift
//  Domain
//
//  Created by okudera on 2021/05/03.
//

import Foundation

public struct HomeViewData {
    public var data: [GitHubUser]

    public init(data: [GitHubUser]) {
        self.data = data
    }
}

public struct GitHubUser {
    public let id: Int
    public let name: String

    /// User's thumbnail image URL.
    public let thumbnailUrl: URL?

    /// User page URL.
    public let htmlUrl: String

    /// User's repositories page URL.
    public let reposUrl: String

    public init(id: Int, name: String, thumbnailUrl: URL?, htmlUrl: String, reposUrl: String) {
        self.id = id
        self.name = name
        self.thumbnailUrl = thumbnailUrl
        self.htmlUrl = htmlUrl
        self.reposUrl = reposUrl
    }
}
