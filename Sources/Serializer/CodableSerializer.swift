//
//  CodableSerializer.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//

import Foundation

/// You can use this serializer when you want to convert a data object returned from the server and parse
/// it to a `Codable` model.
///
/// How to use this:
/// ```swift
/// let serializer = CodableSerializer<User>()
/// ```
/// In the example above the `User` conforms to `Codable`.
public struct CodableSerializer<Model: Codable>: Serializer {
    
    // MARK: - Response
    
    /// The codable response returned by the `CodableSerializer`.
    public enum Response {
        /// When data is correctly parsed we return the `Codable` instance. This can also be nil when no
        /// data was returned.
        case success(Model?)
        /// Failure is triggered an error is returned or when parsing the data didn't succeed.
        case failure(Error)
    }
    
    // MARK: - Serialize
    
    public func serialize(data: Data?, error: Error?, response: URLResponse?) -> CodableSerializer<Model>.Response {
        // When an error occurs we return this error.
        if let error = error { return .failure(error) }
        
        // When a status code larger or equal than 400 is returned we return a custom error.
        if
            let response = response,
            response.httpStatusCode >= 400 {
            return .failure(ResponseError.httpError(statusCode: response.httpStatusCode))
        }
        
        /// When no data object (or an empty one) is returned from the server we have a successful.
        guard
            let data = data,
            !data.isEmpty else { return .success(nil) }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(Model.self, from: data)
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
}
