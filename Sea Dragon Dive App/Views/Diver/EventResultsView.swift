//
//  EventResultsView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/2/23.
//

import SwiftUI

struct EventResultsView: View {
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State var entryList: divers
    
    var body: some View {
        VStack {
            HStack {
                Text("Date: ")
                Spacer()
                Text(entryList.date!.formatted(date: .abbreviated, time: .omitted))
                    .font(.body.bold())
            }
            .padding(.horizontal)
            HStack {
                Text("Location: ")
                Spacer()
                Text(entryList.location!)
                    .font(.body.bold())
            }
            .padding(.horizontal)
            HStack {
                Text("Competition Level: ")
                Spacer()
                Text(entryList.diverEntries.level == 0 ? "Exhibition" : entryList.diverEntries.level == 1 ? "Junior Varsity" : "Varsity")
                    .font(.body.bold())
            }
            .padding(.horizontal)
            HStack {
                Text("Total Score")
                    .font(.title.bold())
                Spacer()
                Text("\(String(format: "%.2f", entryList.diverEntries.totalScore ?? 0))")
                    .font(.title2.bold())
                    .padding(.horizontal)
                VStack {
                    if entryList.placement ?? 0 <= 0 && entryList.diverEntries.level != 0 {
                        Text("DQ")
                            .bold()
                    }
                    else if entryList.diverEntries.level == 0 {
                        
                    }
                    else {
                        Image(systemName: "trophy")
                        Text(entryList.placement == 1 ? "1st Place" : entryList.placement == 2 ? "2nd Place" : entryList.placement == 3 ? "3rd Place" : "\(entryList.placement ?? 0)th Place")
                    }
                }
            }
            .padding()
            List {
                ForEach(Array(zip(entryList.dives.indices, entryList.dives)), id: \.0) { index, dive in
                    HStack {
                        Text("\(index + 1)")
                            .font(.body.bold())
                            .padding(8)
                            .background(
                                Circle()
                                    .stroke(lineWidth: 2)
                            )
                            .padding(.trailing)
                        VStack(alignment: .leading) {
                            Text("\(dive.name), \(dive.position) (\(String(format: "%.1f", dive.degreeOfDiff)))")
                                .font(.body.bold())
                            VStack {
                                HStack {
                                    /*ForEach(dive.score, id: \.hashValue) { score in
                                        Text("\(String(score.score))")
                                            .font(.body.bold())
                                            .padding(.trailing)
                                    }*/
                                    
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 50, maximum: 150)), count: verticalSizeClass == .regular ? 3 : 7)) {
                                        ForEach(dive.score, id: \.hashValue) { score in
                                            Text("\(String(score.score))")
                                                .font(.body.bold())
                                                .padding(.trailing)
                                            
                                        }
                                    }
                                    
                                    Spacer()
                                    Text("Score: \(String(format: "%.2f", dive.roundScore))")
                                        .font(.body.bold())
                                }
                            }
                        }
                    }
                    HStack {
                        Spacer()
                        Text("Running Total: \(String(format: "%.2f", findRunningTotal(index: index)))")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("Event Results")
    }
    
    func findRunningTotal(index: Int) -> Double {
        var runningTotal: Double = 0
        for num in 0..<index + 1 {
            runningTotal += entryList.dives[num].roundScore
        }
        return runningTotal
    }
}

struct EventResultsView_Previews: PreviewProvider {
    static var previews: some View {
        EventResultsView(entryList: divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 10, index: 0), scores(score: 10, index: 1), scores(score: 10, index: 2), scores(score: 10.0, index: 3), scores(score: 10.0, index: 4)], position: "Free", roundScore: 3.3), dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 10, index: 0), scores(score: 10, index: 1), scores(score: 10, index: 2)], position: "Free", roundScore: 3.3), dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 10, index: 0), scores(score: 10, index: 1), scores(score: 10, index: 2), scores(score: 10.0, index: 3), scores(score: 10.0, index: 4), scores(score: 10.0, index: 5), scores(score: 10.0, index: 6)], position: "Free", roundScore: 3.3)], diverEntries: diverEntry(dives: [], level: 0, name: "", totalScore: 0), placement: 420, date: Date(), location: "Location"))
    }
}
