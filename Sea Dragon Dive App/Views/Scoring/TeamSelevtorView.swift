//
//  TeamSelevtorView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/20/23.
//

import SwiftUI


struct TeamSelevtorView: View {
    @State var diverList: [divers]
    
    @State var teamList: [String] = []
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(teamList, id: \.hashValue) { team in
                    NavigationLink(destination: ResultsQRView(team: team, url: createQRDataString(team: team))) {
                        Text(team)
                    }
                }
            }
            .navigationTitle("Select Team")
        }
        .onAppear {
            for diver in diverList {
                var breakloop = false
                for team in teamList {
                    if !breakloop {
                        if diver.diverEntries.team == team {
                            breakloop = true
                        }
                    }
                }
                if !breakloop {
                    teamList.append(diver.diverEntries.team ?? "")
                }
            }
        }
    }
    //
    //score(individual)?, skip?
    func createQRDataString(team: String) -> String {
        var tempDiverList: [divers] = []
        var allDiversCode: String = "{\"diverEntries\":["
        for diver in diverList {
            if team == diver.diverEntries.team {
                tempDiverList.append(diver)
            }
        }
        for diver in tempDiverList {
            var diveNames: String = ""
            var diveScores: String = ""
            for dive in 0..<diver.diverEntries.dives.count {
                if dive != diver.diverEntries.dives.count - 1 {
                    diveNames = diveNames + "\"" + diver.diverEntries.dives[dive] + "\","
                    diveScores = diveScores + String(format: "%.2f", diver.dives[dive].roundScore) + ","
                }
                else {
                    diveNames = diveNames + "\"" + diver.diverEntries.dives[dive] + "\""
                    diveScores = diveScores + String(format: "%.2f", diver.dives[dive].roundScore)
                }
            }
            let diversCode: String = "{\"dives\":[\(diveNames)],\"diveScores\":[\(diveScores)],\"level\":\(diver.diverEntries.level),\"name\":\"\(diver.diverEntries.name)\",\"eventScore\":\(String(format: "%.2f", diver.diverEntries.totalScore ?? 0))}"
            if diver == tempDiverList[tempDiverList.count - 1] {
                allDiversCode = allDiversCode + diversCode
            }
            else {
                allDiversCode = allDiversCode + diversCode + ","
            }
        }
        allDiversCode = allDiversCode + "],\"team\":\"\(team)\"}"

        return allDiversCode
    }
}

struct TeamSelevtorView_Previews: PreviewProvider {
    static var previews: some View {
        TeamSelevtorView(diverList: [divers(dives: [], diverEntries: diverEntry(dives: [], level: 0, name: ""))])
    }
}
