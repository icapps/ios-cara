//
//  File.swift
//  Pods
//
//  Created by Jelle Vandebeeck on 02/03/2019.
//

import Foundation

/// conform to this protocol if you want to assign an interceptor to the service layer. An
/// interceptor will 'intercept' the request when an error occurs.
public protocol Interceptor {
    /// This function is triggered when a response error is triggered.
    ///
    /// - parameter error: The error that triggers the interceptor.
    /// - parameter data: The body's data object if available.
    /// - parameter retry: The block you should trigger to retry the failed request.
    ///
    /// - returns: Return if you want the response processing to be intercepted so that
    /// the normal flow (with completion handler) is stopped.
    func intercept(_ error: ResponseError, data: Data?, retry: @escaping () -> Void) -> Bool
}
