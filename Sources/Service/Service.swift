//
//  Service.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 01/12/2018.
//

/// This it the main executor of requests.
public class Service {
    
    // MARK: - Internal
    
    private let configuration: Configuration
    
    // MARK: - Init
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    // MARK: - Execute
    
    /// Execute the given request and get an appropriate response returned.
    ///
    /// ```swift
    /// let request = SomeRequest()
    /// service.execute(request) { response in
    ///    ...
    /// }
    /// ```
    ///
    /// - parameter request: The request to execute.
    /// - paremeter completion: The block that is triggered on completion.
    public func execute(_ request: Request, completion: @escaping (_ response: Response) -> Void) {
        do {
            try request.makeURLRequest(with: configuration)
                       .execute(completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
}
