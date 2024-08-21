//
//  UnIndexedScoreDives.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/15/24.
//

import Foundation

//holds all the needed information when it comes to dives
struct scoringDives: Hashable, Codable {
    var scores: [String] //array that holds each judges individual scores
    var diveTotal: Double //total score of the round (degreeOfDiff * sum(score))
    var diveId: String? //the code that represents the dive ("101C")
    
    //magic hashing stuff so that the struct is hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(scores)
        hasher.combine(diveTotal)
        hasher.combine(diveId)
    }
}
