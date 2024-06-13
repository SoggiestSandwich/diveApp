//
//  TeamSelevtorView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/20/23.
//

import SwiftUI
import Gzip


struct TeamSelevtorView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var diverList: [divers]
    
    @State var teamList: [String] = []
    
    var body: some View {
        NavigationStack {
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Dismiss")
            }
            .padding()
                List {
                    ForEach(teamList, id: \.hashValue) { team in
                        NavigationLink(destination: ResultsQRView(team: team, url: createQRDataString(team: team))) {
                            Text(team)
                        }
                    }
                }
                .navigationTitle("Select Team")
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
    }
    //
    //score(individual)?, skip?
    func createQRDataString(team: String) -> String {
        var coachList: coachEntry = coachEntry(diverEntries: [], eventDate: "", team: "", version: 0)
        var num = 0
        for diver in diverList {
            if team == diver.diverEntries.team {
                coachList.diverEntries.append(diverEntry(dives: diver.diverEntries.dives, level: diver.diverEntries.level, name: diver.diverEntries.name, dq: diver.diverEntries.dq))
                coachList.diverEntries[num].fullDivesScores = []
                var index = 0
                for dive in diver.dives {
                    index+=1
                    var tempScoreList = [0.0, 0.0, 0.0]
                    tempScoreList = []
                    for score in dive.score {
                        tempScoreList.append(score.score)
                    }
                    coachList.diverEntries[num].fullDivesScores?.append(tempScoreList)
                }
                coachList.diverEntries[num].placement = diver.placement ?? 0
                coachList.diverEntries[num].totalScore = diver.diverEntries.totalScore
                num += 1
            }
            coachList.team = team
            coachList.eventDate = Date().formatted(date: .numeric, time: .omitted)
            coachList.version = 0
        }
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(coachList)
        // json compression
        let optimizedData : Data = try! data.gzipped(level: .bestCompression)
        return optimizedData.base64EncodedString()
    }
}

struct TeamSelevtorView_Previews: PreviewProvider {
    static var previews: some View {
        TeamSelevtorView(diverList: [divers(dives: [], diverEntries: diverEntry(dives: [], level: 0, name: ""))])
    }
}
