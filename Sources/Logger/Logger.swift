//
//  Logger.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 30/12/2018.
//

import Foundation

/// A class can conform to this protocol in order to get more information before and after a request.
public protocol Logger {
    /// Trigger before a request is fired.
    func start(urlRequest: URLRequest)
    /// Trigger after a request completed.
    func end(urlRequest: URLRequest, urlResponse: URLResponse?, error: Error?)
}
