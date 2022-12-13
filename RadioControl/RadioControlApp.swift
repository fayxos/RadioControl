//
//  RadioControlApp.swift
//  RadioControl
//
//  Created by Felix Haag on 15.09.22.
//

import SwiftUI

//TODO
// sender infos

@main
struct RadioControlApp: App {
    
    @StateObject private var network = NetworkManager()
    
    var body: some Scene {
        WindowGroup {
            HomeView(network: network)
        }
    }
}
