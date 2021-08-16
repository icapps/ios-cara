//
//  Configuration.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 01/12/2018.
//

import Foundation

/// A nicer way of defining the mapping between host and public keys.
public typealias PublicKeys = [String: String]

/// The configuration is used by the `Service` instance during the execution of the request.
public protocol Configuration {
    /// The base url that is appended to the `Request`'s relative url.
    var baseURL: URL? { get }
    /// Set the public keys for the hosts.
    var publicKeys: PublicKeys? { get }
    /// Set the loggers when you want to receive more information on the requests.
    var loggers: [Logger]? { get }
    /// Set the headers that will be used for all the requests. The current request is passed
    /// so that some additional logic can be applied before returning the headers.
    ///
    /// - parameters request: The current request.
    ///
    /// - return: The request headers.
    func headers(for request: Request) -> RequestHeaders?
    /// Alter the session configuration before triggering the request.
    ///
    /// - parameters configuration: The session configiguration used by the `URLSession`.
    func alter(configuration: URLSessionConfiguration)
}

public extension Configuration {
    func alter(configuration: URLSessionConfiguration) {
        // Default implementation does nothing.
    }
}
