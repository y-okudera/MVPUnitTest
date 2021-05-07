//
//  GitHubUsersRequest.swift
//  Data
//
//  Created by okudera on 2021/05/03.
//

import Foundation

final class GitHubUsersRequest: APIRequestable {

    typealias Response = [GitHubUserEntity]
    typealias ErrorResponse = CommonErrorResponse

    let path: String = "/users"

    lazy var parameters: [String: Any] = {
        var parameters = [
            "since": since,
        ]
        return parameters
    }()

    private var since: Int

    init(since: Int) {
        self.since = since
    }
}
