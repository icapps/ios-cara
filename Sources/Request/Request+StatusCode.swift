//
//  Request+Execute.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//

import Foundation

extension URLResponse {
    var httpStatusCode: Int {
        guard let httpURLResponse = self as? HTTPURLResponse else { return -1 }
        return httpURLResponse.statusCode
    }
}
