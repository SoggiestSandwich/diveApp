//
//  CoachAndDiverEntries.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/29/23.
//

import Foundation

//holds the data for each entry the coach creates
struct coachEntry: Codable, Hashable {
    var diverEntries: [diverEntry] //list of each diver entry in the coaches entry
    var eventDate: String //date for the entries event
    var team: String //name of the coaches team
    //var version: Int //not sure what it was supposed to do but will keep here commented out in case I need it
    var location: String? //location of where the entry's event takes place
    var finished: Bool? //determines whether an entry is complete when showing results or entry editor
    
    //initializer
    init(diverEntries: [diverEntry], eventDate: String, team: String, version: Int) {
        self.diverEntries = diverEntries
        self.eventDate = eventDate
        self.team = team
        //self.version = version
    }

}
//holds the data for each entry the diver creates which is used to send less data through qr codes than divers struct
struct diverEntry: Codable, Hashable {
    var dives: [String] //list of the codes of the dives
    var level: Int //signifies if the diver is in exhibition(0), JV(1) or varsity(2)
    var name: String //name of the diver
    var finishedEntry: Bool? //determines if the entry has been finished for showing results
    var team: String? //diver entry's team name
    var totalScore: Double? //total score from for the entry
    var dq: Bool? //determines wheter the entry is valid
    var diveCount: Int? //the number of dives in the entry
    var fullDives: [dives]? //list of dives with all their attributes which is often created using the list of div codes
    var fullDivesScores: [[Double]]? //list of the scores for a whole event ([[each score from dive one],[each score from dive rwo], so on])
    var placement: Int? //placement the entry recieved in an event
    var volentary: [Bool]? //list that corresponds with the dives list to send volentary dives through qr codes for validation
}
