//
//  Logger.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 30/12/2018.
//

import Foundation

/// A class can conform to this protocol in order to get more information before and after a request.
public protocol Logger {
    /// The `start` function is triggered just before a request if fired.
    ///
    /// - parameters urlRequest: The request that is will be executed.
    func start(urlRequest: URLRequest)
    /// The `end` function is triggered just after the request finised collecting the metrics.
    ///
    /// - parameters urlRequest: The request that is was executed after redirection.
    /// - parameters urlResponse: The response of the request.
    /// - parameters metrics: The metrics for the request.
    /// - parameters error: The error is an error occured.
    @available(iOS 10.0, *)
    func end(urlRequest: URLRequest, urlResponse: URLResponse, metrics: URLSessionTaskMetrics, error: Error?)
}
