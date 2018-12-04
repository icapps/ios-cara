//
//  Request.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 01/12/2018.
//

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
    /// Set the type of body with it's content. In Cara's case we support 2 major types of body:
    /// - A raw `Data` object
    /// - An `Any` object that can be parsed as a json.
    var body: Any? { get }
}
