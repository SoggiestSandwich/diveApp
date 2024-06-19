//
//  DiveEntryView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/24/23.
//

import SwiftUI

struct DiveEntryView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var diverStore: DiverStore
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.diveNbr)
    ]) var fetchedDives: FetchedResults<Dive>
    @FetchRequest(entity: Position.entity(), sortDescriptors: []) var fetchedPositions: FetchedResults<Position>
    @FetchRequest(entity: WithPosition.entity(), sortDescriptors: []) var fetchedWithPositions: FetchedResults<WithPosition>
    
    @State var diveSelector = false
    @State var signingSheet: Bool = false
    @State var date: Date = Date()
    @State var location: String = ""
    @State var code: String = ""
    @State var noPastDives: Bool = false
    @State var diveCountIsZero: Bool = false
    @State var errorMessage = ""
    @State var failedValidationAlert = false
    
    @State var username: String
    @State var userSchool: String
    
    @Binding var entryList: divers
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Date")
                    Spacer()
                    //make date picker
                    DatePicker("", selection: $date, displayedComponents: [.date])
                        .onChange(of: date) { _ in
                            entryList.date = date
                            diverStore.saveDivers()
                        }
                }
                .padding(.horizontal)
                .offset(y: UIScreen.main.bounds.height * 0.008)
                Divider()
                    .background(Color.black)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                    )
                HStack {
                    Text("Location")
                    Spacer()
                    TextField("Enter Location", text: $location)
                        .onChange(of: location) { _ in
                            entryList.location = location
                            diverStore.saveDivers()
                        }
                        .multilineTextAlignment(.trailing)
                }
                .offset(y: -UIScreen.main.bounds.height * 0.005)
                .padding(.vertical)
                .padding(.horizontal)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 2)
            )
            .padding(5)
            //level picker
            adaptiveStack(horizontalStack: verticalSizeClass == .regular ? false : true) {
                VStack {
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
                                    .fill(entryList.diverEntries.level == 2 ? .blue : .clear)
                                    .opacity(0.5)
                            )
                            .onTapGesture {
                                entryList.diverEntries.level = 2
                                diverStore.saveDivers()
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
                                    .fill(entryList.diverEntries.level == 1 ? .blue : .clear)
                                    .opacity(0.5)
                            )
                            .padding(-8)
                            .onTapGesture {
                                entryList.diverEntries.level = 1
                                diverStore.saveDivers()
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
                                    .fill(entryList.diverEntries.level == 0 ? .blue : .clear)
                                    .opacity(0.5)
                            )
                            .onTapGesture {
                                entryList.diverEntries.level = 0
                                diverStore.saveDivers()
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
                                    .fill(entryList.diveCount == 6 ? .blue : .clear)
                                    .opacity(0.5)
                            )
                            .padding(-4)
                            .onTapGesture {
                                entryList.diveCount = 6
                                diverStore.saveDivers()
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
                                    .fill(entryList.diveCount == 11 ? .blue : .clear)
                                    .opacity(0.5)
                            )
                            .padding(-4)
                            .onTapGesture {
                                entryList.diveCount = 11
                                diverStore.saveDivers()
                            }
                    }
                    //finish entry button
                    Button {
                        if entryList.date == nil {
                            entryList.date = Date()
                        }
                        encodeDives()
                        validateEntry()
                        diverStore.saveDivers()
                    } label: {
                        HStack {
                            Image(systemName: "signature")
                            Text("Sign and give to coach")
                                .font(.body.bold())
                        }
                        .padding()
                        .overlay(
                            Rectangle()
                                .stroke(lineWidth: 2)
                        )
                        .foregroundColor(entryList.location == "" || entryList.dives.count != entryList.diveCount || entryList.diverEntries.level > 2 || entryList.diverEntries.level < 0 || entryList.dives.count == 0 ? colorScheme == .dark ? .white : .gray : colorScheme == .dark ? .white : .black)
                        .padding()
                    }
                    .disabled(entryList.location == "" || entryList.dives.count != entryList.diveCount || entryList.diverEntries.level > 2 || entryList.diverEntries.level < 0 || entryList.dives.count == 0)
                    //add divers buttons
                    HStack {
                        Button {
                            diveSelector = true
                            diverStore.saveDivers()
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
                        Button {
                            if entryList.diveCount == 0 {
                                diveCountIsZero = true
                            }
                            else {
                                var breakLoop = false
                                for entry in diverStore.entryList {
                                    if (!entry.dives.isEmpty && entry.finished == true) && !breakLoop {
                                        addBestDives()
                                        breakLoop = true
                                    }
                                }
                                if breakLoop == false {
                                    noPastDives = true
                                }
                            }
                            diverStore.saveDivers()
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Auto-Add Best Dives")
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
                }
                //dives list
                VStack {
                    HStack {
                        Text("Your Dives")
                            .font(.title.bold())
                        Spacer()
                    }
                    .padding(.horizontal)
                    List {
                        if !entryList.dives.isEmpty {
                            ForEach(Array(zip(entryList.dives.indices, entryList.dives)), id: \.0) { index, dive in
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("\(index + 1). \(dive.code ?? "") \(dive.name), \(dive.position) ")
                                        Text("(\(String(dive.degreeOfDiff)))")
                                    }
                                    if entryList.diveCount == 11 {
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
                                                    entryList.dives[index].volentary = false
                                                }
                                                else {
                                                    entryList.dives[index].volentary = true
                                                }
                                            }
                                    }
                                }
                            }
                            .onDelete(perform: deleteDive)
                            .onMove { (indexSet, index) in
                                self.entryList.dives.move(fromOffsets: indexSet, toOffset: index)
                                diverStore.saveDivers()
                            }
                        }
                        else {
                            Text("No dives added")
                        }
                    }
                    .environment(\.editMode, .constant(.active))
                    .padding(.horizontal)
                    if !entryList.dives.isEmpty {
                        Text("Based on your past scores:\nYour predicted score for this set of dives is \(String(format: "%.2f", predictedScore())) points\nThe best set of dives would score a predicted \(String(format: "%.2f", BestScore())) points")
                            .font(.caption)
                        Button {
                            while !entryList.dives.isEmpty {
                                entryList.dives.removeFirst()
                            }
                            diverStore.saveDivers()
                        } label: {
                            Text("Reset Dives")
                        }
                    }
                }
            }
            .alert("You have no past scores to add from", isPresented: $noPastDives) {
                Button("OK", role: .cancel) {}
            }
            .alert(errorMessage, isPresented: $failedValidationAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Continue") {
                    entryList.dq = true
                    signingSheet = true
                }
            } message: {
                Text("Are you sure you want to continue?")
            }
            .alert("Select a dive count to auto-add your best dives", isPresented: $diveCountIsZero) {
                Button("OK", role: .cancel) {}
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if entryList.date == nil {
                            entryList.date = Date()
                        }
                        diverStore.saveDivers()
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("Back")
                        }
                    }
                }
            }
            .navigationTitle("Dive Entry")
            .sheet(isPresented: $diveSelector) {
                SelectDivesView(entryList: entryList, diveList: $entryList.dives, favoriteList: $diverStore.favoriteList)
            }
            .sheet(isPresented: $signingSheet) {
                SigningView(entry: $entryList)
                    .onDisappear {
                        signingSheet = false
                    }
            }
            .onAppear {
                if entryList.date != nil {
                    date = entryList.date!
                }
                if entryList.location != nil {
                    location = entryList.location!
                }
                if entryList.dives.count == 6 || entryList.dives.count == 11 {
                    entryList.diveCount = entryList.dives.count
                }
            }
        }
    }
    func deleteDive(at offsets: IndexSet) {
        entryList.dives.remove(atOffsets: offsets)
        diverStore.saveDivers()
    }
    
    func encodeDives() {
        for dive in entryList.dives {
            entryList.diverEntries.dives.append(dive.code ?? "")
        }
    }
    
    func addBestDives() {
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
        uniqueDiveList = uniqueDiveList.sorted()
        while uniqueDiveList.count > entryList.diveCount ?? 0 {
            uniqueDiveList.removeLast()
        }
        for dive in uniqueDiveList {
            entryList.dives.append(dives(name: dive.name, degreeOfDiff: dive.degreeOfDifficulty, score: [], position: dive.position, roundScore: 0, code: dive.code))
        }
    }
    
    func predictedScore() -> Double {
        var average: Double = 0
        let calendar = Calendar.current
        let dateRange = calendar.date(byAdding: .weekOfMonth, value: -3, to: Date())!...Date()
        for dive in entryList.dives {
            for entry in diverStore.entryList {
                if entry.finished == true && dateRange.contains(entry.date!) {
                    for entryDive in entry.dives {
                        if dive.name == entryDive.name && dive.position == entryDive.position {
                            average += entryDive.roundScore
                        }
                    }
                }
            }
        }
        return average
    }
    
    func BestScore() -> Double {
        var average: Double = 0
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
        uniqueDiveList = uniqueDiveList.sorted()
        while uniqueDiveList.count > entryList.diveCount ?? 0 {
            uniqueDiveList.removeLast()
        }
        for dive in uniqueDiveList {
            average += dive.average
        }
        return average
    }
    
    func validateEntry() {
        errorMessage = ""
        if entryList.diveCount == 6 {
            var dOW: Bool = false
            //check for dive of the week
            if findDiveOfTheWeek() == "Forward" {
                var diveNum = entryList.dives[0].code!
                diveNum.removeLast()
                if Int(diveNum)! > 100 && Int(diveNum)! < 200 {
                    dOW = true
                    if entryList.dives[0].degreeOfDiff > 1.8 {
                        entryList.dives[0].degreeOfDiff = 1.8
                    }
                }
                else {
                    errorMessage += "The dive of the week is not the first dive in your entry. The dive of the week is \(findDiveOfTheWeek())"
                }
            }
            else if findDiveOfTheWeek() == "Back" {
                var diveNum = entryList.dives[0].code!
                diveNum.removeLast()
                if Int(diveNum)! > 200 && Int(diveNum)! < 300 {
                    dOW = true
                    if entryList.dives[0].degreeOfDiff > 1.8 {
                        entryList.dives[0].degreeOfDiff = 1.8
                    }
                }
                else {
                    errorMessage += "The dive of the week is not the first dive in your entry. The dive of the week is \(findDiveOfTheWeek())"
                }
            }
            else if findDiveOfTheWeek() == "Inward" {
                var diveNum = entryList.dives[0].code!
                diveNum.removeLast()
                if Int(diveNum)! > 400 && Int(diveNum)! < 500 {
                    dOW = true
                    if entryList.dives[0].degreeOfDiff > 1.8 {
                        entryList.dives[0].degreeOfDiff = 1.8
                    }
                }
                else {
                    errorMessage += "The dive of the week is not the first dive in your entry. The dive of the week is \(findDiveOfTheWeek())"
                }
            }
            else if findDiveOfTheWeek() == "Twisting" {
                var diveNum = entryList.dives[0].code!
                diveNum.removeLast()
                if Int(diveNum)! > 5000 && Int(diveNum)! < 6000 {
                    dOW = true
                    if entryList.dives[0].degreeOfDiff > 1.8 {
                        entryList.dives[0].degreeOfDiff = 1.8
                    }
                }
                else {
                    errorMessage += "The dive of the week is not the first dive in your entry. The dive of the week is \(findDiveOfTheWeek())"
                }
            }
            else if findDiveOfTheWeek() == "Reverse" {
                var diveNum = entryList.dives[0].code!
                diveNum.removeLast()
                if Int(diveNum)! > 300 && Int(diveNum)! < 400 {
                    dOW = true
                    if entryList.dives[0].degreeOfDiff > 1.8 {
                        entryList.dives[0].degreeOfDiff = 1.8
                    }
                }
                else {
                    errorMessage += "The dive of the week is not the first dive in your entry. The dive of the week is \(findDiveOfTheWeek())"
                }
            }
            
            var allCategories: [Int] = []
            var uniqueCategories: Int = 0
            var skipFirstEntry = true
            for dive in entryList.dives {
                if !skipFirstEntry {
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
        else if entryList.diveCount == 11 {
            
            var allCategories: [Int] = []
            var uniqueCategories: Int = 0
            var totalDOD: Double = 0
            for dive in entryList.dives {
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
                errorMessage += "\nThe entered volentary dives exceed a degree of difficulty of nine"
            }
            if uniqueCategories == 5 {
            }
            else {
                errorMessage += "\nThe volentary dives selected only includes \(uniqueCategories) groups"
            }
            
            for dive in entryList.dives {
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
                    errorMessage += "\nThe nonvolentary dives selected only includes \(uniqueCategories) groups"
                }
            }
            //check dive order for validation
            uniqueCategories = 0
            allCategories.removeAll()
            for dive in 0...7 {
                var diveNum = entryList.dives[dive].code!
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
                    var diveNum = entryList.dives[dive].code!
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
                for dive in 0...4 {
                    if entryList.dives[dive].volentary == true {
                        volentaryCount += 1
                    }
                }
                if volentaryCount == 2 {
                    //success
                }
                else {
                    errorMessage = "\nThere are \(volentaryCount) volentary dives out of two in the first five dives"
                }
                volentaryCount = 0
                for dive in 5...7 {
                    if entryList.dives[dive].volentary == true {
                        volentaryCount += 1
                    }
                }
                if volentaryCount == 2 {
                    //success
                }
                else {
                    errorMessage = "\nThere are \(volentaryCount) volentary dives out of two in the 5th-7th dives"
                }
                volentaryCount = 0
                for dive in 8...10 {
                    if entryList.dives[dive].volentary == true {
                        volentaryCount += 1
                    }
                }
                if volentaryCount == 1 {
                    //success
                }
                else {
                    errorMessage = "\nThere are \(volentaryCount) volentary dives out of one in the last three dives"
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
            failedValidationAlert = true
        }
        else {
            entryList.dq = false
            signingSheet = true
        }
    }
    
    func findDiveOfTheWeek() -> String {
        var tempDate = entryList.date ?? Date()
        var dateComponents = DateComponents()
        dateComponents.month = 0
        dateComponents.day = -1
        dateComponents.year = 0
        while tempDate.formatted(date: .numeric, time: .omitted) != "8/14/2023" {
            if tempDate.formatted(date: .numeric, time: .omitted) == "8/14/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "9/18/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/23/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "11/20/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/25/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/29/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "8/19/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "9/23/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "10/28/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "11/25/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "12/30/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "2/3/2025" {
                return "Forward"
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "8/21/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "9/25/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/30/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "11/27/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/1/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "2/5/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "8/26/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "9/30/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "11/4/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "12/2/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "1/6/2025" || tempDate.formatted(date: .numeric, time: .omitted) == "2/10/2025" {
                return "Back"
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "8/28/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/2/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/4/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/8/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "9/2/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "10/7/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "12/9/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "1/13/2025" {
                return "Inward"
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "9/4/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/9/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/11/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/15/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "9/9/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "10/14/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "12/16/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "1/20/2025" {
                return "Twisting"
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "9/11/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/16/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/18/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/22/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "9/16/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "10/21/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "12/23/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "1/27/2025" {
                return "Reverse"
            }
            tempDate = Calendar.current.date(byAdding: dateComponents, to: tempDate)!
        }
        
        return ""
    }
}

struct DiveEntryView_Previews: PreviewProvider {
    static var previews: some View {
        DiveEntryView(username: "Kakaw", userSchool: "", entryList: .constant(divers(dives: [], diverEntries: diverEntry(dives: [], level: 0, name: ""))))
    }
}
