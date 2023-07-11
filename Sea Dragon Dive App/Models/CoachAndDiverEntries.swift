//
//  CoachAndDiverEntries.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/29/23.
//

import Foundation

struct coachEntry: Codable {
    let diverEntries: [diverEntry]
    let eventDate, team: String
    let version: Int
}

struct diverEntry: Codable, Hashable {
    let dives: [String]
    var level: Int
    let name: String
    var team: String?
    var score: Double?
}
