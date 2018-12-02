//
//  ServiceSpec.swift
//  Tests
//
//  Created by Jelle Vandebeeck on 01/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import Mockingjay

@testable import Cara

class ServiceSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("Service") {
            var service: Service!
            beforeEach {
                let configuration = MockedConfiguration(baseURL: URL(string: "https://relative.com/")!)
                service = Service(configuration: configuration)
            }
            
            context("request") {
                it("should execute an absolute request") {
                    self.stub(http(.get, uri: "https://absolute.com/request"), http(200))
                    
                    let request = MockedRequest(url: URL(string: "https://absolute.com/request"))
                    waitUntil { done in
                        service.execute(request, with: MockedSerializer()) { response in
                            expect(response.data).toNot(beNil())
                            expect(response.error).to(beNil())
                            expect(response.statusCode) == 200
                            done()
                        }
                    }
                }
                
                it("should execute a relative request") {
                    self.stub(http(.get, uri: "https://relative.com/request"), http(200))
                    
                    let request = MockedRequest(url: URL(string: "request"))
                    waitUntil { done in
                        service.execute(request, with: MockedSerializer()) { response in
                            expect(response.data).toNot(beNil())
                            expect(response.error).to(beNil())
                            expect(response.statusCode) == 200
                            done()
                        }
                    }
                }
            }
         
            context("serializer") {
                it("should fail to execute a request because of an invalid url") {
                    self.stub(http(.get, uri: "https://relative.com/"), http(200))
                    
                    let request = MockedRequest()
                    waitUntil { done in
                        service.execute(request, with: MockedSerializer()) { response in
                            expect(response.data).to(beNil())
                            expect(response.error as? ResponseError) == ResponseError.invalidURL
                            expect(response.statusCode).to(beNil())
                            done()
                        }
                    }
                }
                
                it("should pass the data to the serializer request") {
                    let body = ["key": "value"]
                    self.stub(http(.get, uri: "https://relative.com/request"), json(body))
                    
                    let request = MockedRequest(url: URL(string: "request"))
                    let serializer = MockedSerializer()
                    waitUntil { done in
                        service.execute(request, with: serializer) { response in
                            expect(response.data).toNot(beNil())
                            expect(response.error).to(beNil())
                            expect(response.statusCode) == 200
                            done()
                        }
                    }
                }
                
                it("should pass the error to the serializer request") {
                    let nsError = NSError(domain: "Cara", code: 1, userInfo: nil)
                    self.stub(http(.get, uri: "https://relative.com/request"), failure(nsError))
                    
                    let request = MockedRequest(url: URL(string: "request"))
                    let serializer = MockedSerializer()
                    waitUntil { done in
                        service.execute(request, with: serializer) { response in
                            expect(response.data).to(beNil())
                            expect(response.error as NSError?) == nsError
                            expect(response.statusCode).to(beNil())
                            done()
                        }
                    }
                }
            }
        }
    }
}
