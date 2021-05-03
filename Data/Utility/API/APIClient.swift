//
//  APIClient.swift
//  Data
//
//  Created by okudera on 2021/05/03.
//

import Alamofire
import Foundation

final class APIClient {

    private init() {}
    static let shared = APIClient()

    static func defaultDataDecoder() -> DataDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let decoder: DataDecoder = jsonDecoder
        return decoder
    }

    /// API Request
    func request<T: APIRequestable>(_ request: T,
                                    queue: DispatchQueue = .main,
                                    decoder: DataDecoder = defaultDataDecoder(),
                                    completion: @escaping(Result<T.Response, APIError<T.ErrorResponse>>) -> Void) {

        AF.request(request.makeURLRequest())
            .validate(statusCode: 200..<300)
            .responseDecodable(of: T.Response.self, queue: queue, decoder: decoder) { dataResponse in
                Logger.debug("API Response Description\n\(dataResponse.debugDescription)")

                switch dataResponse.result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let afError):
                    let apiError = APIError<T.ErrorResponse>(afError: afError, responseData: dataResponse.data)
                    completion(.failure(apiError))
                }
            }
    }
}
