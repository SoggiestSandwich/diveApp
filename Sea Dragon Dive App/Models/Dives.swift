//
//  Dives.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/20/23.
//

import Foundation

struct dives: Hashable {
    let name: String
    let degreeOfDiff: Double
    var score: [scores]
    let position: String
    var roundScore: Double
    
    static func == (lhs: dives, rhs: dives) -> Bool {
        return lhs.name == rhs.name && lhs.degreeOfDiff == rhs.degreeOfDiff && lhs.score == rhs.score && lhs.position == rhs.position && lhs.roundScore == rhs.roundScore
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(degreeOfDiff)
        hasher.combine(score)
        hasher.combine(position)
        hasher.combine(roundScore)
    }
}
