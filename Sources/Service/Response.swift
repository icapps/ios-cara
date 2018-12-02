//
//  Response.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//

import Foundation

/// The response from the request call.
public enum Response {
    /// The service request call is successful.
    case success
    /// The service request call failed with the given error.
    case failure(Error)
}
