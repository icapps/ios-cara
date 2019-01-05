//
//  Configuration.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 01/12/2018.
//

/// A nicer way of defining the mapping between host and public keys.
public typealias PublicKeys = [String: String]

/// The configuration is used by the `Service` instance during the execution of the request.
public protocol Configuration {
    /// The base url that is appended to the `Request`'s relative url.
    var baseURL: URL? { get }
    /// Set the headers that will be used for all the requests.
    var headers: RequestHeaders? { get }
    /// Set the public keys for the hosts.
    var publicKeys: PublicKeys? { get }
    /// Set the loggers when you want to receive more information on the requests.
    var loggers: [Logger]? { get }
    /// Set the URLs we can use to detect network changes.
    var connectivityURLs: [URL]? { get }
}
