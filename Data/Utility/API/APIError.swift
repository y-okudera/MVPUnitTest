//
//  APIError.swift
//  Data
//
//  Created by okudera on 2021/05/03.
//

import Alamofire
import Common
import Foundation

public enum APIError<ErrorResponse: Decodable & Equatable>: Error, Equatable {
    case cancelled
    case connectionError
    case errorResponse(ErrorResponse, statusCode: Int)
    case others(error: Error)

    public static func == (lhs: APIError<ErrorResponse>, rhs: APIError<ErrorResponse>) -> Bool {
        switch (lhs, rhs) {
        case (.cancelled, .cancelled):
            return true
        case (.connectionError, .connectionError):
            return true
        case (.errorResponse(let lErrorResponse, statusCode: let lStatusCode), .errorResponse(let rERrorResponse, statusCode: let rStatusCode)):
            return lErrorResponse == rERrorResponse && lStatusCode == rStatusCode
        case (.others(error: let lError as NSError), .others(error: let rError as NSError)):
            return lError.domain == rError.domain && lError.code == rError.code
        default:
            return false
        }
    }
}

extension APIError {
    init(afError: AFError, responseData: Data?, statusCode: Int?) {
        switch afError {
        case .responseValidationFailed(reason: let reason):
            guard case .unacceptableStatusCode(code: let code) = reason, let errorResponse = Self.decode(errorResponseData: responseData) else {
                Logger.error("APIError.others")
                self = .others(error: afError)
                return
            }
            Logger.error("APIError.errorResponse")
            self = .errorResponse(errorResponse, statusCode: code)

        case .responseSerializationFailed:
            guard let errorResponse = Self.decode(errorResponseData: responseData) else {
                Logger.error("APIError.others")
                self = .others(error: afError)
                return
            }
            Logger.error("APIError.errorResponse")
            self = .errorResponse(errorResponse, statusCode: statusCode ?? 0)

        case .explicitlyCancelled:
            Logger.error("APIError.cancelled")
            self = .cancelled

        case .sessionTaskFailed(error: let error):
            if let urlError = error as? URLError {
                guard !urlError.isConnectionError else {
                    Logger.error("APIError.connectionError")
                    self = .connectionError
                    return
                }
                guard !urlError.isCancelledError else {
                    Logger.error("APIError.cancelled")
                    self = .cancelled
                    return
                }
            }
            Logger.error("APIError.others")
            self = .others(error: afError)

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

    var isCancelledError: Bool {
        switch code {
        case .cancelled:
            return true
        default:
            return false
        }
    }
}
