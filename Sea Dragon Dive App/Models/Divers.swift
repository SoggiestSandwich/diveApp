//
//  Divers.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/6/23.
//

import Foundation

struct divers: Hashable, Comparable {
    var dives: [dives]
    var diverEntries: diverEntry
    var placement: Int?
    
    static func == (lhs: divers, rhs: divers) -> Bool {
        return lhs.dives == rhs.dives && lhs.diverEntries == rhs.diverEntries && lhs.placement == rhs.placement
    }
    static func < (lhs: divers, rhs: divers) -> Bool {
        lhs.diverEntries.score! > rhs.diverEntries.score!
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(dives)
        hasher.combine(diverEntries)
        hasher.combine(placement)
    }
    
}
