//
//  DiveResults.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/9/23.
//

import Foundation

//simple struct for sending the results of an event through a qr code to the coach
struct resultsList: Codable {
    var diveResults: [diveResults] //list of the results for each dive
    let placement: Int //the placement achieved from the event
}

//struct with the minimum requirements for each dive to be sent through a qr code
struct diveResults: Codable {
    let code: String //code of the dive
    let score: [Double] //list of each judges score for the dive
}
