//
//  Logger.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 30/12/2018.
//

import os
import Foundation

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
}
