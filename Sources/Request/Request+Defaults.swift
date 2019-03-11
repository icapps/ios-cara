//
//  Request+Defaults.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 02/03/2019.
//

import Foundation

extension Request {
    public var query: RequestQuery? {
        return nil
    }
    
    public var headers: RequestHeaders? {
        return nil
    }
    
    public var body: Any? {
        return nil
    }
    
    public var cachePolicy: URLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }
    
    public var networkServiceType: NSURLRequest.NetworkServiceType {
        return .default
    }
    
    public var isInterceptable: Bool {
        return true
    }
}
