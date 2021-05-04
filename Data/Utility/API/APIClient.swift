//
//  APIClient.swift
//  Data
//
//  Created by okudera on 2021/05/03.
//

import Alamofire
import Foundation

final class APIClient {

    private var dataRequests = [DataRequest]()

    private init() {}
    static let shared = APIClient()

    static func defaultDataDecoder() -> DataDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let decoder: DataDecoder = jsonDecoder
        return decoder
    }

    func cancelRequest(_ dataRequest: DataRequest) {
        dataRequest.cancel()
        removeCancelledDataRequests()
    }

    func cancelAllRequests() {
        Session.default.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
    }

    /// API Request
    @discardableResult
    func request<T: APIRequestable>(_ request: T,
                                    queue: DispatchQueue = .main,
                                    decoder: DataDecoder = defaultDataDecoder(),
                                    completion: @escaping(Result<T.Response, APIError<T.ErrorResponse>>) -> Void) -> DataRequest {

        let dataRequest = AF.request(request.makeURLRequest())
            .validate(statusCode: 200..<300)
            .responseDecodable(of: T.Response.self, queue: queue, decoder: decoder) { [weak self] dataResponse in
                Logger.verbose(dataResponse.debugDescription)

                self?.removeFinishedDataRequests()
                self?.removeCancelledDataRequests()

                switch dataResponse.result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let afError):
                    let apiError = APIError<T.ErrorResponse>(afError: afError, responseData: dataResponse.data)
                    completion(.failure(apiError))
                }
            }
        dataRequests.append(dataRequest)
        return dataRequest
    }

    private func removeFinishedDataRequests() {
        dataRequests.removeAll(where: { $0.isFinished })
    }

    private func removeCancelledDataRequests() {
        dataRequests.removeAll(where: { $0.isCancelled })
    }
}
