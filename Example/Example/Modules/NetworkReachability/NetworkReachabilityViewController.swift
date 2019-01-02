//
//  NetworkReachabilityViewController.swift
//  Example
//
//  Created by Dylan Gyesbreghs on 02/01/2019.
//  Copyright © 2019 icapps. All rights reserved.
//

import UIKit
import Cara

class NetworkReachabilityViewController: UIViewController {

    fileprivate let networkReachability = NetworkReachability()
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var connectedLabel: UILabel!
    @IBOutlet weak var connectedViaCellular: UILabel!
    @IBOutlet weak var connectedViaWiFi: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Network Reachability"
        setupView()
    }
    
    func setupView() {
        networkReachability.listener = { status in
            self.statusLabel.text = "🍞 Status: \(status)"
        }
        networkReachability.startListening()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.connectedLabel.text = "🍞 Connected: \(self.networkReachability.isConnected)"
            self.connectedViaCellular.text = "🍞 Cellular: \(self.networkReachability.isConnectedViaCellular)"
            self.connectedViaWiFi.text = "🍞 WiFi: \(self.networkReachability.isConnectedViaWiFi)"
        }
    }
}
