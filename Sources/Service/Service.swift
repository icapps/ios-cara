//
//  Service.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 01/12/2018.
//

/// This it the main executor of requests.
open class Service {
    
    // MARK: - Internal
    
    private let configuration: Configuration
    private let networkService: NetworkService
    
    // MARK: - Init
    
    /// Initialize the Service layer.
    ///
    /// - parameter configuration: Configure the service layer through this instance.
    public init(configuration: Configuration) {
        self.configuration = configuration
        self.networkService = NetworkService(configuration: configuration,
                                             pinningService: PublicKeyPinningService(configuration: configuration))
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
        return execute(request, with: serializer, retryCount: 0, completion: completion)
    }

    /// This private function is used just to keep track of the retry count of the current request.
    private func execute<S: Serializer>(_ request: Request,
                                        with serializer: S,
                                        retryCount: UInt,
                                        completion: @escaping (_ response: S.Response) -> Void) -> URLSessionDataTask? {
        do {
            // Create the request.
            let urlRequest = try request.makeURLRequest(with: configuration)
            return networkService.execute(urlRequest,
                                          with: serializer,
                                          isInterceptable: request.isInterceptable,
                                          retryCount: retryCount,
                                          retry: { [weak self] in
                self?.execute(request, with: serializer, retryCount: retryCount + 1, completion: completion)
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
