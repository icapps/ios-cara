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

private struct MockedRequest: Request {
    var url: URL?
}

class ServiceSpec: QuickSpec {
    override func spec() {
        describe("Service") {
            var service: Service!
            beforeEach {
                service = Service()
            }
            
            it("should execute a request") {
                self.stub(http(.get, uri: "https://icapps.com/request"), http(200))
                
                let request = MockedRequest(url: URL(string: "https://icapps.com/request"))
                waitUntil { done in
                    service.execute(request) { response in
                        switch response {
                        case .success: done()
                        case .failure: break
                        }
                    }
                }
            }
            
            it("should fail to execute a request") {
                self.stub(http(.get, uri: "https://icapps.com/request"), http(400))
                
                let request = MockedRequest(url: URL(string: "https://icapps.com/request"))
                waitUntil { done in
                    service.execute(request) { response in
                        switch response {
                        case .success: break
                        case .failure(let error):
                            expect(error as? ResponseError) == ResponseError.general
                            done()
                        }
                    }
                }
            }
            
            it("should fail to execute a request because of an invalid url") {
                self.stub(http(.get, uri: "http://icapps.com/request"), http(400))
                
                let request = MockedRequest()
                waitUntil { done in
                    service.execute(request) { response in
                        switch response {
                        case .success: break
                        case .failure(let error):
                            expect(error as? ResponseError) == ResponseError.invalidURL
                            done()
                        }
                    }
                }
            }
        }
    }
}
