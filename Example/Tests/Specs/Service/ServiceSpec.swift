//
//  ServiceSpec.swift
//  Tests
//
//  Created by Jelle Vandebeeck on 01/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick
import Nimble

@testable import Cara

class ServiceSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override class func spec() {
        describe("Service") {
            var service: Service!
            var configuration: MockedConfiguration!
            var stubbedRequest: StubbedRequest!
            beforeEach {
                configuration = MockedConfiguration(baseURL: URL(string: "https://relative.com/")!)
                service = Service(configuration: configuration)
                stubbedRequest = StubbedRequest()
            }
            
            afterEach {
                stubbedRequest.stopStubbedRequest()
            }

            context("request") {
                it("should execute an absolute request") {
                    stubbedRequest.request(url: "https://absolute.com/request", statuscode: 200)
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
                    stubbedRequest.request(url: "https://relative.com/request", statuscode: 200)
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
                    stubbedRequest.request(url: "https://relative.com/request", statuscode: 200)

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
                    stubbedRequest.request(url: "https://relative.com/request", statuscode: 401)
                    let request = MockedRequest(url: URL(string: "request"))
                    let serializer = MockedSerializer()
                    
                    let interceptor = MockedInterceptor()
                    interceptor.interceptHandle = { _, _ in
                        configuration.mockedHeaders = ["Some": "Header"]
                        stubbedRequest.request(url: "https://relative.com/request", statuscode: 200)
                        return false
                    }
                    service.interceptor = interceptor
                    
                    waitUntil { done in
                        service.execute(request, with: serializer) { _ in
                            expect(logger.didTriggerStartRequest?.allHTTPHeaderFields?["Some"]).to(beNil())
                            done()
                        }
                    }
                    expect(interceptor.didReceiveRetryCount) == 0
                }
                
                it("should retry a request with the new headers") {
                    stubbedRequest.request(url: "https://relative.com/request", statuscode: 401)
                    let request = MockedRequest(url: URL(string: "request"))
                    
                    let interceptor = MockedInterceptor()
                    interceptor.interceptHandle = { _, retry in
                        configuration.mockedHeaders = ["Some": "Header"]
                        stubbedRequest.request(url: "https://relative.com/request", statuscode: 200)
                        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1, execute: retry)
                        return true
                    }
                    service.interceptor = interceptor
                    
                    waitUntil { done in
                        service.execute(request, with: MockedSerializer()) { _ in
                            expect(logger.didTriggerStartRequest?.allHTTPHeaderFields?["Some"]) == "Header"
                            done()
                        }
                    }
                    expect(interceptor.didReceiveRetryCount) == 0
                }

                it("should retry a request with the new headers and have a retry count of one") {
                    stubbedRequest.request(url: "https://relative.com/request", statuscode: 401)
                    let request = MockedRequest(url: URL(string: "request"))

                    let interceptor = MockedInterceptor()
                    var count: Int = 0
                    interceptor.interceptHandle = { _, retry in
                        count += 1
                        configuration.mockedHeaders = ["Some": "Header"]
                        if count > 1 {
                            // Make sure the second try also fails.
                            stubbedRequest.request(url: "https://relative.com/request", statuscode: 200)
                        }
                        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1, execute: retry)
                        return true
                    }
                    service.interceptor = interceptor

                    waitUntil { done in
                        service.execute(request, with: MockedSerializer()) { _ in
                            expect(logger.didTriggerStartRequest?.allHTTPHeaderFields?["Some"]) == "Header"
                            done()
                        }
                    }
                    expect(interceptor.didReceiveRetryCount) == 1
                }
            }
         
            context("threading") {
                it("should return on the main queue") {
                    stubbedRequest.request(url: "https://relative.com/request", statuscode: 200)
                    let request = MockedRequest(url: URL(string: "request"))

                    waitUntil { done in
                        DispatchQueue.main.async {
                            service.execute(request, with: MockedSerializer()) { _ in
                                expect(Thread.isMainThread) == true
                                done()
                            }
                        }
                    }
                }

                it("should not return on the main queue") {
                    stubbedRequest.request(url: "https://relative.com/request", statuscode: 200)
                    let request = MockedRequest(url: URL(string: "request"))

                    waitUntil { done in
                        DispatchQueue.global(qos: .utility).async {
                            service.execute(request, with: MockedSerializer()) { _ in
                                expect(Thread.isMainThread) == false
                                done()
                            }
                        }
                    }
                }
            }

            context("serializer") {
                it("should fail to execute a request because of an invalid url") {
                    stubbedRequest.request(url: "https://relative.com/request", statuscode: 200)

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
                    stubbedRequest.request(url: "https://relative.com/request", json: body)

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
                    // let nsError = NSError(domain: "Cara", code: 1, userInfo: nil)
                    stubbedRequest.request(url: "https://relative.com/request", statuscode: 404)

                    let request = MockedRequest(url: URL(string: "request"))
                    let serializer = MockedSerializer()
                    waitUntil { done in
                        service.execute(request, with: serializer) { response in
                            expect(response.data).to(satisfyAnyOf(beNil(), equal(Data())))
                            expect(response.statusCode) == 404
                            done()
                        }
                    }
                }
                
                it("should return a http error") {
                    stubbedRequest.request(url: "https://relative.com/request", statuscode: 400)

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
    // swiftlint:enable function_body_length
}
