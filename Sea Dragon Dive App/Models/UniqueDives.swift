//
//  UniqueDives.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/7/23.
//

import Foundation

//used for calculations in dive history by forming a list of dives allready dove before
struct uniqueDives: Comparable {
    var name: String //name of the dive ("Back Dive")
    var average: Double //average score of the dive with this name throughout dive history
    var position: String //name of the dive position ("Tuck")
    var degreeOfDifficulty: Double //dives point multplier
    var timesDove: Double //tracks how many times a dive with this name has been diven
    var code: String //code that represents the dive (202A)
    
    // overloads < operator to compare based on average
    static func < (lhs: uniqueDives, rhs: uniqueDives) -> Bool {
        lhs.average > rhs.average
    }
    
}
