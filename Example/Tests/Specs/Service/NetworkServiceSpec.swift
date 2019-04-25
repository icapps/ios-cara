//
//  NetworkServiceSpec.swift
//  Tests
//
//  Created by Jelle Vandebeeck on 30/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import Mockingjay
import Foundation

@testable import Cara

class NetworkServiceSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("NetworkService") {
            var service: NetworkService!
            var configuration: MockedConfiguration!
            var pinningService: MockedPublicKeyPinningService!
            beforeEach {
                configuration = MockedConfiguration(baseURL: URL(string: "https://relative.com/")!)
                pinningService = MockedPublicKeyPinningService(configuration: configuration)
                service = NetworkService(configuration: configuration, pinningService: pinningService)
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
                    self.stub(http(.get, uri: "https://relative.com/request"), delay: 0.1, http(200))
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
                    self.stub(http(.get, uri: "https://relative.com/request"), delay: 0.1, http(200))
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
                    self.stub(http(.get, uri: "https://relative.com/one"), http(401))
                    let one = URLRequest(url: URL(string: "https://relative.com/one")!)
                    
                    let interceptor = MockedInterceptor()
                    interceptor.interceptHandle = { error, retry in
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
                    self.stub(http(.get, uri: "https://relative.com/one"), http(401))
                    let one = URLRequest(url: URL(string: "https://relative.com/one")!)
                    
                    let interceptor = MockedInterceptor()
                    interceptor.interceptHandle = { error, retry in
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
                    self.stub(http(.get, uri: "https://relative.com/one"), http(401))
                    let one = URLRequest(url: URL(string: "https://relative.com/one")!)
                    
                    let interceptor = MockedInterceptor()
                    interceptor.interceptHandle = { error, retry in
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
                    self.stub(http(.get, uri: "https://relative.com/request"), http(200))
                    let request = URLRequest(url: URL(string: "https://relative.com/request")!)
                    
                    waitUntil { done in
                        DispatchQueue.main.async {
                            service.execute(request,
                                            with: MockedSerializer(),
                                            isInterceptable: true,
                                            retryCount: 0,
                                            executionQueue: DispatchQueue.main,
                                            retry: {}, completion: { _ in
                                expect(Thread.isMainThread) == true
                                done()
                            })
                        }
                    }
                }
                
                it("should not return on the global queue") {
                    self.stub(http(.get, uri: "https://relative.com/request"), http(200))
                    let request = URLRequest(url: URL(string: "https://relative.com/request")!)
                    
                    waitUntil { done in
                        DispatchQueue.global(qos: .utility).async {
                            service.execute(request,
                                            with: MockedSerializer(),
                                            isInterceptable: true,
                                            retryCount: 0,
                                            executionQueue: DispatchQueue.global(),
                                            retry: {},
                                            completion: { _ in
                                expect(Thread.isMainThread) == false
                                done()
                            })
                        }
                    }
                }
            }
        }
    }
}
