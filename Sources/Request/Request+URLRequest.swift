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
        urlRequest.cachePolicy = cachePolicy
        return urlRequest
    }
    
    private func makeURL(with configuration: Configuration) throws -> URL {
        // A correct url should be set. And when this is the case we alreay try to append the query
        // to this url.
        guard
            let url = url,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw ResponseError.invalidURL
        }
        
        var requestURL: URL
        if components.host != nil {
            // When the url is an absolure url, just use this url.
            requestURL = url
        } else if let baseURL = configuration.baseURL {
            // When the url is a relative url we should have a base url defined.
            let newURL = baseURL.appendingPathComponent(components.path)
            requestURL = newURL
        } else {
            throw ResponseError.invalidURL
        }
        
        // Append the original query paramters to the new request url.
        var requestComponents = URLComponents(url: requestURL, resolvingAgainstBaseURL: false)
        requestComponents?.queryItems = components.queryItems
        guard let correctURL = requestComponents?.url else { throw ResponseError.invalidURL }
        
        // Return the relative url appended to the base url.
        return correctURL.appendingQuery(from: self)
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
        guard
            let query = request.query,
            var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        
        let queryItems: [URLQueryItem] = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        // When the initial url doesn't contain query items we set the request's items. Otherwise we append the
        // items to the existing ones.
        if urlComponents.queryItems == nil {
            urlComponents.queryItems = queryItems
        } else {
            urlComponents.queryItems?.append(contentsOf: queryItems)
        }
        return urlComponents.url ?? self
    }
}
