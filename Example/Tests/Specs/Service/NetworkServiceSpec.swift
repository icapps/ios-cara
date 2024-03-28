//
//  NetworkServiceSpec.swift
//  Tests
//
//  Created by Jelle Vandebeeck on 30/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import Foundation

@testable import Cara

class NetworkServiceSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override class func spec() {
        describe("NetworkService") {
            var service: NetworkService!
            var configuration: MockedConfiguration!
            var pinningService: MockedPublicKeyPinningService!
            var stubbedRequest: StubbedRequest!
            beforeEach {
                configuration = MockedConfiguration(baseURL: URL(string: "https://relative.com/")!)
                pinningService = MockedPublicKeyPinningService(configuration: configuration)
                service = NetworkService(configuration: configuration, pinningService: pinningService)
                stubbedRequest = StubbedRequest()
            }

            afterEach {
                stubbedRequest.stopStubbedRequest()
            }

            context("logger") {
                var loggerOne: MockedLogger!
                var loggerTwo: MockedLogger!
                beforeEach {
                    loggerOne = MockedLogger()
                    loggerTwo = MockedLogger()
                    configuration.loggers = [loggerOne, loggerTwo]
                }
                
                it("should trigger the start on all the configuration") {
                    stubbedRequest.request(url: "https://relative.com/request", statuscode: 200)
                    let request = URLRequest(url: URL(string: "https://relative.com/request")!)

                    service.execute(request,
                                    with: MockedSerializer(),
                                    isInterceptable: true,
                                    retryCount: 0,
                                    executionQueue: nil,
                                    retry: {},
                                    completion: { _ in })

                    expect(loggerOne.didTriggerStartRequest).toNot(beNil())
                    expect(loggerTwo.didTriggerStartRequest).toNot(beNil())
                }
                
                it("should trigger the end on all the configuration") {
                    stubbedRequest.request(url: "https://relative.com/request", statuscode: 200)
                    let request = URLRequest(url: URL(string: "https://relative.com/request")!)
                    
                    waitUntil { done in
                        service.execute(request,
                                        with: MockedSerializer(),
                                        isInterceptable: true,
                                        retryCount: 0,
                                        executionQueue: nil,
                                        retry: {},
                                        completion: { _ in
                            done()
                        })
                    }
                    expect(loggerOne.didTriggerEnd) == true
                    expect(loggerTwo.didTriggerEnd) == true
                }
            }
            
            context("refresh") {
                it("should not retry a request") {
                    stubbedRequest.request(url: "https://relative.com/one", statuscode: 401)
                    let one = URLRequest(url: URL(string: "https://relative.com/one")!)
                    
                    let interceptor = MockedInterceptor()
                    interceptor.interceptHandle = { _, retry in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: retry)
                        return false
                    }
                    service.interceptor = interceptor
                    
                    waitUntil { done in
                        service.execute(one,
                                        with: MockedSerializer(),
                                        isInterceptable: true,
                                        retryCount: 0,
                                        executionQueue: nil,
                                        retry: {},
                                        completion: { _ in
                            done()
                        })
                    }
                }
                
                it("should retry a request") {
                    stubbedRequest.request(url: "https://relative.com/one", statuscode: 401)
                    let one = URLRequest(url: URL(string: "https://relative.com/one")!)
                    
                    let interceptor = MockedInterceptor()
                    interceptor.interceptHandle = { _, retry in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: retry)
                        return true
                    }
                    service.interceptor = interceptor
                    
                    waitUntil { done in
                        service.execute(one,
                                        with: MockedSerializer(),
                                        isInterceptable: true,
                                        retryCount: 0,
                                        executionQueue: nil,
                                        retry: {
                            done()
                        }, completion: { _ in })
                    }
                }
                
                it("should not retry a request when not interceptable") {
                    stubbedRequest.request(url: "https://relative.com/one", statuscode: 401)
                    let one = URLRequest(url: URL(string: "https://relative.com/one")!)
                    
                    let interceptor = MockedInterceptor()
                    interceptor.interceptHandle = { _, retry in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: retry)
                        return true
                    }
                    service.interceptor = interceptor
                    
                    waitUntil { done in
                        service.execute(one,
                                        with: MockedSerializer(),
                                        isInterceptable: false,
                                        retryCount: 0,
                                        executionQueue: nil,
                                        retry: {},
                                        completion: { _ in
                            done()
                        })
                    }
                }
            }
            
            context("threading") {
                it("should return on the main queue") {
                    stubbedRequest.request(url: "https://relative.com/request", statuscode: 200)
                    let request = URLRequest(url: URL(string: "https://relative.com/request")!)
                    
                    waitUntil { done in
                        service.execute(request,
                                        with: MockedSerializer(),
                                        isInterceptable: true,
                                        retryCount: 0,
                                        executionQueue: DispatchQueue.main,
                                        retry: {}, completion: { _ in
                            expect(Thread.isMainThread) == true
                            expect(Thread.current.qualityOfService) == .default
                            done()
                        })
                    }
                }
                
                it("should return on the global queue") {
                    stubbedRequest.request(url: "https://relative.com/request", statuscode: 200)
                    let request = URLRequest(url: URL(string: "https://relative.com/request")!)
                    
                    waitUntil { done in
                        service.execute(request,
                                        with: MockedSerializer(),
                                        isInterceptable: true,
                                        retryCount: 0,
                                        executionQueue: DispatchQueue.global(qos: .utility),
                                        retry: {},
                                        completion: { _ in
                            expect(Thread.isMainThread) == false
                            expect(Thread.current.qualityOfService) == .utility
                            done()
                        })
                    }
                }
            }
        }
    }
}
