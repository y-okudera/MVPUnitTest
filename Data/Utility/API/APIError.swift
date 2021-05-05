//
//  APIError.swift
//  Data
//
//  Created by okudera on 2021/05/03.
//

import Alamofire
import Common
import Foundation

public enum APIError<ErrorResponse: Decodable>: Error {
    case cancelled
    case connectionError
    case errorResponse(ErrorResponse)
    case others(error: Error)
}

extension APIError {
    init(afError: AFError, responseData: Data?) {
        switch afError {
        case .responseSerializationFailed:
            guard let errorResponse = Self.decode(errorResponseData: responseData) else {
                Logger.error("APIError.others")
                self = .others(error: afError)
                return
            }
            Logger.error("APIError.errorResponse")
            self = .errorResponse(errorResponse)
        case .explicitlyCancelled:
            Logger.error("APIError.cancelled")
            self = .cancelled
        case .sessionTaskFailed(error: let error):
            guard let urlError = error as? URLError, urlError.isConnectionError else {
                Logger.error("APIError.others")
                self = .others(error: afError)
                return
            }
            Logger.error("APIError.connectionError")
            self = .connectionError
        default:
            Logger.error("APIError.others")
            self = .others(error: afError)
        }
    }

    /// Decode another response
    private static func decode(errorResponseData: Data?) -> ErrorResponse? {
        guard let errorResponseData = errorResponseData else {
            Logger.error("ErrorResponseData is nil.")
            return nil
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let errorResponse = try decoder.decode(ErrorResponse.self, from: errorResponseData)
            return errorResponse
        } catch {
            Logger.error("ErrorResponse decode error:\(error)")
            return nil
        }
    }
}

private extension URLError {
    var isConnectionError: Bool {
        switch code {
        case .networkConnectionLost, .notConnectedToInternet, .timedOut:
            return true
        default:
            return false
        }
    }
}
