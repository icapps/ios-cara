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
    func intercept(_ error: ResponseError, retry: @escaping () -> Void) -> Bool {
        return interceptHandle?(error, retry) ?? false
    }
}
