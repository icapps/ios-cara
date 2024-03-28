//
//  CaraQuickConfiguration.swift
//  Tests
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick
import Mockingjay

class CaraQuickConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Quick.QCKConfiguration) {
        configuration.beforeEach { _ in
            // Remove all the stubs.
            MockingjayProtocol.removeAllStubs()
            // Disable the caching in all the tests.
            URLCache.shared.removeAllCachedResponses()
        }
    }
}
