//
//  Events.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/18/23.
//

import Foundation

struct events: Codable, Identifiable {
    var id = UUID()
    var date: String
    var EList: [divers]
    var JVList: [divers]
    var VList: [divers]
    
    init(date: String, EList: [divers], JVList: [divers], VList: [divers]) {
        self.date = date
        self.EList = EList
        self.JVList = JVList
        self.VList = VList
    }
 }
