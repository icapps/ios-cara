//
//  Logger.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 30/12/2018.
//

import os

/// The `Console` logger logs some minimal request information to the console.
public class ConsoleLogger {
    public init() {
    }
}

extension ConsoleLogger: Logger {
    public func start(urlRequest: URLRequest) {
        guard
            let method = urlRequest.httpMethod,
            let url = urlRequest.url else { return }
        os_log("☁️ %{public}@: %{public}@", log: OSLog.request, type: .info, method, url.absoluteString)
    }
    
    public func end(urlRequest: URLRequest, urlResponse: URLResponse?, error: Error?) {
        guard
            let method = urlRequest.httpMethod,
            let httpResponse = urlResponse as? HTTPURLResponse,
            let url = urlRequest.url else { return }
        
        if let error = error {
            os_log("⛈ %{public}@ %i: %{public}@\nError: %{public}@",
                   log: OSLog.request,
                   type: .info,
                   method,
                   httpResponse.statusCode,
                   url.absoluteString,
                   error.localizedDescription)
        } else {
            os_log("☀️ %{public}@ %i: %{public}@",
                   log: OSLog.request,
                   type: .info,
                   method,
                   httpResponse.statusCode,
                   url.absoluteString)
        }
    }
}
