//
//  ResponseError.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//

import Foundation

/// The error thrown by the service request.
enum ResponseError: Error {
    /// The request's url was invalid.
    case invalidURL
}
