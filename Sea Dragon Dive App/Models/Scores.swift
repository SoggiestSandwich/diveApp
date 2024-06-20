//
//  Scores.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/22/23.
//

import Foundation

//simple struct for holding the an individual score and it's index for sending across qr codes and deleting from any position
struct scores: Hashable, Codable, Identifiable {
    var id = UUID() //identifier for the score
    var score: Double //the score
    var index: Int //where it resides within an array
    
    //initializer
    init(score: Double, index: Int) {
        self.score = score
        self.index = index
    }
}
