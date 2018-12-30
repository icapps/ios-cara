//
//  NetworkService.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//

import Foundation

class NetworkService: NSObject {
    
    // MARK: - Internal
    
    private let configuration: Configuration
    private let pinningService: PublicKeyPinningService
    
    // MARK: - Init
    
    init(configuration: Configuration, pinningService: PublicKeyPinningService) {
        self.configuration = configuration
        self.pinningService = pinningService
    }
    
    // MARK: - Execute
    
    func execute<S: Serializer>(_ urlRequest: URLRequest,
                                with serializer: S,
                                completion: @escaping (_ response: S.Response) -> Void) -> URLSessionDataTask {
        let executionQueue: DispatchQueue? = OperationQueue.current?.underlyingQueue
        let session = URLSession(configuration: URLSessionConfiguration.default,
                                 delegate: self,
                                 delegateQueue: nil)
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
    
    // MARK: - Helpers
    
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

extension NetworkService: URLSessionDataDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let host = challenge.protectionSpace.host
        guard
            let serverTrust = challenge.protectionSpace.serverTrust,
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            print("🔑 Public key pinning failed due to invalid trust for host", host)
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        pinningService.handle(serverTrust, host: host, completionHandler: completionHandler)
    }
}
