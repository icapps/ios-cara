//
//  Configuration+Logger.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 30/12/2018.
//

import Foundation

extension Configuration {
    func start(urlRequest: URLRequest) {
        loggers?.forEach { $0.start(urlRequest: urlRequest) }
    }
}
