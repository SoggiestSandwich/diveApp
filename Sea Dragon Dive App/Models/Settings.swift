//
//  Settings.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/4/23.
//

import Foundation

//simple struct for holding the variables on the login screen
struct settings: Codable, Hashable {
    var role: Int //determines which function of the app you will go to (diver(0), coach(1), scoring(2) or announcing(3))
    var name: String //the users name which only is used for the diver
    var school: String //the school or team of the user which is only used for the coach
}
