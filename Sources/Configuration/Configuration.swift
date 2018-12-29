//
//  Configuration.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 01/12/2018.
//

/// The configuration is used by the `Service` instance during the execution of the request.
public protocol Configuration {
    /// The base url that is appended to the `Request`'s relative url.
    var baseURL: URL? { get }
    /// Set the headers that will be used for all the requests.
    var headers: RequestHeaders? { get }
}
