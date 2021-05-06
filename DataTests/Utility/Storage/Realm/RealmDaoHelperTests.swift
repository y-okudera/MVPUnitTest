//
//  RealmDaoHelperTests.swift
//  DataTests
//
//  Created by okudera on 2021/05/05.
//

@testable import Data
import RealmSwift
import XCTest

final class RealmDaoHelperTests: XCTestCase {

    private let inMemoryRealmInitializer = RealmInitializerForTest()
    private var dao: RealmDaoHelper<GitHubUserEntity>!

    override func setUpWithError() throws {
        dao = .init(realm: try! Realm(configuration: inMemoryRealmInitializer.configuration!))
    }

    override func tearDownWithError() throws {
        dao = nil
    }

    // MARK: - func newId() tests

    /// Create new id when no objects are stored in Realm.
    func testCreateNewIdWhenNoObjectsAreStored() {

        // Exercise SUT
        let newId = dao.newId()

        // Verify
        XCTAssertEqual(newId, 1)
    }

    /// Create new id when one object is stored in Realm.
    func testCreateNewIdWhenOneObjectIsStored() {

        // Setup
        let testObject = GitHubUserEntity.testObject
        try! dao.add(object: GitHubUserEntity(value: testObject))

        // Exercise SUT
        let newId = dao.newId()

        // Verify
        XCTAssertEqual(newId, 2)
    }

    // MARK: - func add(object: ) tests

    /// Store one object in Realm.
    func testAddObject() throws {

        // Setup
        let testObject = GitHubUserEntity.testObject

        // Exercise SUT
        try! dao.add(object: GitHubUserEntity(value: testObject))

        // Verify
        let findResult = dao.findAll()
        XCTAssertEqual(findResult.count, 1)

        let storedObject = Array(findResult)[0]
        XCTAssertEqual(storedObject.login, "mojombo")
        XCTAssertEqual(storedObject.id, 1)
        XCTAssertEqual(storedObject.avatarUrl, "https://avatars.githubusercontent.com/u/1?v=4")
        XCTAssertEqual(storedObject.htmlUrl, "https://github.com/mojombo")
        XCTAssertEqual(storedObject.reposUrl, "https://api.github.com/users/mojombo/repos")
    }

    // MARK: - func add(objects: ) tests

    /// Store multiple data in Realm.
    func testAddObjects() throws {

        // Setup
        let testObject = GitHubUserEntity.testObject
        let testOtherObject = GitHubUserEntity.testOtherObject

        let objects = [GitHubUserEntity(value: testObject), GitHubUserEntity(value: testOtherObject)]

        // Exercise SUT
        try! dao.add(objects: objects.map { .init(value: $0) })

        // Verify
        let findResult = dao.findAll()
        XCTAssertEqual(findResult.count, 2)

        let storedFirstObject = Array(findResult)[0]
        XCTAssertEqual(storedFirstObject.login, "mojombo")
        XCTAssertEqual(storedFirstObject.id, 1)
        XCTAssertEqual(storedFirstObject.avatarUrl, "https://avatars.githubusercontent.com/u/1?v=4")
        XCTAssertEqual(storedFirstObject.htmlUrl, "https://github.com/mojombo")
        XCTAssertEqual(storedFirstObject.reposUrl, "https://api.github.com/users/mojombo/repos")

        let storedSecondObject = Array(findResult)[1]
        XCTAssertEqual(storedSecondObject.login, "defunkt")
        XCTAssertEqual(storedSecondObject.id, 2)
        XCTAssertEqual(storedSecondObject.avatarUrl, "https://avatars.githubusercontent.com/u/2?v=4")
        XCTAssertEqual(storedSecondObject.htmlUrl, "https://github.com/defunkt")
        XCTAssertEqual(storedSecondObject.reposUrl, "https://api.github.com/users/defunkt/repos")
    }

    // MARK: - func update(object: , block: ) tests

