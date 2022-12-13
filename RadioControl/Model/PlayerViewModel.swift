//
//  PlayerViewModel.swift
//  Skailer
//
//  Created by Sameer Nawaz on 22/05/21.
//

import Foundation

class PlayerViewModel: ObservableObject {
    
    @Published var model: RadioModel
    
    @Published var liked = false
    
    init(model: RadioModel) {
        self.model = model
        self.liked = UserDefaults.standard.bool(forKey: model.name)
    }
}
