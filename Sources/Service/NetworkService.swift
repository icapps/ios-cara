//
//  NetworkService.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//

import Foundation

class NetworkService {
    
    // MARK: - Internal
    
    private let configuration: Configuration
    
    // MARK: - Init
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    // MARK: - Execute
    
    func execute<S: Serializer>(_ urlRequest: URLRequest,
                                with serializer: S,
                                completion: @escaping (_ response: S.Response) -> Void) -> URLSessionDataTask {
        let executionQueue: DispatchQueue? = OperationQueue.current?.underlyingQueue
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { [weak self] data, urlResponse, error in
            let response = serializer.serialize(data: data,
                                                error: error ?? urlResponse?.httpError,
                                                response: urlResponse as? HTTPURLResponse)
            // Make sure the completion handler is triggered on the same queue as the `execute` was triggered on.
            self?.complete(on: executionQueue, block: { completion(response) })
        }
        task.resume()
        return task
    }
    
    private func complete(on queue: DispatchQueue?, block: @escaping () -> Void) {
        guard let queue = queue else {
            block()
            return
        }
        queue.async(execute: block)
    }
}

extension URLResponse {
    var httpError: Error? {
        guard let response = self as? HTTPURLResponse else { return nil }
        return ResponseError(statusCode: response.statusCode)
    }
}
