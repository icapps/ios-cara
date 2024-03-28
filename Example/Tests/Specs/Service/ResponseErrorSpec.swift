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
    // swiftlint:disable function_body_length
    override class func spec() {
        describe("ResponseError") {
            context("handling") {
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
                
                it("should be an service unavailable error") {
                    expect(ResponseError(statusCode: 503)) == ResponseError.serviceUnavailable
                }
                
                it("should be a server error") {
                    expect(ResponseError(statusCode: 501)) == .serverError(statusCode: 501)
                    expect(ResponseError(statusCode: 901)) == .serverError(statusCode: 901)
                }
            }
            
            context("description") {
                it("should show the correct invalid error description") {
                    expect(ResponseError.invalidURL.errorDescription) == "[1000] Invalid URL"
                }
                
                it("should show the correct 400 error description") {
                    expect(ResponseError.badRequest.errorDescription) == "[400] Bad Request"
                }
                
                it("should show the correct 401 error description") {
                    expect(ResponseError.unauthorized.errorDescription) == "[401] Unauthorized"
                }
                
                it("should show the correct 403 error description") {
                    expect(ResponseError.forbidden.errorDescription) == "[403] Forbidden"
                }
                
                it("should show the correct 404 error description") {
                    expect(ResponseError.notFound.errorDescription) == "[404] Not Found"
                }
                
                it("should show the correct 500 error description") {
                    expect(ResponseError.internalServerError.errorDescription) == "[500] Internal Server Error"
                }
                
                it("should show the correct 503 error description") {
                    expect(ResponseError.serviceUnavailable.errorDescription) == "[503] Service Unavailable"
                }
                
                it("should show the correct client error description") {
                    expect(ResponseError.clientError(statusCode: 406).errorDescription) == "[406] Client Error"
                }
                
                it("should show the correct 502 error description") {
                    expect(ResponseError.serverError(statusCode: 502).errorDescription) == "[502] Server Error"
                }
            }
        }
    }
    // swiftlint:enable function_body_length
}
