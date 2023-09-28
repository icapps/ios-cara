//
//  Request+URLRequest.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//

import Foundation

public protocol RequestBuilderProtocol {
    func makeURLRequest(from request: Request) throws -> URLRequest
}

open class RequestBuilder: RequestBuilderProtocol {

    let configuration: Configuration

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    open func makeURLRequest(from request: Request) throws -> URLRequest {
        let url = try makeURL(from: request)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.httpMethod
        urlRequest.allHTTPHeaderFields = makeHeaders(from: request)
        urlRequest.httpBody = try makeBody(from: request)
        urlRequest.cachePolicy = request.cachePolicy
        urlRequest.networkServiceType = request.networkServiceType
        return urlRequest
    }
}

private extension RequestBuilder {
    
    func makeURL(from request: Request) throws -> URL {
        // A correct url should be set. And when this is the case we alreay try to append the query
        // to this url.
        guard
            let url = request.url,
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
        return correctURL
            .appendingQuery(request.query)
    }
    
    func makeHeaders(from request: Request) -> RequestHeaders? {
        var requestHeaders: RequestHeaders?
        // When headers are available in the configuration we use them.
        if let headers = configuration.headers(for: request) {
            requestHeaders = headers
        }
        // When headers are available in this request we use them.
        if let headers = request.headers {
            requestHeaders = requestHeaders ?? RequestHeaders()
            requestHeaders?.merge(dict: headers)
        }
        return requestHeaders
    }
    
    func makeBody(from request: Request) throws -> Data? {
        guard let body  = request.body else { return nil }
        // When the body is of the data type we just return this raw data.
        if let body = body as? Data { return body }
        // In all other cases we try to parse the json.
        return try JSONSerialization.data(withJSONObject: body, options: [])
    }
}

extension URL {
    func appendingQuery(_ requestQuery: RequestQuery?) -> URL {
        guard let query = requestQuery else { return self }
        if #available(iOS 16, *) {
            return appending(queryItems: query.queryItems)
        } else {
            return appendingQueryItems(query.queryItems)
        }
    }

    // Pre-iOS16 fallback for appending query items to a URL
    func appendingQueryItems(_ queryItems: [URLQueryItem]) -> URL {
        guard
            var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
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

extension RequestQuery {

    var queryItems: [URLQueryItem] {
        return self.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
