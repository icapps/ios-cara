//
//  Configuration.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 01/12/2018.
//

/// The serializer is responsible for generating the response that is returned by the service request.
public protocol Serializer {
    /// The response returned by the `execute`'s `completion` handler.
    associatedtype Response
    
    /// This function is called when the request finished and needs to be handled. Depending on the data,
    /// the error or the url response passed, a response is generated.
    ///
    /// - parameter data: The body'sdata returned by the response.
    /// - parameter error: The error given by the request.
    /// - parameter response: The url response for more customization.
    ///
    /// - returns: A generic response defined by the implementation class.
    func serialize(data: Data?, error: Error?, response: URLResponse?) -> Response
}
