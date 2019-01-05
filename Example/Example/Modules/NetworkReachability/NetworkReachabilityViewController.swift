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

    // MARK: - Internal
    
    private let service: Service = Service(configuration: ServiceConfiguration())
    
    // MARK: - Outlets
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var connectedLabel: UILabel!
    @IBOutlet weak var connectedViaCellular: UILabel!
    @IBOutlet weak var connectedViaWiFi: UILabel!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Network Reachability"
        setupView()
    }
    
    func setupView() {
        service.networkStatusChange = { status in
            self.statusLabel.text = "🍞 Status: \(status)"
        }
        service.startListening()
    }
}
