//
//  ViewController.swift
//  Example
//
//  Created by Dylan Gyesbreghs on 02/01/2019.
//  Copyright © 2019 icapps. All rights reserved.
//

import UIKit

import Cara

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let networkReachability = NetworkReachability()
        networkReachability.listener = { status in
            print("🍞 Status: \(status)")
        }
        networkReachability.startListening()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("🍞 Connected: \(networkReachability.isConnected)")
            print("🍞 Cellular: \(networkReachability.isConnectedViaCellular)")
            print("🍞 WiFi: \(networkReachability.isConnectedViaWiFi)")
        }
    }


}

