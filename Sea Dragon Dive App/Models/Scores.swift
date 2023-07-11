//
//  Scores.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/22/23.
//

import Foundation

struct scores: Identifiable, Hashable {
    var score: Double
    var index: Int
    let id = UUID()
}
