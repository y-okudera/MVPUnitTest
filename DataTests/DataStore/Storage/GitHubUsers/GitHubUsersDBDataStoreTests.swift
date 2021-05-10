//
//  GitHubUsersDBDataStoreTests.swift
//  DataTests
//
//  Created by okudera on 2021/05/06.
//

@testable import Data
import RealmSwift
import XCTest

final class GitHubUsersDBDataStoreTests: XCTestCase {

    private let inMemoryRealmInitializer = RealmInitializerForTest()
    private var dbDataStore: GitHubUsersDBDataStoreImpl!
    private var usersCacheDao: RealmDaoHelper<GitHubUsersCacheEntity>!
    private var userDao: RealmDaoHelper<GitHubUserEntity>!

    typealias DBCompletion = (Result<Void, Error>) -> Void

    override func setUpWithError() throws {
        let inMemoryRealm = try! Realm(configuration: inMemoryRealmInitializer.configuration!)
        usersCacheDao = .init(realm: inMemoryRealm)
        userDao = .init(realm: inMemoryRealm)
        dbDataStore = .init(usersCacheDao: usersCacheDao, userDao: userDao)
    }

    override func tearDownWithError() throws {
        usersCacheDao = nil
        userDao = nil
        dbDataStore = nil
    }

    // MARK: - func add(entity: , completion: ) tests

    /// Store the GitHubUsersCacheEntity object in Realm.
    ///
    /// Expectation: Result.success is passed to completion handler. And the object is stored in Realm.
    func testAddGitHubUsersCacheEntity() throws {

        // Expect
        let expectation = XCTestExpectation(description: "Result.success is passed to completion handler. And the object is stored in Realm.")

        // Setup
        let expectLastModified = Date()
        let userObject = GitHubUserEntity.testObject
        let object = GitHubUsersCacheEntity(
            since: 0,
            lastModified: expectLastModified,
            response: [userObject]
        )

        let addCompletion: DBCompletion = { [unowned self] addResult in
            guard case .success = addResult else {
                XCTFail("Unexpected.")
                return
            }
            guard let storedObject = usersCacheDao.find(id: 0) else {
                XCTFail("Unexpected.")
                return
            }
            // Verify
            XCTAssertEqual(storedObject.since, 0)
            XCTAssertEqual(storedObject.lastModified, expectLastModified)
            XCTAssertEqual(Array(storedObject.responseList), [userObject])
            expectation.fulfill()
        }

        // Exercise SUT
        dbDataStore.add(entity: object, completion: addCompletion)

        wait(for: [expectation], timeout: 3.0)
    }

    // MARK: - func delete(since: , completion: ) tests

    /// Delete the GitHubUsersCacheEntity object in Realm.
    ///
    /// Expectation: Result.success is passed to completion handler. And the object is deleted in Realm.
    func testDeleteGitHubUsersCacheEntity() throws {

        // Expect
        let expectation = XCTestExpectation(description: "Result.success is passed to completion handler. And the object is deleted in Realm.")

        // Setup
        let expectLastModified = Date()
        let object = GitHubUsersCacheEntity(since: 0, lastModified: expectLastModified, response: [GitHubUserEntity.testObject])

        let deleteCompletion: DBCompletion = { [unowned self] deleteResult in
            guard case .success = deleteResult else {
                XCTFail("Unexpected.")
                return
            }
            // Verify
            XCTAssertEqual(dbDataStore.find(since: 0), nil)
            expectation.fulfill()
        }
        let addCompletion: DBCompletion = { [unowned self] addResult in
            guard case .success = addResult else {
                XCTFail("Unexpected.")
                return
            }
            // Exercise SUT
            dbDataStore.delete(since: 0, completion: deleteCompletion)
        }
        dbDataStore.add(entity: object, completion: addCompletion)

        wait(for: [expectation], timeout: 3.0)
    }

    // MARK: - func deleteAll(completion: ) tests

    /// Delete all GitHubUsersCacheEntity objects in Realm.
    ///
    /// Expectation: Result.success is passed to completion handler. And all objects are deleted in Realm.
    func testDeleteAllGitHubUsersCacheEntities() throws {

        // Expect
        let expectation = XCTestExpectation(description: "Result.success is passed to completion handler. And all objects are deleted in Realm.")

        // Setup
        let expectLastModified = Date()
        let usersCacheObject = GitHubUsersCacheEntity(since: 0, lastModified: expectLastModified, response: [GitHubUserEntity.testObject])
        let otherUsersCacheObject = GitHubUsersCacheEntity(since: 1, lastModified: expectLastModified, response: [GitHubUserEntity.testOtherObject])

        let deleteAllCompletion: DBCompletion = { [unowned self] deleteAllResult in
            guard case .success = deleteAllResult else {
                XCTFail("Unexpected.")
                return
            }
            // Verify
            XCTAssertEqual(dbDataStore.find(since: 0), nil)
            XCTAssertEqual(dbDataStore.find(since: 1), nil)
            expectation.fulfill()
        }
        let addOtherUserCompletion: DBCompletion = { [unowned self] addResult in
            guard case .success = addResult else {
                XCTFail("Unexpected.")
                return
            }
            // Exercise SUT
            dbDataStore.deleteAll(completion: deleteAllCompletion)
        }
        let addUserCompletion: DBCompletion = { [unowned self] addResult in
            guard case .success = addResult else {
                XCTFail("Unexpected.")
                return
            }
            dbDataStore.add(entity: otherUsersCacheObject, completion: addOtherUserCompletion)
        }

        dbDataStore.add(entity: usersCacheObject, completion: addUserCompletion)

        wait(for: [expectation], timeout: 3.0)
    }
}
