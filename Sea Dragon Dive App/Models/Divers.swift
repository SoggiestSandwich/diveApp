//
//  Divers.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/6/23.
//

import Foundation

//holds everything a diver needs
struct divers: Hashable, Comparable, Codable {
    var dives: [dives] //holds the entire list of dives for an event
    var diverEntries: diverEntry //used to gain the attributes in diverEntry (name, team, etc.)
    var placementScore: Double? //holds the score of non-dq'ed divers for events for determining placements at the end of scoring
    var placement: Int? //holds what place the diver got in the event
    var skip: Bool? //marks if a diver has been dropped in scoring and should be skipped when moving to the next diver
    var date: Date? //the date of the event the diver participated in
    var location: String? //the location of the the event that the diver participated in
    var finished: Bool? //marks if the diver is finished to disclude unfinished entries from being included in calculating best dives
    var dq: Bool? //marks an invalid dive entry so they can not recieve a placement
    var diveCount: Int? //holds the number of dives in a dive event
    
    //overloads == operator
    static func == (lhs: divers, rhs: divers) -> Bool {
        return lhs.dives == rhs.dives && lhs.diverEntries == rhs.diverEntries && lhs.placement == rhs.placement && lhs.skip == rhs.skip && lhs.placementScore == rhs.placementScore && lhs.date == rhs.date && lhs.location == rhs.location && lhs.finished == rhs.finished && lhs.dq == rhs.dq && lhs.diveCount == rhs.diveCount
    }
    //overloads < operator for comparing based on the placement score
    static func < (lhs: divers, rhs: divers) -> Bool {
        lhs.placementScore ?? -1 > rhs.placementScore ?? -1
    }
    //more hash magic
    func hash(into hasher: inout Hasher) {
        hasher.combine(dives)
        hasher.combine(diverEntries)
        hasher.combine(placement)
        hasher.combine(skip)
        hasher.combine(placementScore)
        hasher.combine(date)
        hasher.combine(location)
        hasher.combine(finished)
        hasher.combine(dq)
        hasher.combine(diveCount)
    }
    
}
