//
//  ResponseErrorSpec.swift
//  Tests
//
//  Created by Jelle Vandebeeck on 30/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick
import Nimble

@testable import Cara

class ResponseErrorSpec: QuickSpec {
    override func spec() {
        describe("ResponseError") {
            it("should not be an error") {
                expect(ResponseError(statusCode: 0)).to(beNil())
                expect(ResponseError(statusCode: 399)).to(beNil())
            }
                
            it("should be a bad request") {
                expect(ResponseError(statusCode: 400)) == .badRequest
            }
            
            it("should be unauthorized") {
                expect(ResponseError(statusCode: 401)) == .unauthorized
            }
            
            it("should be forbidden") {
                expect(ResponseError(statusCode: 403)) == .forbidden
            }
            
            it("should be not found") {
                expect(ResponseError(statusCode: 404)) == .notFound
            }
            
            it("should be a client error") {
                expect(ResponseError(statusCode: 405)) == .clientError(statusCode: 405)
                expect(ResponseError(statusCode: 499)) == .clientError(statusCode: 499)
            }
            
            it("should be an internal server error") {
                expect(ResponseError(statusCode: 500)) == ResponseError.internalServerError
            }
            
            it("should be a server error") {
                expect(ResponseError(statusCode: 501)) == .serverError(statusCode: 501)
                expect(ResponseError(statusCode: 901)) == .serverError(statusCode: 901)
            }
        }
    }
}
