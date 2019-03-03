//
//  ResponseError.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//

import Foundation

/// The error thrown by the service request.
public enum ResponseError: Error {
    // MARK: - Custom errors
    
    case invalidURL
    
    // MARK: - HTTP client errors
    
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case clientError(statusCode: Int)
    
    // MARK: - HTTP server errors
    
    case internalServerError
    case serviceUnavailable
    case serverError(statusCode: Int)
    
    // MARK: - Init
    
    init?(statusCode: Int) {
        switch statusCode {
        // This is not an error.
        case 0...399: return nil
        case 400: self = .badRequest
        case 401: self = .unauthorized
        case 403: self = .forbidden
        case 404: self = .notFound
        case 500: self = .internalServerError
        case 503: self = .serviceUnavailable
        case 405...499: self = .clientError(statusCode: statusCode)
        default: self = .serverError(statusCode: statusCode)
        }
    }
}

extension ResponseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "[1000] Invalid URL"
        case .badRequest: return "[400] Bad Request"
        case .unauthorized: return "[401] Unauthorized"
        case .forbidden: return "[403] Forbidden"
        case .notFound: return "[404] Not Found"
        case .clientError(let statusCode): return "[\(statusCode)] Client Error"
        case .internalServerError: return "[500] Internal Server Error"
        case .serviceUnavailable: return "[503] Service Unavailable"
        case .serverError(let statusCode): return "[\(statusCode)] Server Error"
        }
    }
}

extension ResponseError: Equatable {
    public static func == (lhs: ResponseError, rhs: ResponseError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, invalidURL): return true
        case (.badRequest, badRequest): return true
        case (.unauthorized, unauthorized): return true
        case (.forbidden, forbidden): return true
        case (.notFound, notFound): return true
        case (.clientError(let lhsStatusCode), clientError(let rhsStatusCode)): return lhsStatusCode == rhsStatusCode
        case (.internalServerError, internalServerError): return true
        case (.serviceUnavailable, serviceUnavailable): return true
        case (.serverError(let lhsStatusCode), serverError(let rhsStatusCode)): return lhsStatusCode == rhsStatusCode
        default: return false
        }
    }
}
