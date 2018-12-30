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
        urlRequest.httpBody = try makeBody()
        return urlRequest
    }
    
    private func makeURL(with configuration: Configuration) throws -> URL {
        // A correct url should be set. And when this is the case we alreay try to append the query
        // to this url.
        guard let url = url else { throw ResponseError.invalidURL }
        // When the url is an absolure url, just use this url.
        guard url.host == nil else { return url.appendingQuery(from: self) }
        // When the url is a relative url we should have a base url defined.
        guard let baseURL = configuration.baseURL else { throw ResponseError.invalidURL }
        // Return the relative url appended to the base url.
        return baseURL.appendingPathComponent(url.absoluteString).appendingQuery(from: self)
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
    
    private func makeBody() throws -> Data? {
        guard let body  = body else { return nil }
        // When the body is of the data type we just return this raw data.
        if let body = body as? Data { return body }
        // In all other cases we try to parse the json.
        return try JSONSerialization.data(withJSONObject: body, options: [])
    }
}

fileprivate extension URL {
    func appendingQuery(from request: Request) -> URL {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        urlComponents.queryItems = request.query?.map { URLQueryItem(name: $0.key, value: $0.value) }
        return urlComponents.url ?? self
    }
}
