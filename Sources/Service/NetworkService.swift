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
        // Get the originating queue.
        let executionQueue: DispatchQueue? = OperationQueue.current?.underlyingQueue
        // Trigger the loggers before the request is done.
        configuration.start(urlRequest: urlRequest)
        // Prepare the session.
        let session = URLSession(configuration: URLSessionConfiguration.default,
                                 delegate: self,
                                 delegateQueue: nil)
        // Execute the task.
        let task = session.dataTask(with: urlRequest) { [weak self] data, urlResponse, error in
            let responseError: Error? = error ?? urlResponse?.httpError
            let response = serializer.serialize(data: data,
                                                error: responseError,
                                                response: urlResponse as? HTTPURLResponse)
            // Trigger the loggers when the request finished.
            self?.configuration.end(urlRequest: urlRequest, urlResponse: urlResponse, error: responseError)
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

extension NetworkService: URLSessionDataDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let host = challenge.protectionSpace.host
        guard
            let serverTrust = challenge.protectionSpace.serverTrust,
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        pinningService.handle(serverTrust, host: host, completionHandler: completionHandler)
    }
}
