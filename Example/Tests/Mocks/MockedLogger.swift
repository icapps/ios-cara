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
    private(set) var didTriggerStart: Bool = false
    func start(urlRequest: URLRequest) {
        didTriggerStart = true
    }
    
    private(set) var didTriggerEnd: Bool = false
    func end(urlRequest: URLRequest, urlResponse: URLResponse, metrics: URLSessionTaskMetrics, error: Error?) {
        didTriggerEnd = true
    }
}
