//
//  Scores.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/22/23.
//

import Foundation

struct scores: Hashable, Codable, Identifiable {
    var id = UUID()
    var score: Double
    var index: Int
    
    init(score: Double, index: Int) {
        self.score = score
        self.index = index
    }
}
