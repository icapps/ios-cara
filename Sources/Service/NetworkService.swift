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
                                completion: @escaping (_ response: S.Response) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { data, urlResponse, error in
            let response = serializer.serialize(data: data, error: error, response: urlResponse)
            completion(response)
        }
        task.resume()
    }
}
