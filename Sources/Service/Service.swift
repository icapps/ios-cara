//
//  Service.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 01/12/2018.
//

import Foundation

/// This it the main executor of requests.
open class Service {
    
    // MARK: - Internal

    private let networkService: NetworkService
    private let requestBuilder: RequestBuilderProtocol
    
    // MARK: - Init
    
    /// Initialize the Service layer.
    ///
    /// - parameter configuration: Configure the service layer through this instance.
    public convenience init(configuration: Configuration) {
        self.init(configuration: configuration,
                  requestBuilder: RequestBuilder(configuration: configuration))
    }

    /// Initialize the Service layer.
    ///
    /// - parameter configuration: Configure the service layer through this instance.
    /// - parameter requestBuilder: The class responsible for creating the request
    public init(configuration: Configuration,
                requestBuilder: RequestBuilderProtocol) {
        self.networkService = NetworkService(configuration: configuration,
                                             pinningService: PublicKeyPinningService(configuration: configuration))
        self.requestBuilder = requestBuilder
    }
    
    // MARK: - Execute
    
    /// Execute the given request and get an appropriate response returned.
    ///
    /// ```swift
    /// let request = SomeRequest()
    /// let serializer = SomeSerializer()
    /// service.execute(request, with: serializer) { response in
    ///    ...
    /// }
    /// ```
    ///
    /// - parameter request: The request to execute.
    /// - parameter serializer: The result of the request will go through serialization.
    /// - paremeter completion: The block that is triggered on completion.
    ///
    /// - returns: The executed data task.
    @discardableResult
    public func execute<S: Serializer>(_ request: Request,
                                       with serializer: S,
                                       completion: @escaping (_ response: S.Response) -> Void) -> URLSessionDataTask? {
        // Get the originating queue.
        let executionQueue: DispatchQueue? = OperationQueue.current?.underlyingQueue
        return execute(request, with: serializer, retryCount: 0, executionQueue: executionQueue, completion: completion)
    }

    /// This private function is used just to keep track of the retry count of the current request.
    @discardableResult
    private func execute<S: Serializer>(_ request: Request,
                                        with serializer: S,
                                        retryCount: UInt,
                                        executionQueue: DispatchQueue?,
                                        completion: @escaping (_ response: S.Response) -> Void) -> URLSessionDataTask? {
        do {
            // Create the request.
            let urlRequest = try requestBuilder.makeURLRequest(from: request)
            return networkService.execute(urlRequest,
                                          with: serializer,
                                          isInterceptable: request.isInterceptable,
                                          retryCount: retryCount,
                                          executionQueue: executionQueue,
                                          retry: { [weak self] in
                self?.execute(request,
                              with: serializer,
                              retryCount: retryCount + 1,
                              executionQueue: executionQueue,
                              completion: completion)
            }, completion: completion)
        } catch {
            let response = serializer.serialize(data: nil, error: error, response: nil)
            completion(response)
            return nil
        }
    }
    
    // MARK: - Interceptor
    
    /// Define the interceptor. This can be usefull when you want to handle some status code
    /// differently.
    /// ex. refresh, maintenance mode, ...
    public var interceptor: Interceptor? {
        set { networkService.interceptor = newValue }
        get { return networkService.interceptor }
    }
}
