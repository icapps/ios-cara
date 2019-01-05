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
    
    public var connectivityURLs: [URL]? {
        get {
            return connectivy.connectivityURLs
        }
        set {
            if let value = newValue {
                connectivy.connectivityURLs = value
            }
        }
    }
    
    // MARK: - Internal Properties
    private lazy var connectivy: Connectivity = {
        let connectivy = Connectivity()
        connectivy.framework = .network
        return connectivy
    }()
    
    // MARK: - Init
    public init(connectivityURLs: [URL]? = nil) {
        self.connectivityURLs = connectivityURLs
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
        connectivy.whenConnected = networkChanged
        connectivy.whenDisconnected = networkChanged
    }
    
    private func updateConnectionStatus(_ connectivity: Connectivity) {
        guard let networkStatusChange = networkStatusChange else { return }
        networkStatusChange(connectivity.status)
    }
}
