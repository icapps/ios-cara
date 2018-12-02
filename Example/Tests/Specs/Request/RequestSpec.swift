//
//  RequestSpec.swift
//  Tests
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick
import Nimble

@testable import Cara

class RequestSpec: QuickSpec {
    override func spec() {
        var configuration: MockedConfiguration!
        beforeEach {
            configuration = MockedConfiguration(baseURL: URL(string: "https://relative.com")!)
        }
        
        context("url") {
            it("should have a absolute url") {
                let request = MockedRequest(url: URL(string: "https://absolute.com/request"))
                let urlRequest = try? request.makeURLRequest(with: configuration)
                expect(urlRequest?.url) == URL(string: "https://absolute.com/request")
            }
            
            it("should have a relative url") {
                let request = MockedRequest(url: URL(string: "request"))
                let urlRequest = try? request.makeURLRequest(with: configuration)
                expect(urlRequest?.url) == URL(string: "https://relative.com/request")
            }
            
            it("should throw an invalid url error") {
                let request = MockedRequest(url: nil)
                expect {
                    _ = try request.makeURLRequest(with: configuration)
                }.to(throwError(ResponseError.invalidURL))
            }
        }
    }
}
