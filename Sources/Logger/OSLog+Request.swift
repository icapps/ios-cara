//
//  OSLog+Request.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 30/12/2018.
//

import os
import Foundation

extension OSLog {
    
    // MARK: - Categories
    
    static let request = OSLog(category: "Request")
    
    // MARK: - Init
    
    private convenience init(category: String, bundle: Bundle = Bundle.main) {
        let identifier = bundle.infoDictionary?["CFBundleIdentifier"] as? String
        self.init(subsystem: (identifier ?? "").appending(".logs"), category: category)
    }
}
