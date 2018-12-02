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
    // swiftlint:disable function_body_length
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
        
        context("method") {
            it("should have the correct GET method") {
                let request = MockedRequest(url: URL(string: "request"), method: .get)
                let urlRequest = try? request.makeURLRequest(with: configuration)
                expect(urlRequest?.httpMethod) == "GET"
            }
            
            it("should have the correct HEAD method") {
                let request = MockedRequest(url: URL(string: "request"), method: .head)
                let urlRequest = try? request.makeURLRequest(with: configuration)
                expect(urlRequest?.httpMethod) == "HEAD"
            }
            
            it("should have the correct POST method") {
                let request = MockedRequest(url: URL(string: "request"), method: .post)
                let urlRequest = try? request.makeURLRequest(with: configuration)
                expect(urlRequest?.httpMethod) == "POST"
            }
            
            it("should have the correct PATCH method") {
                let request = MockedRequest(url: URL(string: "request"), method: .patch)
                let urlRequest = try? request.makeURLRequest(with: configuration)
                expect(urlRequest?.httpMethod) == "PATCH"
            }
            
            it("should have the correct PUT method") {
                let request = MockedRequest(url: URL(string: "request"), method: .put)
                let urlRequest = try? request.makeURLRequest(with: configuration)
                expect(urlRequest?.httpMethod) == "PUT"
            }
            
            it("should have the correct DELETE method") {
                let request = MockedRequest(url: URL(string: "request"), method: .delete)
                let urlRequest = try? request.makeURLRequest(with: configuration)
                expect(urlRequest?.httpMethod) == "DELETE"
            }
        }
    }
}
