//
//  Request+Execute.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//

import Foundation

extension URLRequest {
    func execute(completion: @escaping (_ response: Response) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: self) { _, urlResponse, error in
            // When the response errored.
            if urlResponse?.isError == true {
                completion(.failure(error ?? ResponseError.general))
                return
            }
            
            // Otherwise the request succeeds.
            completion(.success)
        }
        task.resume()
    }
}

extension URLResponse {
    var isError: Bool {
        guard
            let httpURLResponse = self as? HTTPURLResponse,
            httpURLResponse.statusCode >= 400 else { return false }
        return true
    }
}
