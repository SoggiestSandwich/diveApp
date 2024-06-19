//
//  Dives.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/20/23.
//

import Foundation

//holds all the needed information when it comes to dives
struct dives: Hashable, Codable {
    var name: String //name of the dive ("Forward Dive")
    var degreeOfDiff: Double //point multplier
    var score: [scores] //array that holds each judges individual scores
    var position: String //name of the dive's position ("Straight")
    var roundScore: Double //total score of the round (degreeOfDiff * sum(score))
    var scored: Bool? //signifies that a dive has been scored for scoring
    var code: String? //the code that represents the dive ("101C")
    var volentary: Bool? //signifies that the dive in a volentary dive for validation of a diver entry with 11 dives
    
    //overloads the == operator
    static func == (lhs: dives, rhs: dives) -> Bool {
        return lhs.name == rhs.name && lhs.degreeOfDiff == rhs.degreeOfDiff && lhs.score == rhs.score && lhs.position == rhs.position && lhs.roundScore == rhs.roundScore && lhs.scored == rhs.scored && lhs.code == rhs.code && lhs.volentary == rhs.volentary
    }
    
    //magic hashing stuff so that the struct is hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(degreeOfDiff)
        hasher.combine(score)
        hasher.combine(position)
        hasher.combine(roundScore)
        hasher.combine(scored)
        hasher.combine(code)
        hasher.combine(volentary)
    }
}
