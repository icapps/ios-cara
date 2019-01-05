//
//  ServiceConfiguration.swift
//  Example
//
//  Created by Dylan Gyesbreghs on 05/01/2019.
//  Copyright © 2019 icapps. All rights reserved.
//

import Cara

struct ServiceConfiguration: Cara.Configuration {
    var baseURL: URL? {
        return URL(string: "https://icapps.com/")
    }
    var headers: RequestHeaders? {
        return nil
    }
    var publicKeys: PublicKeys? {
        return nil
    }
    var loggers: [Logger]? {
        return nil
    }
    var connectivityURLs: [URL]? {
        return nil
    }
}
