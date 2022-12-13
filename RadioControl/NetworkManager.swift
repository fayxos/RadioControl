//
//  NetworkManager.swift
//  RadioControl
//
//  Created by Felix Haag on 16.09.22.
//

import Foundation
import SwiftUI

class NetworkManager: ObservableObject {
    
    @Published var isConnected: Bool = false
    @Published var isPlaying: Bool = false
    @Published var currentRadioStation: String = "SWR3"
    @Published var currentVolume: Int = 2
    @Published var nextVolume: Int = 2
    @Published var stations: [String] = []
    @Published var favorites: [String] = []
    
    let url = "http://hfradio.local"
    
    init() {
        getStations()
        updateData()
        volumeLoop()
    }
    
    func updateData() {
        getConnectionStatus()
        getPlayingStatus()
        getCurrentRadioStation()
        getVolume()
    }
    
    private var timer: DispatchSourceTimer?
    private func volumeLoop() {
        let queue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".timer")
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer!.schedule(deadline: .now(), repeating: .seconds(2))
        timer!.setEventHandler { [weak self] in
            if self!.isConnected {
                if self!.nextVolume != self!.currentVolume {
                    DispatchQueue.main.async {
                        self!.currentVolume = self!.nextVolume
                    }
                    
                    self!.setVolume(volume: self!.nextVolume)
                }
            }
        }
        timer!.resume()
    }
    
    private func getStations() {
        let connectionURL = URL(string: "\(url)/sender")!
        
        let task = URLSession.shared.dataTask(with: connectionURL) { [self] data, reponse, error in
            if let data = data {
                if let reponseString = try? JSONSerialization.jsonObject(with: data) as? [String: String] { // { name: link }
                    var s: [String] = []
                    for stationName in reponseString.keys {
                        s.append(stationName)
                    }
                    DispatchQueue.main.async {
                        self.stations = s.sorted { $0.lowercased() < $1.lowercased() }
                        self.getFavorites()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isConnected = false
                    }
                }
            } else if error != nil {
                print(error ?? "error")
                DispatchQueue.main.async {
                    self.isConnected = false
                }
            }
        }
        
        task.resume()
    }
    
    func getFavorites() {
        var f: [String] = []
        
        let userDefaults = UserDefaults.standard
        
        for station in stations {
            if userDefaults.bool(forKey: station) == true {
                f.append(station)
            }
        }
        
        DispatchQueue.main.async {
            self.favorites = f.sorted { $0.lowercased() < $1.lowercased() }
        }
    }
    
    func getConnectionStatus() {
        let connectionURL = URL(string: "\(url)/getConnectionStatus")!
        
        let task = URLSession.shared.dataTask(with: connectionURL) { [self] data, reponse, error in
            if let data = data {
                if let reponseString = try? JSONSerialization.jsonObject(with: data) as? [String: Bool] { // { isPlaying: true }
                    if reponseString["isConnected"] == true {
                        DispatchQueue.main.async {
                            self.isConnected = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.isConnected = false
                            self.favorites = []
                            self.stations = []
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isConnected = false
                        self.favorites = []
                        self.stations = []
                    }
                }
            } else if error != nil {
                print(error ?? "error")
                DispatchQueue.main.async {
                    self.isConnected = false
                    self.favorites = []
                    self.stations = []
                }
            }
        }
        
        task.resume()
    }
    
    func getPlayingStatus() {
        let connectionURL = URL(string: "\(url)/getPlayingStatus")!
        
        let task = URLSession.shared.dataTask(with: connectionURL) { data, reponse, error in
            if let data = data {
                if let reponseString = try? JSONSerialization.jsonObject(with: data) as? [String: Bool] { // { isPlaying: true }
                    if reponseString["isPlaying"] == true {
                        DispatchQueue.main.async {
                            self.isPlaying = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.isPlaying = false
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isConnected = false
                    }
                }
            } else if error != nil {
                print(error ?? "error")
                DispatchQueue.main.async {
                    self.isConnected = false
                }
            }
        }
    
        
        task.resume()
    }
    
    func getCurrentRadioStation() {
        
        let connectionURL = URL(string: "\(url)/getCurrentRadioStation")!
        
        let task = URLSession.shared.dataTask(with: connectionURL) { data, reponse, error in
            if let data = data {
                if let reponseString = try? JSONSerialization.jsonObject(with: data) as? [String: String] { // { station: "name" }
                    if let name = reponseString["station"] {
                        DispatchQueue.main.async {
                            self.currentRadioStation = name
                        }
                    }
                }
            } else if error != nil {
                print(error ?? "error")
            }
        }
        
        task.resume()
    }
    
    func getVolume() {
        
        let connectionURL = URL(string: "\(url)/getVolume")!
        
        let task = URLSession.shared.dataTask(with: connectionURL) { data, reponse, error in
            if let data = data {
                if let reponseString = try? JSONSerialization.jsonObject(with: data) as? [String: Int] { // { volume: 2}
                    DispatchQueue.main.async {
                        self.currentVolume = Int(reponseString["volume"]!)
                        self.nextVolume = Int(reponseString["volume"]!)
                    }
                }
            } else if error != nil {
                print(error ?? "error")
            }
        }
        
        task.resume()
    }
    
    func setPlayingStatus(play: Bool) {
        
        let connectionURL = URL(string: "\(url)/pauseResume")!
        
        let task = URLSession.shared.dataTask(with: connectionURL) { data, reponse, error in
            if let data = data {
                if let reponseString = try? JSONSerialization.jsonObject(with: data) as? [String: String] { // { error: ""}
                    if reponseString["error"] != "" {
                        print(reponseString["error"]!)
                    } else {
                        DispatchQueue.main.async {
                            self.isPlaying = play
                        }
                    }
                }
            } else if error != nil {
                print(error ?? "error")
            }
        }
        
        task.resume()
    }
    
    func setRadioStation(station: String) {
        if(currentRadioStation == station) {
            return;
        }
        
        let connectionURL = URL(string: "\(url)/setRadioStation?s=\(station.replacingOccurrences(of: " ", with: "+"))")!
        
        let task = URLSession.shared.dataTask(with: connectionURL) { data, reponse, error in
            if let data = data {
                if let reponseString = try? JSONSerialization.jsonObject(with: data) as? [String: String] { // { error: ""}
                    if reponseString["error"] != "" {
                        print(reponseString["error"]!)
                    } else {
                        DispatchQueue.main.async {
                            self.currentRadioStation = station
                        }
                    }
                }
            } else if error != nil {
                print(error ?? "error")
            }
        }
        
        task.resume()
    }
    
    func setVolume(volume: Int) {
        
        let connectionURL = URL(string: "\(url)/setVolume?v=\(Int(volume))")!
        
        let task = URLSession.shared.dataTask(with: connectionURL) { data, reponse, error in
            if let data = data {
                if let reponseString = try? JSONSerialization.jsonObject(with: data) as? [String: String] { // { error: ""}
                    if reponseString["error"] != "" {
                        print(reponseString["error"]!)
                    } else {
                        DispatchQueue.main.async {
                            self.currentVolume = volume
                        }
                    }
                }
            } else if error != nil {
                print(error ?? "error")
            }
        }
        
        task.resume()
    }
    
}
