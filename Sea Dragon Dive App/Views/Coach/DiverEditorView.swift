//
//  DiverEditorView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/17/23.
//

import SwiftUI

struct DiverEditorView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var coachEntryStore: CoachEntryStore
    
    @FetchRequest(entity: Dive.entity(), sortDescriptors: []) var fetchedDives: FetchedResults<Dive>
    @FetchRequest(entity: Position.entity(), sortDescriptors: []) var fetchedPositions: FetchedResults<Position>
    @FetchRequest(entity: WithPosition.entity(), sortDescriptors: []) var fetchedWithPositions: FetchedResults<WithPosition>
    
    @State var errorMessage: String = ""
    @State var diveSelector = false
    @State var selectedCoachEntryIndex: Int
    @State var selectedDiverEntryIndex: Int
    @State var eventDate: String
    @State var signingSheet: Bool = false
    @State var diveList: [dives] = []
    @State var name: String = ""
    @State var location: String = ""
    
    var body: some View {
        VStack(alignment: .center) {
            if coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].finishedEntry == false {
                    VStack {
                        HStack {
                            Text("Name")
                            Spacer()
                            TextField("Enter Name", text: $name)
                                .onChange(of: name) { _ in
                                    coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].name = name
                                }
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(.horizontal)
                        .offset(y: UIScreen.main.bounds.height * 0.008)
                        Divider()
                            .background(Color.black)
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                            )
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 2)
                    )
                    .padding(5)
            }
            Text(coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].name)
                .font(.title.bold())
            .padding(.horizontal)
                HStack {
                    Text("Varsity")
                        .font(.caption.bold())
                        .padding(5)
                        .padding(.horizontal)
                        .background(
                            Rectangle()
                                .stroke(lineWidth: 2)
                        )
                        .overlay(
                            Rectangle()
                                .fill(coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].level == 2 ? .blue : .clear)
                                .opacity(0.5)
                        )
                        .onTapGesture {
                            coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].level = 2
                        }
                    Text("Junior Varsity")
                        .font(.caption.bold())
                        .padding(5)
                        .padding(.horizontal)
                        .background(
                            Rectangle()
                                .stroke(lineWidth: 2)
                        )
                        .overlay(
                            Rectangle()
                                .fill(coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].level == 1 ? .blue : .clear)
                                .opacity(0.5)
                        )
                        .padding(-8)
                        .onTapGesture {
                            coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].level = 1
                        }
                    Text("Exhibition")
                        .font(.caption.bold())
                        .padding(5)
                        .padding(.horizontal)
                        .background(
                            Rectangle()
                                .stroke(lineWidth: 2)
                        )
                        .overlay(
                            Rectangle()
                                .fill(coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].level == 0 ? .blue : .clear)
                                .opacity(0.5)
                        )
                        .onTapGesture {
                            coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].level = 0
                        }
                }
                .padding(5)
            //dives picker
            HStack {
                Text("Six Dives")
                    .font(.caption.bold())
                    .padding(5)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .background(
                        Rectangle()
                            .stroke(lineWidth: 2)
                    )
                    .overlay(
                        Rectangle()
                            .fill(coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].diveCount == 6 ? .blue : .clear)
                            .opacity(0.5)
                    )
                    .padding(-4)
                    .onTapGesture {
                        coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].diveCount = 6
                    }
                Text("Eleven Dives")
                    .font(.caption.bold())
                    .padding(5)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .background(
                        Rectangle()
                            .stroke(lineWidth: 2)
                    )
                    .overlay(
                        Rectangle()
                            .fill(coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].diveCount == 11 ? .blue : .clear)
                            .opacity(0.5)
                    )
                    .padding(-4)
                    .onTapGesture {
                        coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].diveCount = 11
                    }
            }
            //finish entry button
            Button {
                signingSheet = true
            } label: {
                HStack {
                    Image(systemName: "signature")
                    Text("Sign and Save changes")
                        .font(.body.bold())
                }
                .sheet(isPresented: $signingSheet) {
                    CoachEditSigningView(selectedCoachEntryIndex: $selectedCoachEntryIndex, selectedDiverEntryIndex: $selectedDiverEntryIndex)
                        .onDisappear {
                            signingSheet = false
                        }
                }
                .padding()
                .overlay(
                    Rectangle()
                        .stroke(lineWidth: 2)
                )
                .foregroundColor(coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives.count != coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].diveCount || coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].level > 2 || coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].level < 0 || coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives.count == 0 ? colorScheme == .dark ? .white : .gray : colorScheme == .dark ? .white : .black)
                .padding()
            }
            .disabled(coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives.count != coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].diveCount || coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].level > 2 || coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].level < 0 || coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives.count == 0)
            HStack {
                Button {
                    diveSelector = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Dives")
                            .font(.body.bold())
                    }
                    .padding()
                    .overlay(
                        Rectangle()
                            .stroke(lineWidth: 2)
                    )
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
            Spacer()
            //list of dives
            VStack {
                HStack {
                    Text("Your Dives")
                        .font(.title.bold())
                    Spacer()
                }
                .padding(.horizontal)
                List {
                    if !coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives.isEmpty {
                        ForEach(Array(zip(diveList.indices, diveList)), id: \.0) { index, dive in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("\(index + 1). \(dive.code ?? "") \(dive.name), \(dive.position) ")
                                    Text("(\(String(dive.degreeOfDiff)))")
                                }
                                if coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].diveCount == 11 {
                                    Text("Volentary")
                                        .font(.caption)
                                        .padding(3)
                                        .background(
                                            Rectangle()
                                                .stroke(lineWidth: 2)
                                        )
                                        .background(
                                            Rectangle()
                                                .fill(dive.volentary == true ? .blue : .clear)
                                                .opacity(0.5)
                                        )
                                        .onTapGesture {
                                            if dive.volentary == true {
                                                //diverEntry[index].volentary = false
                                            }
                                            else {
                                                //diverEntry[index].volentary = true
                                            }
                                        }
                                }
                            }
                        }
                        .onDelete(perform: deleteDive)
                        .onMove { (indexSet, index) in
                            self.coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives.move(fromOffsets: indexSet, toOffset: index)
                            diveList.move(fromOffsets: indexSet, toOffset: index)
                        }
                    }
                    else {
                        Text("No dives added")
                    }
                }
                .environment(\.editMode, .constant(.active))
                .padding(.horizontal)
                if !coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives.isEmpty {
                    Button {
                        while !coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives.isEmpty {
                            coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives.removeFirst()
                        }
                        while !diveList.isEmpty {
                            diveList.removeFirst()
                        }
                    } label: {
                        Text("Reset Dives")
                    }
                }
            }
            .sheet(isPresented: $diveSelector, onDismiss: didDismiss) {
                DiverDiveSelector(entryList: coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex], coachEntry: coachEntryStore.coachesList[selectedCoachEntryIndex], eventDate: eventDate, diveList: $diveList)
            }
        }
        .task {
            findDives()
            coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].diveCount = diveList.count
        }
    }
    func didDismiss() {
        coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].fullDives = diveList
        
        coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives.removeAll()
        
        for dive in coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].fullDives! {
            coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives.append(dive.code ?? "")
        }
        findDives()    }
    
    func deleteDive(at offsets: IndexSet) {
        coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives.remove(atOffsets: offsets)
        diveList.remove(atOffsets: offsets)
    }
    
    func findDives() {
        diveList = []
        for diveCode in coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives {
            var tempCode: String = diveCode
            tempCode.removeLast()
            for fetchedDive in fetchedDives {
                if Int(tempCode) ?? 0 == fetchedDive.diveNbr {
                    tempCode = diveCode
                    while tempCode.count != 1 {
                        tempCode.removeFirst()
                    }
                    for fetchedWithPosition in fetchedWithPositions {
                        if fetchedDive.diveNbr == fetchedWithPosition.diveNbr {
                            for fetchedPosition in fetchedPositions {
                                if tempCode.uppercased() == fetchedPosition.positionCode && fetchedPosition.positionId == fetchedWithPosition.positionId {
                                    diveList.append(dives(name: fetchedDive.diveName ?? "", degreeOfDiff: fetchedWithPosition.degreeOfDifficulty, score: [], position: fetchedPosition.positionName ?? "", roundScore: 0))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func validateEntry() {
        errorMessage = ""
        if coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].diveCount == 6 {
            var dOW: Bool = false
            //check for dive of the week
            if findDiveOfTheWeek() == "Forward" {
                var diveNum = coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives[0]
                diveNum.removeLast()
                if Int(diveNum)! > 100 && Int(diveNum)! < 200 {
                    dOW = true
//                    if entryList.dives[0].degreeOfDiff > 1.8 {
//                        entryList.dives[0].degreeOfDiff = 1.8
//                    }
                }
                else {
                    errorMessage += "The dive of the week is not the first dive in your entry. The dive of the week is \(findDiveOfTheWeek())"
                }
            }
            else if findDiveOfTheWeek() == "Back" {
                var diveNum = coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives[0]
                diveNum.removeLast()
                if Int(diveNum)! > 200 && Int(diveNum)! < 300 {
                    dOW = true
//                    if entryList.dives[0].degreeOfDiff > 1.8 {
//                        entryList.dives[0].degreeOfDiff = 1.8
//                    }
                }
                else {
                    errorMessage += "The dive of the week is not the first dive in your entry. The dive of the week is \(findDiveOfTheWeek())"
                }
            }
            else if findDiveOfTheWeek() == "Inward" {
                var diveNum = coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives[0]
                diveNum.removeLast()
                if Int(diveNum)! > 400 && Int(diveNum)! < 500 {
                    dOW = true
//                    if entryList.dives[0].degreeOfDiff > 1.8 {
//                        entryList.dives[0].degreeOfDiff = 1.8
//                    }
                }
                else {
                    errorMessage += "The dive of the week is not the first dive in your entry. The dive of the week is \(findDiveOfTheWeek())"
                }
            }
            else if findDiveOfTheWeek() == "Twisting" {
                var diveNum = coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives[0]
                diveNum.removeLast()
                if Int(diveNum)! > 5000 && Int(diveNum)! < 6000 {
                    dOW = true
//                    if entryList.dives[0].degreeOfDiff > 1.8 {
//                        entryList.dives[0].degreeOfDiff = 1.8
//                    }
                }
                else {
                    errorMessage += "The dive of the week is not the first dive in your entry. The dive of the week is \(findDiveOfTheWeek())"
                }
            }
            else if findDiveOfTheWeek() == "Reverse" {
                var diveNum = coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives[0]
                diveNum.removeLast()
                if Int(diveNum)! > 300 && Int(diveNum)! < 400 {
                    dOW = true
//                    if entryList.dives[0].degreeOfDiff > 1.8 {
//                        entryList.dives[0].degreeOfDiff = 1.8
//                    }
                }
                else {
                    errorMessage += "The dive of the week is not the first dive in your entry. The dive of the week is \(findDiveOfTheWeek())"
                }
            }
            
            var allCategories: [Int] = []
            var uniqueCategories: Int = 0
            var skipFirstEntry = true
            for dive in coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives {
                if !skipFirstEntry {
                    var diveNum = dive
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
                else {
                    skipFirstEntry = false
                }
            }
            if uniqueCategories >= 4 {
                if dOW == true {
                }
            }
            else {
                errorMessage += "\nThe dives selected only includes \(uniqueCategories) groups besides the dive of the week"
            }
        }
        else if coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].diveCount == 11 {
            
            var allCategories: [Int] = []
            var uniqueCategories: Int = 0
            var totalDOD: Double = 0
            for dive in 0..<coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives.count {
                //if diverEntry.volentary?[dive] == true {
                var diveNum = coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives[dive]
                    diveNum.removeLast()
                    if Int(diveNum)! > 100 && Int(diveNum)! < 200 {
                        if !allCategories.contains(1) {
                            uniqueCategories += 1
                        }
                        allCategories.append(1)
                        for fetchedWithPosition in fetchedWithPositions {
                            if Int(diveNum)! == fetchedWithPosition.diveNbr {
                                var diveLetter = coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives[dive]
                                while diveLetter.count != 1 {
                                    diveLetter.removeFirst()
                                }
                                for fetchedPosition in fetchedPositions {
                                    if fetchedPosition.positionCode == diveLetter {
                                        totalDOD += fetchedWithPosition.degreeOfDifficulty
                                    }
                                }
                            }
                        }
                    }
                    else if Int(diveNum)! > 200 && Int(diveNum)! < 300 {
                        if !allCategories.contains(2) {
                            uniqueCategories += 1
                        }
                        allCategories.append(2)
                        for fetchedWithPosition in fetchedWithPositions {
                            if Int(diveNum)! == fetchedWithPosition.diveNbr {
                                var diveLetter = coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives[dive]
                                while diveLetter.count != 1 {
                                    diveLetter.removeFirst()
                                }
                                for fetchedPosition in fetchedPositions {
                                    if fetchedPosition.positionCode == diveLetter {
                                        totalDOD += fetchedWithPosition.degreeOfDifficulty
                                    }
                                }
                            }
                        }
                        
                    }
                    else if Int(diveNum)! > 300 && Int(diveNum)! < 400 {
                        if !allCategories.contains(3) {
                            uniqueCategories += 1
                        }
                        allCategories.append(3)
                        for fetchedWithPosition in fetchedWithPositions {
                            if Int(diveNum)! == fetchedWithPosition.diveNbr {
                                var diveLetter = coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives[dive]
                                while diveLetter.count != 1 {
                                    diveLetter.removeFirst()
                                }
                                for fetchedPosition in fetchedPositions {
                                    if fetchedPosition.positionCode == diveLetter {
                                        totalDOD += fetchedWithPosition.degreeOfDifficulty
                                    }
                                }
                            }
                        }
                        
                    }
                    else if Int(diveNum)! > 400 && Int(diveNum)! < 500 {
                        if !allCategories.contains(4) {
                            uniqueCategories += 1
                        }
                        allCategories.append(4)
                        for fetchedWithPosition in fetchedWithPositions {
                            if Int(diveNum)! == fetchedWithPosition.diveNbr {
                                var diveLetter = coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives[dive]
                                while diveLetter.count != 1 {
                                    diveLetter.removeFirst()
                                }
                                for fetchedPosition in fetchedPositions {
                                    if fetchedPosition.positionCode == diveLetter {
                                        totalDOD += fetchedWithPosition.degreeOfDifficulty
                                    }
                                }
                            }
                        }
                    }
                    else if Int(diveNum)! > 1000 {
                        if !allCategories.contains(5) {
                            uniqueCategories += 1
                        }
                        allCategories.append(5)
                        for fetchedWithPosition in fetchedWithPositions {
                            if Int(diveNum)! == fetchedWithPosition.diveNbr {
                                var diveLetter = coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives[dive]
                                while diveLetter.count != 1 {
                                    diveLetter.removeFirst()
                                }
                                for fetchedPosition in fetchedPositions {
                                    if fetchedPosition.positionCode == diveLetter {
                                        totalDOD += fetchedWithPosition.degreeOfDifficulty
                                    }
                                }
                            }
                        }
                        
                    }
                //}
            }
            if totalDOD > 9 {
                errorMessage += "\nThe entered volentary dives exceed a degree of difficulty of nine"
            }
            if uniqueCategories == 5 {
            }
            else {
                errorMessage += "\nThe volentary dives selected only includes \(uniqueCategories) groups"
            }
            
            for dive in 0..<coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives.count {
                //if diverEntry.volentary?[dive] != true {
                    var diveNum = coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives[dive]
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
                //}
                if uniqueCategories == 5 {
                }
                else {
                    errorMessage += "\nThe optional dives selected only includes \(uniqueCategories) groups"
                }
            }
            //check dive order for validation
            uniqueCategories = 0
            allCategories.removeAll()
            for dive in 0...7 {
                var diveNum = coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives[dive]
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
                    var diveNum = coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dives[dive]
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
                            errorMessage += "\nFirst 8 dives include three dives from the same group"
                            breakLoop = true
                        }
                    }
                }
                //check the volentary to optional ratio
                var volentaryCount = 0
                for _ in 0...4 {
                    //if diverEntry.volentary?[dive] == true {
                        volentaryCount += 1
                    //}
                }
                if volentaryCount == 2 {
                    //success
                }
                else {
                    errorMessage = "\nThere are \(volentaryCount) volentary dives out of two in the first five dives"
                }
                volentaryCount = 0
                for _ in 5...7 {
                    //if diverEntry.volentary?[dive] == true {
                        volentaryCount += 1
                    //}
                }
                if volentaryCount == 2 {
                    //success
                }
                else {
                    errorMessage = "\nThere are \(volentaryCount) volentary dives out of two in the 5th-7th dives"
                }
                volentaryCount = 0
                for _ in 8...10 {
                    //if diverEntry.volentary?[dive] == true {
                        volentaryCount += 1
                    //}
                }
                if volentaryCount == 1 {
                    //success
                }
                else {
                    errorMessage = "\nThere are \(volentaryCount) volentary dives out of two in the last three dives"
                }
            }
            else {
                errorMessage += "\nFirst 8 dives do not include all groups"
            }
        }
        else {
            errorMessage = "This should be literally impossible to see because the button is disabled unless a diveCount is chosen"
        }
        if errorMessage != "" {
            //failedValidationAlert = true
        }
        else {
            coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].dq = false
            signingSheet = true
        }
    }
    func findDiveOfTheWeek() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        var tempDate = dateFormatter.date(from: eventDate)
        print(tempDate!.formatted(date: .numeric, time: .omitted))
        var dateComponents = DateComponents()
        dateComponents.month = 0
        dateComponents.day = -1
        dateComponents.year = 0
        while tempDate!.formatted(date: .numeric, time: .omitted) != "8/14/2023" {
            if tempDate!.formatted(date: .numeric, time: .omitted) == "8/14/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "9/18/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/23/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "11/20/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/25/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/29/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "8/19/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "9/23/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/28/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "11/25/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/30/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "2/3/2025" {
                return "Forward"
            }
            else if tempDate!.formatted(date: .numeric, time: .omitted) == "8/21/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "9/25/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/30/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "11/27/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/1/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "2/5/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "8/26/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "9/30/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "11/4/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/2/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/6/2025" || tempDate!.formatted(date: .numeric, time: .omitted) == "2/10/2025" {
                return "Back"
            }
            else if tempDate!.formatted(date: .numeric, time: .omitted) == "8/28/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/2/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/4/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/8/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "9/2/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/7/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/9/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/13/2025" {
                return "Inward"
            }
            else if tempDate!.formatted(date: .numeric, time: .omitted) == "9/4/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/9/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/11/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/15/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "9/9/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/14/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/16/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/20/2025" {
                return "Twisting"
            }
            else if tempDate!.formatted(date: .numeric, time: .omitted) == "9/11/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/16/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/18/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/22/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "9/16/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/21/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/23/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/27/2025" {
                return "Reverse"
            }
            tempDate = Calendar.current.date(byAdding: dateComponents, to: tempDate!)!
        }
        
        return ""
    }
}
//    var dives: [String]
struct DiverEditorView_Previews: PreviewProvider {
    static var previews: some View {
        DiverEditorView(selectedCoachEntryIndex: 0, selectedDiverEntryIndex: 0, eventDate: "")
            .environmentObject(CoachEntryStore())
    }
}
