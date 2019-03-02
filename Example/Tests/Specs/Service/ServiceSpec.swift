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
            var configuration: MockedConfiguration!
            beforeEach {
                configuration = MockedConfiguration(baseURL: URL(string: "https://relative.com/")!)
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
            
            context("task") {
                it("should return a task when request is triggered") {
                    self.stub(http(.get, uri: "https://relative.com/request"), http(200))
                    
                    let request = MockedRequest(url: URL(string: "request"))
                    var task: URLSessionDataTask?
                    waitUntil { done in
                        task = service.execute(request, with: MockedSerializer()) { _ in
                            done()
                        }
                    }
                    expect(task).toNot(beNil())
                }
                
                it("should not return a task when request fail to trigger") {
                    let request = MockedRequest(url: nil)
                    var task: URLSessionDataTask?
                    waitUntil { done in
                        task = service.execute(request, with: MockedSerializer()) { _ in
                            done()
                        }
                    }
                    expect(task).to(beNil())
                }
            }
            
            context("retry") {
                var logger: MockedLogger!
                beforeEach {
                    logger = MockedLogger()
                    configuration.loggers = [logger]
                }
                
                it("should not retry a request") {
                    self.stub(http(.get, uri: "https://relative.com/request"), http(401))
                    let request = MockedRequest(url: URL(string: "request"))
                    let serializer = MockedSerializer()
                    
                    configuration.retryHandle = { error, retry in
                        configuration.headers = ["Some": "Header"]
                        self.stub(http(.get, uri: "https://relative.com/request"), http(200))
                        return false
                    }
                    
                    waitUntil { done in
                        service.execute(request, with: serializer) { _ in
                            expect(logger.didTriggerStartRequest?.allHTTPHeaderFields?["Some"]).to(beNil())
                            done()
                        }
                    }
                }
                
                it("should retry a request with the new headers") {
                    self.stub(http(.get, uri: "https://relative.com/request"), http(401))
                    let request = MockedRequest(url: URL(string: "request"))
                    
                    configuration.retryHandle = { error, retry in
                        configuration.headers = ["Some": "Header"]
                        self.stub(http(.get, uri: "https://relative.com/request"), http(200))
                        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1, execute: retry)
                        return true
                    }
                    
                    waitUntil { done in
                        service.execute(request, with: MockedSerializer()) { _ in
                            expect(logger.didTriggerStartRequest?.allHTTPHeaderFields?["Some"]) == "Header"
                            done()
                        }
                    }
                }
            }
         
            context("serializer") {
                it("should fail to execute a request because of an invalid url") {
                    self.stub(http(.get, uri: "https://relative.com/"), http(200))
                    
                    let request = MockedRequest(url: nil)
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
                
                it("should return a http error") {
                    self.stub(http(.get, uri: "https://relative.com/request"), http(400))
                    
                    let request = MockedRequest(url: URL(string: "request"))
                    let serializer = MockedSerializer()
                    waitUntil { done in
                        service.execute(request, with: serializer) { response in
                            expect(response.data).toNot(beNil())
                            expect(response.error as? ResponseError) == ResponseError.badRequest
                            expect(response.statusCode) == 400
                            done()
                        }
                    }
                }
            }
        }
    }
}
