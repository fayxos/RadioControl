//
//  PlayerView.swift
//  Skailer
//
//  Created by Sameer Nawaz on 22/05/21.
//

import SwiftUI

fileprivate let HORIZONTAL_SPACING: CGFloat = 24

struct PlayerView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var network: NetworkManager
    
    var body: some View {
        ZStack {
            Color.primary_color.edgesIgnoringSafeArea(.all)
            
            withAnimation(.spring()) {
                VStack(alignment: .center, spacing: 0) {
                    HStack(alignment: .center) {
                        Button(action: {
                            network.getConnectionStatus()
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image.close.resizable().frame(width: 40, height: 40)
                                .padding(8).background(Color.primary_color)
                                .cornerRadius(40).modifier(NeuShadow())
                        }
                        Spacer()
                        Button(action: {
                            network.updateData()
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.title.bold())
                                .frame(width: 40, height: 40)
                                .foregroundColor(.text_header)
                                .padding(12)
                                .background(Color.primary_color)
                                .cornerRadius(40)
                                .modifier(NeuShadow())
                        }
                    }
                    .padding(.horizontal, HORIZONTAL_SPACING)
                    .padding(.top, 12)
                    
                    PlayerDiscView(coverImage: Image("\(network.currentRadioStation)"))
                        .padding(.top, 65)
                    
                    Text(network.currentRadioStation).foregroundColor(.text_primary)
                        .modifier(FontModifier(.black, size: 50))
                        .padding(.top, 32)
                    Text(network.currentRadioStation).foregroundColor(.text_primary_f1)
                        .modifier(FontModifier(.semibold, size: 45))
                        .padding(.top, 32)
                    
                    Spacer()
                        .frame(maxHeight: 300)
                    
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
                            Image.next.resizable().frame(width: 35, height: 35)
                                .rotationEffect(Angle(degrees: 180))
                                .padding(30).background(Color.primary_color)
                                .cornerRadius(65).modifier(NeuShadow())
                        }
                        Spacer()
                        Button(action: {
                            network.setPlayingStatus(play: network.isPlaying ? false : true)
                            network.updateData()
                        }) {
                            (network.isPlaying ? Image.pause : Image.play)
                                .resizable().frame(width: 48, height: 48)
                                .padding(65).background(Color.main_color)
                                .cornerRadius(113).modifier(NeuShadow())
                        }
                        Spacer()
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
                            Image.next.resizable().frame(width: 35, height: 35)
                                .padding(30).background(Color.primary_color)
                                .cornerRadius(65).modifier(NeuShadow())
                        }
                    }
                    .frame(maxWidth: 500)
                    .padding(.horizontal, 32)
                    
                    
                    Spacer()
                        .frame(maxHeight: 300)
                    
                    HStack(alignment: .center, spacing: 22) {
                        Text("\(Int(network.nextVolume))").foregroundColor(.text_primary)
                            .modifier(FontModifier(.bold, size: 25))
                            .frame(width: 42, height: 20)
                        Slider(value: Binding(get: {
                            Float(network.nextVolume)
                        }, set: { (newVal) in
                            if(Int(newVal) != network.nextVolume) {
                                network.nextVolume = Int(newVal)
                            }
                        }), in: 0...21)
                            .accentColor(.main_white)
                            //.gesture(DragGesture(minimumDistance: 0)
                            //    .onEnded { _ in
                            //        network.setVolume(volume: network.currentVolume)
                             //   }, including: .all)
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
                                .resizable().frame(width: 35, height: 35)
                        }
                    }
                    .frame(maxWidth: 800)
                    .padding(.horizontal, 25) 
                    
                    
                }.padding(.bottom, HORIZONTAL_SPACING)
            }.frame(maxWidth: 950, maxHeight: 1300)
        }
    }
}

fileprivate struct PlayerDiscView: View {
    let coverImage: Image
    var body: some View {
        ZStack {
            Image("default")
                .resizable()
                .frame(maxWidth: 600, maxHeight: 600)
                .aspectRatio(contentMode: .fill)
                .foregroundColor(.primary_color)
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            coverImage
                .resizable()
                .frame(maxWidth: 600, maxHeight: 600)
                .aspectRatio(contentMode: .fill)
                .foregroundColor(.primary_color)
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
        }
        .modifier(NeuShadow())
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(network: NetworkManager())
    }
}
