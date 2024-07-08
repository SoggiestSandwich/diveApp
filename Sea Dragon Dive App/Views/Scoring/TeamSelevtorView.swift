//
//  TeamSelevtorView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/20/23.
//

import SwiftUI
import Gzip


struct TeamSelevtorView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> //used for custom back button
    
    @State var diverList: [divers] //list of all divers in the event
    
    @State var teamList: [String] = [] //list of all team names
    
    var body: some View {
        NavigationStack {
            //dismisses the sheet
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Dismiss")
            }
            .padding()
            //list of each team with links to qr code for that team
                List {
                    ForEach(teamList, id: \.hashValue) { team in
                        NavigationLink(destination: ResultsQRView(team: team, code: createQRDataString(team: team))) {
                            Text(team)
                        }
                    }
                }
                .navigationTitle("Select Team")
            .onAppear {
                //adds all teams from the divers to the team list
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
    //create a string to be sent to the qr code
    func createQRDataString(team: String) -> String {
        var coachList: coachEntry = coachEntry(diverEntries: [], eventDate: "", team: "", version: 0)
        var num = 0
        //assembles a coach entry from the diver list
        for diver in diverList {
            if team == diver.diverEntries.team {
                coachList.diverEntries.append(diverEntry(dives: diver.diverEntries.dives, level: diver.diverEntries.level, name: diver.diverEntries.name, dq: diver.diverEntries.dq, placement: diver.placement))
                coachList.diverEntries[num].fullDivesScores = []
                var index = 0
                //adds scores from each dive to the diver in the coach entry
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
        }
        //encode from coach entry into json
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
