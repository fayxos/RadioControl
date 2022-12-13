//
//  HomeView.swift
//  Skailer
//
//  Created by Sameer Nawaz on 22/05/21.
//

import SwiftUI

fileprivate let HORIZONTAL_SPACING: CGFloat = 24

struct HomeView: View {
    
    @ObservedObject var network: NetworkManager
    @State var displayPlayer: Bool = false
    
    let grid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack {
            Color.primary_color.edgesIgnoringSafeArea(.all)
            
            withAnimation(.spring()) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        HomeHeaderView(network: network)
                        
                        if(network.favorites.count != 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Favorites").foregroundColor(.text_header)
                                    .modifier(FontModifier(.bold, size: 30))
                                    .padding(.leading, HORIZONTAL_SPACING)
                                    .padding(.leading, 20)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(0..<network.favorites.count, id: \.self) { i in
                                            Button(action: {
                                                network.setRadioStation(station: network.favorites[i])
                                                network.updateData()
                                            }, label: {
                                                FavoriteView(name: network.favorites[i],
                                                             coverImage: Image("\(network.favorites[i])"))
                                            }).padding(.top, 20).padding(.bottom, 40)
                                        }
                                    }
                                    .padding(.leading, 30)
                                    .padding(.trailing)
                                }
                                
                            }
                            .padding(.top, 36)
                        }
                        
                        if(network.stations.count != 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Radio Stations").foregroundColor(.text_header)
                                    .modifier(FontModifier(.bold, size: 30))
                                    .padding(.leading, HORIZONTAL_SPACING)
                                LazyVGrid(columns: grid) {
                                    ForEach(0..<network.stations.count, id: \.self) { i in
                                        Button(action: {
                                            network.setRadioStation(station: network.stations[i])
                                            network.updateData()
                                        }, label: {
                                            FavoriteView(name: network.stations[i],
                                                         coverImage: Image("\(network.stations[i])"))
                                        }).padding(.top, 20)
                                    }
                                }
                            }
                            .padding(.leading, 20)
                        }
                                                
                        Spacer().frame(height: 150)
                        Spacer()
                    }
                    
                    .fullScreenCover(isPresented: $displayPlayer) {
                        PlayerView(network: network)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea([.horizontal, .bottom])
        .overlay {
            if(network.isConnected) {
                VStack {
                    Spacer()
                    ZStack {
                        Color.primary_color
                            
                        HStack {
                            ZStack{
                                Image("default").resizable().scaledToFill()
                                    .frame(width: 80, height: 80).cornerRadius(8)
                                Image(network.currentRadioStation).resizable().scaledToFill()
                                    .frame(width: 80, height: 80).cornerRadius(8)
                            }
                            .padding(.trailing)
                            
                            Text(network.currentRadioStation).foregroundColor(.text_primary)
                                .modifier(FontModifier(.bold, size: 25))
                                
                            Spacer()
                            
                            HStack(alignment: .center) {
                                Button(action: {
                                    if let index = network.stations.sorted(by: { $0 < $1}).firstIndex(where: { $0 == network.currentRadioStation }) {
                                        let i: Int = network.stations.sorted(by: { $0 < $1}).distance(from: network.stations.sorted(by: { $0 < $1}).startIndex, to: index)
                                        if (i-1 >= 0) {
                                            network.setRadioStation(station: network.stations.sorted(by: { $0 < $1})[i-1])
                                        } else {
                                            network.setRadioStation(station: network.stations.sorted(by: { $0 < $1}).last!)
                                        }
                                    }
                                    network.updateData()
                                }) {
                                    Image.next.resizable().frame(width: 15, height: 15)
                                        .rotationEffect(Angle(degrees: 180))
                                        .padding(15).background(Color.primary_color)
                                        .cornerRadius(30).modifier(NeuShadow())
                                }
                                
                                Button(action: {
                                    network.setPlayingStatus(play: network.isPlaying ? false : true)
                                    network.updateData()
                                }) {
                                    (network.isPlaying ? Image.pause : Image.play)
                                        .resizable().frame(width: 28, height: 28)
                                        .padding(25).background(Color.main_color)
                                        .cornerRadius(80).modifier(NeuShadow())
                                }
                                .padding(.horizontal)
                                
                                Button(action: {
                                    if let index = network.stations.sorted(by: { $0 < $1}).firstIndex(where: { $0 == network.currentRadioStation }) {
                                        let i: Int = network.stations.sorted(by: { $0 < $1}).distance(from: network.stations.sorted(by: { $0 < $1}).startIndex, to: index)
                                        if (i+1 < network.stations.sorted(by: { $0 < $1}).count) {
                                            network.setRadioStation(station: network.stations.sorted(by: { $0 < $1})[i+1])
                                        } else {
                                            network.setRadioStation(station: network.stations.sorted(by: { $0 < $1}).first!)
                                        }
                                    }
                                    network.updateData()
                                }) {
                                    Image.next.resizable().frame(width: 15, height: 15)
                                        .padding(15).background(Color.primary_color)
                                        .cornerRadius(30).modifier(NeuShadow())
                                }
                                .padding(.trailing)
                                
                                Button(action: {
                                    if network.favorites.contains(network.currentRadioStation)  {
                                        network.favorites.remove(at: network.favorites.firstIndex(of: network.currentRadioStation)!)
                                    } else {
                                        network.favorites.append(network.currentRadioStation)
                                    }
                                    let userDefaults = UserDefaults.standard
                                    userDefaults.set(!UserDefaults.standard.bool(forKey: network.currentRadioStation), forKey: network.currentRadioStation)
                                }) {
                                    (network.favorites.contains(network.currentRadioStation) ? Image.heart_filled : Image.heart)
                                        .resizable().frame(width: 25, height: 25)
                                }
                                .padding(.trailing)
                            }
                        }
                        .padding(.leading)
                        .padding(10)
                    }
                    .edgesIgnoringSafeArea([.horizontal, .bottom])
                    .frame(height: 100)
                    .modifier(NeuShadow())
                    .onTapGesture {
                        displayPlayer = true
                    }
                }
            }
        }
    }
}


