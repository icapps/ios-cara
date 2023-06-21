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
}