    /// Update one data in Realm.
    func testUpdateObject() throws {

        // Setup
        let testObject = GitHubUserEntity.testObject
        try! dao.add(object: GitHubUserEntity(value: testObject))
        guard let storedObject = dao.find(id: testObject.id) else {
            XCTFail("Unexpected.")
            return
        }

        // Exercise SUT
        try! dao.update(object: storedObject) { targetObject in
            targetObject.login = "TEST USER"
        }

        // Verify
        guard let updatedObject = dao.find(id: testObject.id) else {
            XCTFail("Unexpected.")
            return
        }
        XCTAssertEqual(updatedObject.login, "TEST USER")
    }

    // MARK: - func deleteAll() tests

    /// Delete all objects in Realm.
    func testDeleteAll() throws {

        // Setup
        let testObject = GitHubUserEntity.testObject
        let testOtherObject = GitHubUserEntity.testOtherObject

        let objects = [GitHubUserEntity(value: testObject), GitHubUserEntity(value: testOtherObject)]

        try! dao.add(objects: objects.map { .init(value: $0) })
        XCTAssertEqual(dao.findAll().count, 2)

        // Exercise SUT
        try! dao.deleteAll()

        // Verify
        XCTAssertEqual(dao.findAll().count, 0)
    }

    // MARK: - func delete(object: ) tests

    /// Delete one data in Realm.
    func testDeleteObject() throws {

        // Setup
        let testObject = GitHubUserEntity.testObject

        try! dao.add(object: GitHubUserEntity(value: testObject))
        XCTAssertEqual(dao.findAll().count, 1)

        guard let findResult = dao.find(id: testObject.id) else {
            XCTFail("Unexpected.")
            return
        }

        // Exercise SUT
        try! dao.delete(object: findResult)

        // Verify
        XCTAssertEqual(dao.findAll().count, 0)
    }

    // MARK: - func delete(objects: Results<T>) tests

    /// Delete multiple data in Realm.
    func testDeleteObjects() throws {

        // Setup
        let testObject = GitHubUserEntity.testObject
        let testOtherObject = GitHubUserEntity.testOtherObject

        let objects = [GitHubUserEntity(value: testObject), GitHubUserEntity(value: testOtherObject)]

        try! dao.add(objects: objects.map { .init(value: $0) })
        XCTAssertEqual(dao.findAll().count, 2)

        guard let findResult = dao.find(ids: [testObject.id, testOtherObject.id]) else {
            XCTFail("Unexpected.")
            return
        }

        // Exercise SUT
        try! dao.delete(objects: findResult)

        // Verify
        XCTAssertEqual(dao.findAll().count, 0)
    }

    // MARK: - func transaction(block: ) tests

    /// Write data in transaction of Realm.
    func testTransaction() throws {

        // Expect
        let expectation = XCTestExpectation(description: "Writing data in a realm transaction does not cause an error.")

        // Setup
        let testObject = GitHubUserEntity.testObject
        let testOtherObject = GitHubUserEntity.testOtherObject
        let objects = [GitHubUserEntity(value: testObject), GitHubUserEntity(value: testOtherObject)]

        // Exercise SUT
        try! dao.transaction(block: { [weak self] in

            // Add
            try! self?.dao.add(objects: objects.map { .init(value: $0) })

            // Find
            guard let findResult = self?.dao.find(id: testOtherObject.id) else {
                XCTFail("Unexpected.")
                return
            }

            // Delete
            try! self?.dao.delete(object: findResult)

            // Update
            try! self?.dao.update(object: testObject) { targetObject in
                targetObject.login = "TEST USER"
            }

        }, completion: { [weak self] in
            XCTAssertEqual(self?.dao.findAll().count, 1)
            XCTAssertEqual(self?.dao.findAll()[0].login, "TEST USER")
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 10.0)
    }
}

// MARK: - GitHubUserEntity convenience initializer

private extension GitHubUserEntity {

    convenience init(login: String, id: Int, avatarUrl: String, htmlUrl: String, reposUrl: String) {
        self.init()
        self.login = login
        self.id = id
        self.avatarUrl = avatarUrl
        self.htmlUrl = htmlUrl
        self.reposUrl = reposUrl
    }

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
