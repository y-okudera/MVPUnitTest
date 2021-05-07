//
//  GitHubUserEntity.swift
//  Data
//
//  Created by okudera on 2021/05/03.
//

import Foundation
import RealmSwift

public final class GitHubUserEntity: RealmSwift.Object, Decodable {

    public override static func primaryKey() -> String? {
        return "id"
    }

    @objc public dynamic var login: String = ""
    @objc public dynamic var id: Int = 0
    @objc public dynamic var avatarUrl: String = ""
    @objc public dynamic var htmlUrl: String = ""
    @objc public dynamic var reposUrl: String = ""

    public convenience init(login: String, id: Int, avatarUrl: String, htmlUrl: String, reposUrl: String) {
        self.init()
        self.login = login
        self.id = id
        self.avatarUrl = avatarUrl
        self.htmlUrl = htmlUrl
        self.reposUrl = reposUrl
    }
}
