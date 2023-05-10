//
//  Request.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 01/12/2018.
//

import Foundation

/// A nicer way of defining the request header format.
public typealias RequestHeaders = [String: String]
/// A nicer way of defining the query format.
public typealias RequestQuery = [String: String]

/// The request you want to execute.
public protocol Request {
    /// The url you want to send a request to. This url can be both a relative as a absolute url. In case of
    /// a relative url we prepend it with the base url defined in the configuration.
    var url: URL? { get }
    /// The HTTP method that should be used for this request.
    var method: RequestMethod { get }
    /// Set the url query for this request.
    var query: RequestQuery? { get }
    /// Set the headers for this request.
    var headers: RequestHeaders? { get }
    /// Set the type of body with it's content. In Cara's case we support 3 types of body:
    /// - A raw `Data` object
    /// - A type that implements `Encodable`
    /// - An `Any` object that can be serialized to json using `JSONSerialization`.
    var body: Any? { get }
    /// Set a cache policy for every request.
    var cachePolicy: URLRequest.CachePolicy { get }
    /// Set the network service type to prioritize the request.
    var networkServiceType: NSURLRequest.NetworkServiceType { get }
    /// Define if the request can be intercepted. Make sure this is set to false when you are for example
    /// refreshing the tokens. The refresh request should not be interceptable.
    var isInterceptable: Bool { get }
}
