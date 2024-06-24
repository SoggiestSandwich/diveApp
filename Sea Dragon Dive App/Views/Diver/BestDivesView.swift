//
//  BestDivesView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/2/23.
//

import SwiftUI

struct BestDivesView: View {
    @EnvironmentObject var diverStore: DiverStore //persistant diver data
    
    var body: some View {
        //list of past dives with their averages
        List {
            ForEach(Array(zip(BestDives().sorted().indices, BestDives().sorted())), id: \.0) { index, dive in
                //each dive has a link to a detailed view showing all dives of that dive
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
    
    //find how many times each dive has been dived from a name and position and returns the total
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
    
    //finds the score for each dive with name and  position given to calculate the average
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
            count = 1 //prevent /0 errors
        }
        average /= count
        return average
    }
    //assembles and returns an array of the unique dives dived and finds their averages so they can be sorted
    func BestDives() -> [uniqueDives] {
        var uniqueDiveList: [uniqueDives] = []
        //looks at dives to see if it is in the unique dives list
        for entry in diverStore.entryList {
            if entry.finished == true {
                for dive in entry.dives {
                    var foundDive: Bool = false
                    for uDive in 0..<uniqueDiveList.count {
                        if dive.name == uniqueDiveList[uDive].name {
                            foundDive = true
                        }
                    }
                    //adds a new dive to the array
                    if !foundDive {
                        uniqueDiveList.append(uniqueDives(name: dive.name, average: dive.roundScore, position: dive.position, degreeOfDifficulty: dive.degreeOfDiff, timesDove: 1, code: dive.code!))
                    }
                    //recalculates the average with the repeated dive
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
