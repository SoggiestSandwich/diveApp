//
//  diverInfoView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/14/23.
//

import SwiftUI

struct diverInfoView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @FetchRequest(entity: Dive.entity(), sortDescriptors: []) var fetchedDives: FetchedResults<Dive>
    @FetchRequest(entity: Position.entity(), sortDescriptors: []) var fetchedPositions: FetchedResults<Position>
    @FetchRequest(entity: WithPosition.entity(), sortDescriptors: []) var fetchedWithPositions: FetchedResults<WithPosition>
    
    @Binding var diverList: divers
    @State private var dOfTheWeekError: String = ""
    @State private var catCountError: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Dismiss")
                }
                .padding()
            }
            Text(diverList.diverEntries.name)
                .font(.title.bold())
                .padding(.horizontal)
            Text(diverList.diverEntries.team!)
                .font(.title)
                .padding(.horizontal)
            Text(diverList.diverEntries.level == 0 ? "Exhibition" : diverList.diverEntries.level == 1 ? "Junior Varsity" : "Varsity")
                .font(.title)
                .padding(.horizontal)
            
            List {
                ForEach(diverList.dives, id: \.hashValue) { dive in
                    HStack {
                        Text("\(dive.name), \(dive.position)")
                        Text("(\(String(dive.degreeOfDiff)))")
                    }
                }
            }
            List {
                //list of reasons the entry is invalid
                if dOfTheWeekError != "" {
                    Text(dOfTheWeekError)
                        .foregroundColor(.red)
                }
                if catCountError != "" {
                    Text(catCountError)
                        .foregroundColor(.red)
                }
            }
        }
        .onAppear {
                if diverList.dives.isEmpty {
                    for dive in diverList.diverEntries.dives {
                        var name: String = ""
                        var positionId: Int64 = -1
                        var positionName: String = ""
                        var dOD: Double = 0
                        var numberStr = dive
                        numberStr.remove(at: numberStr.index(before: numberStr.endIndex))
                        let number = Int(numberStr) ?? 0
                        var letter = dive
                        //remove numbers from letter
                        while letter.count > 1 {
                            letter.remove(at: letter.startIndex)
                        }
                        
                        
                        //convert dive num and code to data
                        for fetchedDive in fetchedDives {
                            if fetchedDive.diveNbr == number {
                                name = fetchedDive.diveName ?? ""
                            }
                        }
                        for fetchedPosition in fetchedPositions {
                            if fetchedPosition.positionCode == letter.uppercased() {
                                positionId = fetchedPosition.positionId
                                positionName = fetchedPosition.positionName ?? ""
                            }
                        }
                        for fetchedWithPosition in fetchedWithPositions {
                            if fetchedWithPosition.positionId == positionId && fetchedWithPosition.diveNbr == number {
                                dOD = fetchedWithPosition.degreeOfDifficulty
                            }
                        }
                        
                        let newDive = dives(name: name, degreeOfDiff: dOD, score: [], position: positionName, roundScore: 0)
                        diverList.dives.append(newDive)
                    }
                }
            findErrors()
        }
    }
    func findErrors() {
        var skipFirstDive = true
        var uniqueCategories: [Int] = []
        var uniqueCategoryCount: Int = 0
            if diverList.dives.count == 6 {
                //check for dive of the week
                var tempDiveCode = diverList.diverEntries.dives[0]
                tempDiveCode.removeLast()
                if findDiveOfTheWeek().contains(Int(tempDiveCode)!) {
                    dOfTheWeekError = ""
                }
                else {
                    //DQ
                    dOfTheWeekError = "Does not have the dive of the week in the first dive slot"
                }
                if !skipFirstDive {
                    for dive in diverList.diverEntries.dives {
                        var tempDiveCode = dive
                        tempDiveCode.removeLast()
                        if Int(tempDiveCode)! < 200 {
                            if uniqueCategories.contains(1) {
                                uniqueCategoryCount += 1
                            }
                            uniqueCategories.append(1)
                        }
                        else if Int(tempDiveCode)! < 300 {
                            if uniqueCategories.contains(2) {
                                uniqueCategoryCount += 1
                            }
                            uniqueCategories.append(2)
                        }
                        else if Int(tempDiveCode)! < 400 {
                            if uniqueCategories.contains(3) {
                                uniqueCategoryCount += 1
                            }
                            uniqueCategories.append(3)
                        }
                        else if Int(tempDiveCode)! < 500 {
                            if uniqueCategories.contains(4) {
                                uniqueCategoryCount += 1
                            }
                            uniqueCategories.append(4)
                        }
                        else if Int(tempDiveCode)! < 6000 {
                            if uniqueCategories.contains(5) {
                                uniqueCategoryCount += 1
                            }
                            uniqueCategories.append(5)
                        }
                    }
                    if uniqueCategoryCount >= 4 {
                        catCountError = ""
                    }
                    else {
                        //DQ for not having 4 categories
                        catCountError = "Only has \(uniqueCategoryCount) groups out of at least 4"
                    }
                }
            }
            else if diverList.dives.count == 11 {
                
            }
            skipFirstDive = false
    }
    func findDiveOfTheWeek() -> ClosedRange<Int> {
        var tempDate = Date()
        var dateComponents = DateComponents()
        dateComponents.month = 0
        dateComponents.day = -10
        dateComponents.year = 0
        while tempDate > Calendar.current.date(byAdding: dateComponents, to: tempDate)! {
            dateComponents.day = 0
            if tempDate.formatted(date: .numeric, time: .omitted) == "8/14/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "9/18/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/23/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "11/20/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/25/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/29/2024" {
                return 100...200
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "8/21/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "9/25/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/30/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "11/27/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/1/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "2/5/2024" {
                return 200...300
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "8/28/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/2/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/4/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/8/2024" {
                return 400...500
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "9/4/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/9/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/11/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/15/2024" {
                return 5000...6000
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "9/11/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/16/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/18/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/22/2024" {
                return 300...400
            }
            tempDate = Calendar.current.date(byAdding: dateComponents, to: tempDate)!
        }
        
        return 0...1
    }
}

struct diverInfoView_Previews: PreviewProvider {
    static var previews: some View {
        diverInfoView(diverList: .constant(divers(dives: [dives(name: "dive1", degreeOfDiff: 1, score: [], position: "position", roundScore: 0), dives(name: "dive2", degreeOfDiff: 1, score: [], position: "position", roundScore: 0), dives(name: "dive3", degreeOfDiff: 1, score: [], position: "position", roundScore: 0), dives(name: "dive4", degreeOfDiff: 1, score: [], position: "position", roundScore: 0), dives(name: "dive5", degreeOfDiff: 1, score: [], position: "position", roundScore: 0), dives(name: "dive6", degreeOfDiff: 1, score: [], position: "position", roundScore: 0)], diverEntries: diverEntry(dives: ["code", "code", "code", "code", "code", "code"], level: 0, name: "name", team: "Team"))))
    }
}
