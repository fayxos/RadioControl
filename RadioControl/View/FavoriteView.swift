//
//  PlaylistView.swift
//  Skailer
//
//  Created by Sameer Nawaz on 22/05/21.
//

import SwiftUI

struct FavoriteView: View {
    
    let name: String, coverImage: Image
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack{
                Image("default").resizable().scaledToFill()
                    .frame(width: 180, height: 180).cornerRadius(16)
                coverImage.resizable().scaledToFill()
                    .frame(width: 180, height: 180).cornerRadius(16)
            }
            Text(name).foregroundColor(.text_primary)
                .modifier(FontModifier(.bold, size: 20))
                .padding(.top, 18).padding(.bottom, 6)

        }
        .padding(12).background(Color.primary_color)
        .cornerRadius(24).modifier(NeuShadow())
        .padding(.trailing)
    }
}
