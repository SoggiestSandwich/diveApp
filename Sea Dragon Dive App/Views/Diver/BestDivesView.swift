//
//  BestDivesView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/2/23.
//

import SwiftUI

struct BestDivesView: View {
    @EnvironmentObject var diverStore: DiverStore
    
    var body: some View {
        List {
            ForEach(Array(zip(BestDives().sorted().indices, BestDives().sorted())), id: \.0) { index, dive in
                NavigationLink(destination: BestDiveInfoView(entryList: diverStore.entryList, name: dive.name, position: dive.position, degreeOfDiff: dive.degreeOfDifficulty)) {
                    HStack {
                        Text("\(index + 1)")
                            .padding(8)
                            .background(
                                Circle()
                                    .stroke(lineWidth: 2)
                            )
                        VStack(alignment: .leading) {
                            Text("\(dive.name), \(dive.position) (\(String(format: "%.1f", dive.degreeOfDifficulty)))")
                            Text("Average Score: \(String(format: "%.1f", findAverage(name: dive.name, position: dive.position)))")
                            Text("Dived \(findDivedTimes(name: dive.name, position: dive.position)) Times")
                        }
                    }
                }
            }
        }
        .navigationTitle("My Best Dives")
    }
    
    func findDivedTimes(name: String, position: String) -> Int {
        var count = 0
        for entry in diverStore.entryList {
            if entry.finished == true {
                for dive in entry.dives {
                    if dive.name == name && dive.position == position {
                        count+=1
                    }
                }
            }
        }
        return count
    }
    
    func findAverage(name: String, position: String) -> Double {
        var average: Double = 0
        var count: Double = 0
        let calendar = Calendar.current
        let dateRange = calendar.date(byAdding: .weekOfMonth, value: -3, to: Date())!...Date()
        for entry in diverStore.entryList {
            if entry.finished == true && dateRange.contains(entry.date!) {
                for dive in entry.dives {
                    if dive.name == name && dive.position == position {
                        average += dive.roundScore
                        count += 1
                    }
                }
            }
        }
        if count == 0 {
            count = 1
        }
        average /= count
        return average
    }
    func BestDives() -> [uniqueDives] {
        var uniqueDiveList: [uniqueDives] = []
        for entry in diverStore.entryList {
            if entry.finished == true {
                for dive in entry.dives {
                    var foundDive: Bool = false
                    for uDive in 0..<uniqueDiveList.count {
                        if dive.name == uniqueDiveList[uDive].name {
                            foundDive = true
                        }
                    }
                    if !foundDive {
                        uniqueDiveList.append(uniqueDives(name: dive.name, average: dive.roundScore, position: dive.position, degreeOfDifficulty: dive.degreeOfDiff, timesDove: 1, code: dive.code!))
                    }
                    else {
                        for uDive in 0..<uniqueDiveList.count {
                            uniqueDiveList[uDive].average *= uniqueDiveList[uDive].timesDove
                            uniqueDiveList[uDive].average += dive.roundScore
                            uniqueDiveList[uDive].timesDove += 1
                            uniqueDiveList[uDive].average /= uniqueDiveList[uDive].timesDove
                        }
                    }
                }
            }
        }
        return uniqueDiveList
    }
}

struct BestDivesView_Previews: PreviewProvider {
    static var previews: some View {
        BestDivesView()
            .environmentObject(DiverStore())
    }
}
