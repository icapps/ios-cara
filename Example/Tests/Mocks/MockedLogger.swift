//
//  MockedLogger.swift
//  Tests
//
//  Created by Jelle Vandebeeck on 30/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Cara

class MockedLogger: Logger {
    private(set) var didTriggerStartRequest: URLRequest?
    func start(urlRequest: URLRequest) {
        didTriggerStartRequest = urlRequest
    }
    
    private(set) var didTriggerEnd: Bool = false
    func end(urlRequest: URLRequest, urlResponse: URLResponse, metrics: URLSessionTaskMetrics, error: Error?) {
        didTriggerEnd = true
    }
}
