//
//  Request.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 01/12/2018.
//

/// A nicer way of defining the request header format.
public typealias RequestHeaders = [String: String]

/// The request you want to execute.
public protocol Request {
    /// The url you want to send a request to. This url can be both a relative as a absolute url. In case of
    /// a relative url we prepend it with the base url defined in the configuration.
    var url: URL? { get }
    /// The HTTP method that should be used for this request.
    var method: RequestMethod { get }
    /// Set the headers for this request.
    var headers: RequestHeaders? { get }
}