fileprivate struct HomePlayingView: View {
    
    @StateObject var network: NetworkManager
    
    var body: some View {
        HStack(alignment: .center) {
            HStack {
                Image(systemName: network.isConnected ? "wifi" : "wifi.slash")
                    .foregroundColor(network.isConnected ? .green : .gray)
                    .font(.title)
                
                Text(network.isConnected ? "Connected" : "Disconnected").foregroundColor(network.isConnected ? .green : .gray)
                    .modifier(FontModifier(.black, size: 33))
            }
            
            Spacer()
            Button(action: {
                network.updateData()
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title.bold())
                    .frame(width: 40, height: 40)
                    .foregroundColor(.black)
                    .padding(12)
                    .background(Color.primary_color)
                    .cornerRadius(40)
                    .modifier(NeuShadow())
            }
        }.padding(.top, 12).padding(.horizontal, HORIZONTAL_SPACING)
    }
}


fileprivate struct HomeHeaderView: View {
    
    @StateObject var network: NetworkManager
    
    var body: some View {
        HStack(alignment: .center) {
            HStack {
                Image(systemName: network.isConnected ? "wifi" : "wifi.slash")
                    .foregroundColor(network.isConnected ? .green : .gray)
                    .font(.title)
                
                Text(network.isConnected ? "Connected" : "Disconnected").foregroundColor(network.isConnected ? .green : .gray)
                    .modifier(FontModifier(.black, size: 33))
            }
            
            Spacer()
            Button(action: { network.updateData() }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title.bold())
                    .frame(width: 40, height: 40)
                    .foregroundColor(.text_header)
                    .padding(12)
                    .background(Color.primary_color)
                    .cornerRadius(40)
                    .modifier(NeuShadow())
            }
        }.padding(.top, 12).padding(.horizontal, HORIZONTAL_SPACING)
    }
}

