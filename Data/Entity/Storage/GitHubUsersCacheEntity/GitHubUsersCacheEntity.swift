//
//  GitHubUsersCacheEntity.swift
//  Data
//
//  Created by okudera on 2021/05/04.
//

import Foundation
import RealmSwift

public final class GitHubUsersCacheEntity: RealmSwift.Object {

    public override static func primaryKey() -> String? {
        return "since"
    }

    @objc public dynamic var since: Int = 0
    @objc public dynamic var lastModified: Date = .init()
    public let responseList = List<GitHubUserEntity>()

    convenience init(since: Int, lastModified: Date, response: [GitHubUserEntity]) {
        self.init()
        self.since = since
        self.lastModified = lastModified
        self.responseList.append(objectsIn: response)
    }
}
