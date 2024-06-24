//
//  BestDiveInfoView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/2/23.
//

import SwiftUI

struct BestDiveInfoView: View {
    
    @State var entryList: [divers] //list of diver entries
    @State var name: String //dive's name
    @State var position: String //dive's position
    @State var degreeOfDiff: Double //dive's degree of difficulty
    
    var body: some View {
            VStack(alignment: .leading) {
                Text("degree of difficulty: \(String(format: "%.1f", degreeOfDiff))")
                    .padding(.horizontal)
                //list of each dive dived with the selected name
                List {
                    ForEach(entryList, id: \.date) { entry in
                        if entry.finished == true {
                            ForEach(entry.dives, id: \.hashValue) { dive in
                                if dive.name == name && dive.position == position {
                                    VStack(alignment: .center) {
                                        Text("\(entry.date!.formatted(date: .abbreviated, time: .omitted))-\(entry.location ?? "")-\(entry.diverEntries.level == 0 ? "Exhibition" : entry.diverEntries.level == 1 ? "Junior Varsity" : "Varsity")")
                                        HStack {
                                            ForEach(dive.score, id: \.hashValue) { score in
                                                Text("\(String(format: "%.1f", score.score))")
                                                    .padding(.horizontal)
                                            }
                                            Spacer()
                                            Text("Score: \(String(format: "%.1f", dive.roundScore))")
                                                .font(.body.bold())
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        .navigationTitle(name + (position))
    }
}

struct BestDiveInfoView_Previews: PreviewProvider {
    static var previews: some View {
        BestDiveInfoView(entryList: [divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 1, index: 0), scores(score: 1, index: 1), scores(score: 1, index: 2)], position: "position", roundScore: 3.3)], diverEntries: diverEntry(dives: [], level: 0, name: "Name"), date: Date(), location: "location", finished: true)], name: "diveName", position: "position", degreeOfDiff: 1.1)
    }
}
