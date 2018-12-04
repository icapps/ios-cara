//
//  CodableSerializerSpec.swift
//  Tests
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import Mockingjay

@testable import Cara

private class User: Codable {
    let firstName: String?
    let lastName: String?
    let birthDate: Date?
}

class CodableSerializerSpec: QuickSpec {
    // swiftlint:disable function_body_length cyclomatic_complexity
    override func spec() {
        describe("CodableSerializer") {
            var service: Service!
            var serializer: CodableSerializer<User>!
            beforeEach {
                let configuration = MockedConfiguration(baseURL: URL(string: "https://relative.com/")!)
                service = Service(configuration: configuration)
                
                serializer = CodableSerializer<User>()
            }
            
            it("should not serialize to a simple model but still be successful.") {
                self.stub(http(.get, uri: "https://relative.com/request"), http(200))
                
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
                self.stub(http(.get, uri: "https://relative.com/request"), json(body))
                
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
            
            it("should fail to serialize to a simple model") {
                let body = ["firstName"]
                self.stub(http(.get, uri: "https://relative.com/request"), json(body))
                
                let request = MockedRequest(url: URL(string: "request"))
                waitUntil { done in
                    service.execute(request, with: serializer) { response in
                        switch response {
                        case .success: break
                        case .failure:
                            done()
                        }
                    }
                }
            }
            
            it("should throw an error in the serializer") {
                let nsError = NSError(domain: "Cara", code: 1, userInfo: nil)
                self.stub(http(.get, uri: "https://relative.com/request"), failure(nsError))
                
                let request = MockedRequest(url: URL(string: "request"))
                waitUntil { done in
                    service.execute(request, with: serializer) { response in
                        switch response {
                        case .success: break
                        case .failure(let error):
                            expect(error as NSError?) == nsError
                            done()
                        }
                    }
                }
            }
            
            it("should throw an error in the serializer when the status code is a client one") {
                self.stub(http(.get, uri: "https://relative.com/request"), http(400))
                
                let request = MockedRequest(url: URL(string: "request"), method: .get)
                waitUntil { done in
                    service.execute(request, with: serializer) { response in
                        switch response {
                        case .success: break
                        case .failure(let error):
                            expect(error as? ResponseError) == ResponseError.httpError(statusCode: 400)
                            done()
                        }
                    }
                }
            }
            
            it("should throw an error in the serializer when the status code is a server one") {
                self.stub(http(.get, uri: "https://relative.com/request"), http(500))
                
                let request = MockedRequest(url: URL(string: "request"), method: .get)
                waitUntil { done in
                    service.execute(request, with: serializer) { response in
                        switch response {
                        case .success: break
                        case .failure(let error):
                            expect(error as? ResponseError) == ResponseError.httpError(statusCode: 500)
                            done()
                        }
                    }
                }
            }

            it("should serialize to a model with a different decoder") {
                let body = ["birthDate": 1000]
                self.stub(http(.get, uri: "https://relative.com/request"), json(body))

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
}
