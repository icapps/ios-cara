//
//  Request+URLRequest.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//

import Foundation

extension Request {
    func makeURLRequest(with configuration: Configuration) throws -> URLRequest {
        let url = try makeURL(with: configuration)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.httpMethod
        urlRequest.allHTTPHeaderFields = makeHeaders(with: configuration)
        return urlRequest
    }
    
    private func makeURL(with configuration: Configuration) throws -> URL {
        // A correct url should be set.
        guard let url = url else { throw ResponseError.invalidURL }
        // When the url is an absolure url, just use this url.
        guard url.host == nil else { return url }
        // Return the relative url appended to the base url.
        return configuration.baseURL.appendingPathComponent(url.absoluteString)
    }
    
    private func makeHeaders(with configuration: Configuration) -> RequestHeaders? {
        var requestHeaders: RequestHeaders?
        // When headers are available in the configuration we use them.
        if let headers = configuration.headers { requestHeaders = headers }
        // When headers are available in this request we use them.
        if let headers = headers {
            requestHeaders = requestHeaders ?? RequestHeaders()
            requestHeaders?.merge(dict: headers)
        }
        return requestHeaders
    }
}
