//
//  NetworkReachability.swift
//  Cara
//
//  Created by Dylan Gyesbreghs on 02/01/2019.
//

import Connectivity

public typealias NetworkStatusChange = (Connectivity.Status) -> Void

class NetworkReachability {
    
    // MARK: - Public Properties
    public var networkStatusChange: NetworkStatusChange?
    
    // MARK: - Internal Properties
    private let configuration: Configuration
    private let connectivy: Connectivity = Connectivity()
    
    // MARK: - Init
    public init(configuration: Configuration) {
        self.configuration = configuration
        setupConnectivity()
    }
    
    // MARK: - Public Methods
    public func startListening() {
        connectivy.startNotifier()
    }
    
    public func stopListening() {
        connectivy.stopNotifier()
    }
    
    // MARK: - Helpers
    private func setupConnectivity() {
        let networkChanged: Connectivity.NetworkConnected = { [weak self] connectivy in
            self?.updateConnectionStatus(connectivy)
        }
        connectivy.framework = .network
        connectivy.setup(configuration: configuration)
        connectivy.whenConnected = networkChanged
        connectivy.whenDisconnected = networkChanged
    }
    
    private func updateConnectionStatus(_ connectivity: Connectivity) {
        guard let networkStatusChange = networkStatusChange else { return }
        networkStatusChange(connectivity.status)
    }
}
