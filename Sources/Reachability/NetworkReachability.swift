//
//  NetworkReachability.swift
//  Cara
//
//  Created by Dylan Gyesbreghs on 02/01/2019.
//

import Connectivity

open class NetworkReachability {
    
    // MARK: - Public Properties
    public typealias Listener = (Connectivity.Status) -> Void
    
    public var listener: Listener?
    
    public var isPollingEnabled: Bool {
        set {
            connectivy.isPollingEnabled = newValue
            connectivy.startNotifier()
        }
        get {
            return connectivy.isPollingEnabled
        }
    }
    
    public var isConnected: Bool {
        return connectivy.isConnected
    }
    
    public var isConnectedViaCellular: Bool {
        return connectivy.isConnectedViaCellular
    }
    
    public var isConnectedViaWiFi: Bool {
        return connectivy.isConnectedViaWiFi
    }
    
    public var isConnectedViaCellularWithoutInternet: Bool {
        return connectivy.isConnectedViaCellularWithoutInternet
    }
    
    public var isConnectedViaWiFiWithoutInternet: Bool {
        return connectivy.isConnectedViaWiFiWithoutInternet
    }
    
    // MARK: - Internal Properties
    private lazy var connectivy: Connectivity = {
        let connectivy = Connectivity()
        connectivy.framework = .network
        return connectivy
    }()
    
    // MARK: - Init
    public init() {
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
        guard let listener = listener else { return }
        listener(connectivity.status)
    }
}
