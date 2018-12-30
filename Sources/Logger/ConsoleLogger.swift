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
    
    public func end(urlRequest: URLRequest, urlResponse: URLResponse, metrics: URLSessionTaskMetrics, error: Error?) {
        guard
            let method = urlRequest.httpMethod,
            let httpResponse = urlResponse as? HTTPURLResponse,
            let url = urlRequest.url,
            let transactionMetric = metrics.transactionMetrics.first,
            let requestEndDate = transactionMetric.requestEndDate,
            let domainLookupStartDate = transactionMetric.domainLookupStartDate else { return }
        
        let totalDuration = requestEndDate.timeIntervalSince(domainLookupStartDate)
        if let error = error {
            os_log("⛈ %{public}@ %i: %{public}@ 💥 %{public}@ ⏳ %.3fms",
                   log: OSLog.request,
                   type: .info,
                   method,
                   httpResponse.statusCode,
                   url.absoluteString,
                   error.localizedDescription,
                   totalDuration)
        } else {
            os_log("☀️ %{public}@ %i: %{public}@ ⏳ %.3fms",
                   log: OSLog.request,
                   type: .info,
                   method,
                   httpResponse.statusCode,
                   url.absoluteString,
                   totalDuration)
        }
    }
}