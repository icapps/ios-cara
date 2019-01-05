//
//  Connectivity+Configuration.swift
//  Cara
//
//  Created by Dylan Gyesbreghs on 05/01/2019.
//

import Connectivity

extension Connectivity {
    func setup(configuration: Configuration) {
        if let connectivityURLs = configuration.connectivityURLs {
            self.connectivityURLs = connectivityURLs
        }
    }
}
