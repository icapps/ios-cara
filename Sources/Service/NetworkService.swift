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
    
    @discardableResult
    // swiftlint:disable function_parameter_count
    func execute<S: Serializer>(_ urlRequest: URLRequest,
                                with serializer: S,
                                isInterceptable: Bool,
                                retryCount: UInt,
                                executionQueue: DispatchQueue?,
                                retry: @escaping () -> Void,
                                completion: @escaping (_ response: S.Response) -> Void) -> URLSessionDataTask {
        // Trigger the loggers before the request is done.
        configuration.start(urlRequest: urlRequest)
        // Prepare the session.
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        // Execute the task.
        let task = session.dataTask(with: urlRequest) { [weak self] data, urlResponse, error in
            /// When the url response has a response error and an interceptor is set we check if the request flow
            /// should be stopped.
            if
                let responseError = urlResponse?.responseError,
                let interceptor = self?.interceptor,
                isInterceptable,
                interceptor.intercept(responseError, data: data, retryCount: retryCount, retry: retry) {
                return
            }
            
            let responseError: Error? = error ?? urlResponse?.responseError
            let response = serializer.serialize(data: data,
                                                error: responseError,
                                                response: urlResponse as? HTTPURLResponse)
            // Make sure the completion handler is triggered on the same queue as the `execute` was triggered on.
            self?.complete(on: executionQueue, block: { completion(response) })
        }
        task.resume()
        // This causes the delegate to be released correctly.
        session.finishTasksAndInvalidate()
        return task
    }

    // MARK: - Retry
    
    var interceptor: Interceptor?
    
    // MARK: - Helpers
    
    /// Perform the block on the given queue, when no queue is given we just execute the block.
    private func complete(on queue: DispatchQueue?, block: @escaping () -> Void) {
        guard let queue = queue else {
            block()
            return
        }
        queue.async(execute: block)
    }
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension NetworkService {
    
    func execute<S: Serializer>(_ urlRequest: URLRequest,
                                with serializer: S,
                                isInterceptable: Bool,
                                retryCount: UInt,
                                retry: @escaping () -> Void) async throws -> S.Response? {
        // Trigger the loggers before the request is done.
        configuration.start(urlRequest: urlRequest)
        // Prepare the session.
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        
        // Create the right variables.
        var data: Data?
        var urlResponse: URLResponse?
        var error: Error?
        
        // Execute the task.
        do {
            (data, urlResponse) = try await session.data(for: urlRequest)
        } catch let err {
            error = err
        }
        
        /// When the url response has a response error and an interceptor is set we check if the request flow
        /// should be stopped.
        if
            let responseError = urlResponse?.responseError,
            let interceptor = interceptor,
            isInterceptable, interceptor.intercept(responseError, data: data, retryCount: retryCount, retry: retry) {
            
            return nil
        }
        
        let responseError: Error? = error ?? urlResponse?.responseError
        return serializer.serialize(data: data,
                                    error: responseError,
                                    response: urlResponse as? HTTPURLResponse)
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
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        guard
            let urlRequest = task.currentRequest,
            let urlResponse = task.response else { return }
        
        // Trigger the loggers when the request finished.
        configuration.end(urlRequest: urlRequest,
                          urlResponse: urlResponse,
                          metrics: metrics,
                          error: task.error ?? urlResponse.responseError)
    }
}
