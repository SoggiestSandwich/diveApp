//
//  AnnouncerEvent.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/13/24.
//

import Foundation

struct announcerEvent: Codable {
    var diver: [announcerDiver]
}

struct announcerDiver: Codable {
    var name: String
    var school: String
    var dives: [String]
}
