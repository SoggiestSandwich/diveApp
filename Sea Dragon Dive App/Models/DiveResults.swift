//
//  DiveResults.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/9/23.
//

import Foundation

struct resultsList: Codable {
    let diveResults: [diveResults]
    let placement: Int
}

struct diveResults: Codable {
    let code: String
    let score: [Double]
}
