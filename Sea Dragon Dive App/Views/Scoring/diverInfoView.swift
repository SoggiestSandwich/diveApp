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
    @State private var volDiveGreaterNineError: String = ""
    @State private var volDiveCategoryError: String = ""
    @State private var nonVolDiveCategoryError: String = ""
    @State private var catCountFirstEigtError: String = ""
    @State private var repeatDiveInFirstEightError: String = ""
    @State private var twoVolZeroFourError: String = ""
    @State private var twoVolFiveSevenError: String = ""
    @State private var oneVolEightTenError: String = ""
    @State private var notEnoughDivesError: String = ""
    
    @State var diveCount: Int
    
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
                if volDiveGreaterNineError != "" {
                    Text(volDiveGreaterNineError)
                        .foregroundColor(.red)
                }
                if volDiveCategoryError != "" {
                    Text(volDiveCategoryError)
                        .foregroundColor(.red)
                }
                if catCountFirstEigtError != "" {
                    Text(catCountFirstEigtError)
                        .foregroundColor(.red)
                }
                if repeatDiveInFirstEightError != "" {
                    Text(repeatDiveInFirstEightError)
                        .foregroundColor(.red)
                }
                if twoVolZeroFourError != "" {
                    Text(twoVolZeroFourError)
                        .foregroundColor(.red)
                }
                if twoVolFiveSevenError != "" {
                    Text(twoVolFiveSevenError)
                        .foregroundColor(.red)
                }
                if oneVolEightTenError != "" {
                    Text(oneVolEightTenError)
                        .foregroundColor(.red)
                }
                if nonVolDiveCategoryError != "" {
                    Text(nonVolDiveCategoryError)
                        .foregroundColor(.red)
                }
                if notEnoughDivesError != "" {
                    Text(notEnoughDivesError)
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
        if diverList.diverEntries.dives.count < diveCount {
            notEnoughDivesError = "Has \(diverList.diverEntries.dives.count) out of \(diveCount) dives"
        }
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
                var allCategories: [Int] = []
                var uniqueCategories: Int = 0
                var totalDOD: Double = 0
                for dive in diverList.diverEntries.fullDives! {
                    if dive.volentary == true {
                        var diveNum = dive.code!
                        diveNum.removeLast()
                        if Int(diveNum)! > 100 && Int(diveNum)! < 200 {
                            if !allCategories.contains(1) {
                                uniqueCategories += 1
                            }
                            allCategories.append(1)
                            totalDOD += dive.degreeOfDiff
                        }
                        else if Int(diveNum)! > 200 && Int(diveNum)! < 300 {
                            if !allCategories.contains(2) {
                                uniqueCategories += 1
                            }
                            allCategories.append(2)
                            totalDOD += dive.degreeOfDiff
                            
                        }
                        else if Int(diveNum)! > 300 && Int(diveNum)! < 400 {
                            if !allCategories.contains(3) {
                                uniqueCategories += 1
                            }
                            allCategories.append(3)
                            totalDOD += dive.degreeOfDiff
                            
                        }
                        else if Int(diveNum)! > 400 && Int(diveNum)! < 500 {
                            if !allCategories.contains(4) {
                                uniqueCategories += 1
                            }
                            allCategories.append(4)
                            totalDOD += dive.degreeOfDiff
                        }
                        else if Int(diveNum)! > 1000 {
                            if !allCategories.contains(5) {
                                uniqueCategories += 1
                            }
                            allCategories.append(5)
                            totalDOD += dive.degreeOfDiff
                            
                        }
                    }
                }
                if totalDOD > 9 {
                    volDiveGreaterNineError = "Volentary dives degree of difficulty is greater than 9"
                }
                if uniqueCategories == 5 {
                }
                else {
                    volDiveCategoryError = "Only has \(uniqueCategories) out of 5 categories in volentary dives"
                }
                
                for dive in diverList.diverEntries.fullDives! {
                    if dive.volentary != true {
                        var diveNum = dive.code!
                        diveNum.removeLast()
                        if Int(diveNum)! > 100 && Int(diveNum)! < 200 {
                            if !allCategories.contains(1) {
                                uniqueCategories += 1
                            }
                            allCategories.append(1)
                        }
                        else if Int(diveNum)! > 200 && Int(diveNum)! < 300 {
                            if !allCategories.contains(2) {
                                uniqueCategories += 1
                            }
                            allCategories.append(2)
                            
                        }
                        else if Int(diveNum)! > 300 && Int(diveNum)! < 400 {
                            if !allCategories.contains(3) {
                                uniqueCategories += 1
                            }
                            allCategories.append(3)
                            
                        }
                        else if Int(diveNum)! > 400 && Int(diveNum)! < 500 {
                            if !allCategories.contains(4) {
                                uniqueCategories += 1
                            }
                            allCategories.append(4)
                        }
                        else if Int(diveNum)! > 1000 {
                            if !allCategories.contains(5) {
                                uniqueCategories += 1
                            }
                            allCategories.append(5)
                            
                        }
                    }
                    if uniqueCategories == 5 {
                    }
                    else {
                        nonVolDiveCategoryError = "Only has \(uniqueCategories) out of 5 unique categories in non-volentary dive"
                    }
                }
                //check dive order for validation
                uniqueCategories = 0
                allCategories.removeAll()
                for dive in 0...7 {
                    var diveNum = diverList.diverEntries.dives[dive]
                    diveNum.removeLast()
                    if Int(diveNum)! > 100 && Int(diveNum)! < 200 {
                        if !allCategories.contains(1) {
                            uniqueCategories += 1
                        }
                        allCategories.append(1)
                    }
                    else if Int(diveNum)! > 200 && Int(diveNum)! < 300 {
                        if !allCategories.contains(2) {
                            uniqueCategories += 1
                        }
                        allCategories.append(2)
                        
                    }
                    else if Int(diveNum)! > 300 && Int(diveNum)! < 400 {
                        if !allCategories.contains(3) {
                            uniqueCategories += 1
                        }
                        allCategories.append(3)
                        
                    }
                    else if Int(diveNum)! > 400 && Int(diveNum)! < 500 {
                        if !allCategories.contains(4) {
                            uniqueCategories += 1
                        }
                        allCategories.append(4)
                    }
                    else if Int(diveNum)! > 1000 {
                        if !allCategories.contains(5) {
                            uniqueCategories += 1
                        }
                        allCategories.append(5)
                        
                    }
                }
                if uniqueCategories == 5 {
                    //check for more than 3 or more repeats in the first 8 dives
                    allCategories.removeAll()
                    for dive in 0...7 {
                        var diveNum = diverList.diverEntries.dives[dive]
                        diveNum.removeLast()
                        if Int(diveNum)! > 100 && Int(diveNum)! < 200 {
                            allCategories.append(1)
                        }
                        else if Int(diveNum)! > 200 && Int(diveNum)! < 300 {
                            allCategories.append(2)
                            
                        }
                        else if Int(diveNum)! > 300 && Int(diveNum)! < 400 {
                            allCategories.append(3)
                            
                        }
                        else if Int(diveNum)! > 400 && Int(diveNum)! < 500 {
                            allCategories.append(4)
                        }
                        else if Int(diveNum)! > 1000 {
                            allCategories.append(5)
                        }
                    }
                    var breakLoop = false
                    for num in 1...5 {
                        if !breakLoop {
                            var count = 0
                            for cat in allCategories {
                                if cat == num {
                                    count += 1
                                }
                            }
                            if count < 3 {
                                
                            }
                            else {
                                repeatDiveInFirstEightError = "A category is repeated three time or more in the first 8 dives"
                                breakLoop = true
                            }
                        }
                    }
                    //check the volentary to optional ratio
                    var volentaryCount = 0
                    for dive in 0...4 {
                        if diverList.diverEntries.fullDives![dive].volentary == true {
                            volentaryCount += 1
                        }
                    }
                    if volentaryCount == 2 {
                        //success
                    }
                    else {
                        twoVolZeroFourError = "Has \(volentaryCount) out of 2 volentary dives in the first 5 dives"
                    }
                    volentaryCount = 0
                    for dive in 5...7 {
                        if diverList.diverEntries.fullDives![dive].volentary == true {
                            volentaryCount += 1
                        }
                    }
                    if volentaryCount == 2 {
                        //success
                    }
                    else {
                        twoVolFiveSevenError = "Has \(volentaryCount) out of 2 volentary dives in dives 5 through 8"
                    }
                    volentaryCount = 0
                    for dive in 8...10 {
                        if diverList.diverEntries.fullDives![dive].volentary == true {
                            volentaryCount += 1
                        }
                    }
                    if volentaryCount == 1 {
                        //success
                    }
                    else {
                        oneVolEightTenError = "Has \(volentaryCount) out of 2 volentary dives in dives 9 through 11"
                    }
                }
                else {
                    catCountFirstEigtError = "Does not have all 5 unique categories in the first eight dives"
                }
            }
            skipFirstDive = false
    }
    func findDiveOfTheWeek() -> ClosedRange<Int> {
        var tempDate = Date()
        var dateComponents = DateComponents()
        dateComponents.month = 0
        dateComponents.day = -1
        dateComponents.year = 0
        while tempDate.formatted(date: .numeric, time: .omitted) != "8/14/2023" {
            if tempDate.formatted(date: .numeric, time: .omitted) == "8/14/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "9/18/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/23/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "11/20/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/25/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/29/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "8/19/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "9/23/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "10/28/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "11/25/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "12/30/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "2/3/2025" {
                return 100...200
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "8/21/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "9/25/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/30/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "11/27/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/1/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "2/5/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "8/26/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "9/30/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "11/4/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "12/2/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "1/6/2025" || tempDate.formatted(date: .numeric, time: .omitted) == "2/10/2025" {
                return 200...300
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "8/28/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/2/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/4/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/8/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "9/2/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "10/7/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "12/9/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "1/13/2025" {
                return 400...500
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "9/4/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/9/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/11/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/15/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "9/9/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "10/14/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "12/16/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "1/20/2025" {
                return 5000...6000
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "9/11/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/16/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/18/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/22/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "9/16/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "10/21/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "12/23/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "1/27/2025" {
                return 200...400
            }
            tempDate = Calendar.current.date(byAdding: dateComponents, to: tempDate)!
        }
        
        return 0...1
    }
}

struct diverInfoView_Previews: PreviewProvider {
    static var previews: some View {
        diverInfoView(diverList: .constant(divers(dives: [dives(name: "dive1", degreeOfDiff: 1, score: [], position: "position", roundScore: 0), dives(name: "dive2", degreeOfDiff: 1, score: [], position: "position", roundScore: 0), dives(name: "dive3", degreeOfDiff: 1, score: [], position: "position", roundScore: 0), dives(name: "dive4", degreeOfDiff: 1, score: [], position: "position", roundScore: 0), dives(name: "dive5", degreeOfDiff: 1, score: [], position: "position", roundScore: 0), dives(name: "dive6", degreeOfDiff: 1, score: [], position: "position", roundScore: 0)], diverEntries: diverEntry(dives: ["code", "code", "code", "code", "code", "code"], level: 0, name: "name", team: "Team"))), diveCount: 6)
    }
}
