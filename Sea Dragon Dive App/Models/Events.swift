//
//  Events.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/18/23.
//

import Foundation

//stores each dive event for scoring
struct events: Codable, Identifiable, Hashable {
    var id = UUID() //identifier used to make the struct Identifiable
    var date: String //date of the event
    var EList: [divers] //list of divers in exhibition
    var JVList: [divers] //list of divers in junior varsity
    var VList: [divers] //list of divers in varsity
    var finished: Bool //signifies that an event is finished and can show results
    var judgeCount: Int //the number of judges for an event
    var diveCount: Int //the maximum number of dives allowed in the event that is changed when the event is started to prevent errors
    var reviewed: Bool //confirms that an official has reviewed the divers diving before allowing the event to start
    
    //initializer
    init(date: String, EList: [divers], JVList: [divers], VList: [divers], finished: Bool, judgeCount: Int, diveCount: Int, reviewed: Bool) {
        self.date = date
        self.EList = EList
        self.JVList = JVList
        self.VList = VList
        self.finished = finished
        self.judgeCount = judgeCount
        self.diveCount = diveCount
        self.reviewed = reviewed
    }
 }
