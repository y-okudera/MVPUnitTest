//
//  APIRequestable.swift
//  Data
//
//  Created by okudera on 2021/05/03.
//

import Alamofire
import Foundation

// MARK: - Protocol
protocol APIRequestable: AnyObject {

    associatedtype Response: Decodable
    associatedtype ErrorResponse: Decodable

    var baseURL: URL { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: [String: Any] { get }
    var encodingType: EncodingType { get }
    var httpHeaderFields: [String: String] { get }
    var timeoutInterval: TimeInterval { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    var allowsCellularAccess: Bool { get }

    func makeURLRequest() -> URLRequest
}

// MARK: - Default implementation
extension APIRequestable {

    var baseURL: URL {
        let url = URL(string: "https://api.github.com")!
        return url
    }

    var method: HTTPMethod {
        return .get
    }

    var parameters: [String: Any] {
        return [:]
    }

    var encodingType: EncodingType {
        return .urlEncoding
    }

    var httpHeaderFields: [String: String] {
        return [
            "Accept": "application/vnd.github.v3+json",
        ]
    }

    var timeoutInterval: TimeInterval {
        return 30
    }

    var cachePolicy: URLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }

    var allowsCellularAccess: Bool {
        return true
    }

    func makeURLRequest() -> URLRequest {
        let endPoint = URL(string: baseURL.absoluteString + path)!
        var urlRequest = URLRequest(url: endPoint)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = httpHeaderFields
        urlRequest.timeoutInterval = timeoutInterval
        urlRequest.cachePolicy = cachePolicy
        urlRequest.allowsCellularAccess = allowsCellularAccess

        // Encoding request parameters
        switch encodingType {
        case .jsonEncoding:
            return urlRequest.jsonEncoding(parameters: parameters)!
        case .urlEncoding:
            return urlRequest.urlEncoding(parameters: parameters)!
        }
    }
}

// MARK: - Private func
private extension URLRequest {

    /// URLEncoding
    ///
    /// - Parameter parameters: Dictionary of request parameters
    /// - Returns: URLRequest
    mutating func urlEncoding(parameters: [String: Any]) -> URLRequest? {
        do {
            self = try Alamofire.URLEncoding.default.encode(self, with: parameters)
            return self
        } catch {
            assertionFailure("URLEncoding error occurred\nURLRequest:\(self)")
            return nil
        }
    }

    /// JSONEncoding
    ///
    /// - Parameter parameters: Dictionary of request parameters
    /// - Returns: URLRequest
    mutating func jsonEncoding(parameters: [String: Any]) -> URLRequest? {
        do {
            self = try Alamofire.JSONEncoding.default.encode(self, with: parameters)
            return self
        } catch {
            assertionFailure("JSONEncoding error occurred\nURLRequest:\(self)")
            return nil
        }
    }
}
