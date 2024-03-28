//
//  CodableSerializerSpec.swift
//  Tests
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick
import Nimble

@testable import Cara

private class User: Codable {
    let firstName: String?
    let lastName: String?
    let birthDate: Date?
}

class CodableSerializerSpec: QuickSpec {
    // swiftlint:disable switch_case_alignment function_body_length cyclomatic_complexity
    override class func spec() {
        describe("CodableSerializer") {
            var service: Service!
            var serializer: CodableSerializer<User>!
            var stubbedRequest: StubbedRequest!

            beforeEach {
                let configuration = MockedConfiguration(baseURL: URL(string: "https://relative.com/")!)
                service = Service(configuration: configuration)
                
                serializer = CodableSerializer<User>()
                stubbedRequest = StubbedRequest()
            }

            afterEach {
                stubbedRequest.stopStubbedRequest()
            }

            it("should not serialize to a simple model but still be successful.") {
                stubbedRequest.request(url: "https://relative.com/request")
                
                let request = MockedRequest(url: URL(string: "request"), method: .get)
                waitUntil { done in
                    service.execute(request, with: serializer) { response in
                        switch response {
                            case .success(let model):
                                expect(model).to(beNil())
                                done()
                            case .failure: break
                        }
                    }
                }
            }
            
            it("should serialize to a simple model") {
                let body = [
                    "firstName": "Jake",
                    "lastName": "The Snake"
                ]
                stubbedRequest.request(url: "https://relative.com/request", statuscode: 200, json: body)

                let request = MockedRequest(url: URL(string: "request"), method: .get)
                waitUntil { done in
                    service.execute(request, with: serializer) { response in
                        switch response {
                            case .success(let model):
                                expect(model?.firstName) == "Jake"
                                expect(model?.lastName) == "The Snake"
                                done()
                            case .failure: break
                        }
                    }
                }
            }
            
            it("should throw an error in the serializer") {
                let nsError = NSError(domain: "Cara", code: 1, userInfo: nil)
                stubbedRequest.request(url: "https://relative.com/request", error: nsError)

                let request = MockedRequest(url: URL(string: "request"))
                waitUntil { done in
                    service.execute(request, with: serializer) { response in
                        switch response {
                            case .success: break
                            case .failure(let error):
                                let err = error as NSError
                                expect(err.domain) == "Cara"
                                expect(err.code) == 1
                                done()
                        }
                    }
                }
            }
            
            it("should throw an error in the serializer when the status code is a client one") {
                stubbedRequest.request(url: "https://relative.com/request", statuscode: 400)

                let request = MockedRequest(url: URL(string: "request"), method: .get)
                waitUntil { done in
                    service.execute(request, with: serializer) { response in
                        switch response {
                            case .success: break
                            case .failure(let error):
                                expect(error as? ResponseError) == ResponseError.badRequest
                                done()
                        }
                    }
                }
            }
            
            it("should throw an error in the serializer when the status code is a server one") {
                stubbedRequest.request(url: "https://relative.com/request", statuscode: 500)

                let request = MockedRequest(url: URL(string: "request"), method: .get)
                waitUntil { done in
                    service.execute(request, with: serializer) { response in
                        switch response {
                            case .success: break
                            case .failure(let error):
                                expect(error as? ResponseError) == ResponseError.internalServerError
                                done()
                        }
                    }
                }
            }
            
            it("should serialize to a model with a different decoder") {
                let body = ["birthDate": 1000]
                stubbedRequest.request(url: "https://relative.com/request", json: body)
                
                let request = MockedRequest(url: URL(string: "request"))
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let serializer = CodableSerializer<User>(decoder: decoder)
                waitUntil { done in
                    service.execute(request, with: serializer) { response in
                        switch response {
                            case .success(let model):
                                expect(model?.birthDate) == Date(timeIntervalSince1970: 1000)
                                done()
                            case .failure: break
                        }
                    }
                }
            }
        }
    }
    // swiftlint:enable switch_case_alignment function_body_length cyclomatic_complexity
}
