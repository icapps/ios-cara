//
//  Request.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 01/12/2018.
//

extension Dictionary {
    mutating func merge(dict: [Key: Value]) {
        dict.forEach { updateValue($0.value, forKey: $0.key) }
    }
}
