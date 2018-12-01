//
//  RequestSpec.swift
//  Tests
//
//  Created by Jelle Vandebeeck on 01/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick
import Nimble

@testable import Cara

class RequestSpec: QuickSpec {
    override func spec() {
        describe("Request") {
            it("should always succeed") {
                expect(Some()).toNot(beNil())
            }
        }
    }
}
