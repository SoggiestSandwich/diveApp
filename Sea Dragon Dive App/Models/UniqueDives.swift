//
//  UniqueDives.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/7/23.
//

import Foundation

struct uniqueDives: Comparable {
    var name: String
    var average: Double
    var position: String
    var degreeOfDifficulty: Double
    var timesDove: Double
    var code: String
    
    static func < (lhs: uniqueDives, rhs: uniqueDives) -> Bool {
        lhs.average > rhs.average
    }
    
}
