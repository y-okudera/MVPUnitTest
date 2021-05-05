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
}
