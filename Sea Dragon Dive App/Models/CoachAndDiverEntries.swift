//
//  CoachAndDiverEntries.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/29/23.
//

import Foundation

struct coachEntry: Codable, Hashable {
    var diverEntries: [diverEntry]
    var eventDate, team: String
    var version: Int
    var location: String?
    var finished: Bool?
    
    init(diverEntries: [diverEntry], eventDate: String, team: String, version: Int) {
        self.diverEntries = diverEntries
        self.eventDate = eventDate
        self.team = team
        self.version = version
    }

}
struct diverEntry: Codable, Hashable {
    var dives: [String]
    var level: Int
    let name: String
    var team: String?
    var totalScore: Double?
    var dq: Bool?
    var diveCount: Int?
    var fullDives: [dives]?
    var placement: Int?
}
