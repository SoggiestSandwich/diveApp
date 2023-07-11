//
//  Scores.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/22/23.
//

import Foundation

struct scores: Identifiable, Hashable, Codable {
    var score: Double
    var index: Int
    let id: UUID
    
    init(score: Double, index: Int, id: UUID = UUID()) {
        self.score = score
        self.index = index
        self.id = id
    }
}
