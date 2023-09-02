//
//  Divers.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/6/23.
//

import Foundation

struct divers: Hashable, Comparable, Codable {
    var dives: [dives]
    var diverEntries: diverEntry
    var placementScore: Double?
    var placement: Int?
    var skip: Bool?
    var date: Date?
    var location: String?
    
    static func == (lhs: divers, rhs: divers) -> Bool {
        return lhs.dives == rhs.dives && lhs.diverEntries == rhs.diverEntries && lhs.placement == rhs.placement && lhs.skip == rhs.skip && lhs.placementScore == rhs.placementScore && lhs.date == rhs.date && lhs.location == rhs.location
    }
    static func < (lhs: divers, rhs: divers) -> Bool {
        lhs.placementScore ?? -1 > rhs.placementScore ?? -1
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(dives)
        hasher.combine(diverEntries)
        hasher.combine(placement)
        hasher.combine(skip)
        hasher.combine(placementScore)
        hasher.combine(date)
        hasher.combine(location)
    }
    
}
