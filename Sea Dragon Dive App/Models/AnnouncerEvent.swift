//
//  AnnouncerEvent.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/13/24.
//

import Foundation

//holds a list of divers for the announcer
struct announcerEvent: Codable {
    var diver: [announcerDiver] //list of divers
}

//holds a diver for the announcer
struct announcerDiver: Codable {
    var name: String //divers name
    var school: String //divers school name
    var dives: [String] //list of the diver's dive codes
}
