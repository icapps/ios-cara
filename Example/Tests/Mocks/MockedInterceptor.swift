//
//  MockedInterceptor.swift
//  Tests
//
//  Created by Jelle Vandebeeck on 02/03/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Cara

class MockedInterceptor: Interceptor {
    var interceptHandle: ((_ error: ResponseError, _ retry: @escaping () -> Void) -> Bool)?
    var didReceiveRetryCount: UInt?
    func intercept(_ error: ResponseError, data: Data?, retryCount: UInt, retry: @escaping () -> Void) -> Bool {
        didReceiveRetryCount = retryCount
        return interceptHandle?(error, retry) ?? false
    }
}
