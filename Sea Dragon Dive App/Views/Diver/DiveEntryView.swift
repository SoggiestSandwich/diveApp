//
//  DiveEntryView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/24/23.
//

import SwiftUI

struct DiveEntryView: View {
    @Environment(\.colorScheme) var colorScheme //detects if the device is in dark mode
    @Environment(\.verticalSizeClass) var verticalSizeClass //detects if the device is vertical
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> //used for custom back buttons
    
    @EnvironmentObject var diverStore: DiverStore //persistant diver data
    
    //tables fetched from the data base
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.diveNbr)
    ]) var fetchedDives: FetchedResults<Dive>
    @FetchRequest(entity: Position.entity(), sortDescriptors: []) var fetchedPositions: FetchedResults<Position>
    @FetchRequest(entity: WithPosition.entity(), sortDescriptors: []) var fetchedWithPositions: FetchedResults<WithPosition>
    
    @State var diveSelector = false //trigger for the dive selector
    @State var signingSheet: Bool = false //trigger for the signing sheet
    @State var date: Date = Date() //the date of the event
    @State var location: String = "" //location of the event
    //@State var code: String = "" //commented out until sure it is un-needed
    @State var noPastDives: Bool = false //trigger for alert telling the user there are no dives in history
    @State var diveCountIsZero: Bool = false //triggers the alert telling the user that a dive count has not been selected
    @State var errorMessage = "" //lists all errors found in validation
    @State var failedValidationAlert = false //triggers the alert on failed validation
    
    @Binding var entry: divers //the entry being made
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Date")
                    Spacer()
                    //date picker for setting the events date
                    DatePicker("", selection: $date, displayedComponents: [.date])
                        .onChange(of: date) { _ in
                            entry.date = date
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
                    //textfield for entering the event location
                    TextField("Enter Location", text: $location)
                        .onChange(of: location) { _ in
                            entry.location = location
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
            //makes the stack verticle if the device is vertical and horizantol if the device is horizontal
            adaptiveStack(horizontalStack: verticalSizeClass == .regular ? false : true) {
                VStack {
                    //when the text is tapped the level is set to the corresponding value
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
                                    .fill(entry.diverEntries.level == 2 ? .blue : .clear)
                                    .opacity(0.5)
                            )
                            .onTapGesture {
                                entry.diverEntries.level = 2
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
                                    .fill(entry.diverEntries.level == 1 ? .blue : .clear)
                                    .opacity(0.5)
                            )
                            .padding(-8)
                            .onTapGesture {
                                entry.diverEntries.level = 1
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
                                    .fill(entry.diverEntries.level == 0 ? .blue : .clear)
                                    .opacity(0.5)
                            )
                            .onTapGesture {
                                entry.diverEntries.level = 0
                                diverStore.saveDivers()
                            }
                    }
                    .padding(5)
                    //when the text is tapped it will set the diveCount to the corresponding number
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
                                    .fill(entry.diveCount == 6 ? .blue : .clear)
                                    .opacity(0.5)
                            )
                            .padding(-4)
                            .onTapGesture {
                                entry.diveCount = 6
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
                                    .fill(entry.diveCount == 11 ? .blue : .clear)
                                    .opacity(0.5)
                            )
                            .padding(-4)
                            .onTapGesture {
                                entry.diveCount = 11
                                diverStore.saveDivers()
                            }
                    }
                    //finish entry button and send to the signing view
                    Button {
                        if entry.date == nil {
                            entry.date = Date() //ensures a date is selected
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
                        .foregroundColor(entry.location == "" || entry.dives.count != entry.diveCount || entry.diverEntries.level > 2 || entry.diverEntries.level < 0 || entry.dives.count == 0 ? colorScheme == .dark ? .white : .gray : colorScheme == .dark ? .white : .black)
                        .padding()
                    }
                    .disabled(entry.location == "" || entry.dives.count != entry.diveCount || entry.diverEntries.level > 2 || entry.diverEntries.level < 0 || entry.dives.count == 0)
                    //add dives buttons
                    HStack {
                        Button {
                            diveSelector = true //brings up the dive selector
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
                        //automatically adds a number of dives equal to the selected number that have the highest sores
                        Button {
                            if entry.diveCount == 0 {
                                diveCountIsZero = true //alert telling the user that they have not selected a dive count
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
                                    noPastDives = true //alert telling the user they have no past dives
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
                VStack {
                    HStack {
                        Text("Your Dives")
                            .font(.title.bold())
                        Spacer()
                    }
                    .padding(.horizontal)
                    //dives list
                    List {
                        if !entry.dives.isEmpty {
                            ForEach(Array(zip(entry.dives.indices, entry.dives)), id: \.0) { index, dive in
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("\(index + 1). \(dive.code ?? "") \(dive.name), \(dive.position) ")
                                        Text("(\(String(dive.degreeOfDiff)))")
                                    }
                                    //has a volentary button if there are 11 dives that marks dives as volentary
                                    if entry.diveCount == 11 {
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
                                                //toggles the dives volentary status
                                                if dive.volentary == true {
                                                    entry.dives[index].volentary = false
                                                }
                                                else {
                                                    entry.dives[index].volentary = true
                                                }
                                            }
                                    }
                                }
                            }
                            .onDelete(perform: deleteDive)
                            .onMove { (indexSet, index) in
                                self.entry.dives.move(fromOffsets: indexSet, toOffset: index)
                                diverStore.saveDivers()
                            }
                        }
                        else {
                            Text("No dives added")
                        }
                    }
                    .environment(\.editMode, .constant(.active))
                    .padding(.horizontal)
                    //shows a predicted core based on previous scores if previous scores exist
                    if !entry.dives.isEmpty {
                        Text("Based on your past scores:\nYour predicted score for this set of dives is \(String(format: "%.2f", predictedScore())) points\nThe best set of dives would score a predicted \(String(format: "%.2f", BestScore())) points")
                            .font(.caption)
                        //removes all dives from the list
                        Button {
                            while !entry.dives.isEmpty {
                                entry.dives.removeFirst()
                            }
                            diverStore.saveDivers()
                        } label: {
                            Text("Reset Dives")
                        }
                    }
                }
            }
            //tells the user they have no past scores
            .alert("You have no past scores to add from", isPresented: $noPastDives) {
                Button("OK", role: .cancel) {}
            }
            //tells the user all the reasons that the entry is invalid
            .alert(errorMessage, isPresented: $failedValidationAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Continue") {
                    entry.dq = true
                    signingSheet = true
                }
            } message: {
                Text("Are you sure you want to continue?")
            }
            //tells the user to select a dive count
            .alert("Select a dive count to auto-add your best dives", isPresented: $diveCountIsZero) {
                Button("OK", role: .cancel) {}
            }
            .navigationBarBackButtonHidden(true) //deletes the default back button
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    //custom back button
                    Button {
                        if entry.date == nil {
                            entry.date = Date()
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
            //dive selector
            .sheet(isPresented: $diveSelector) {
                SelectDivesView(entryList: entry, diveList: $entry.dives, favoriteList: $diverStore.favoriteList)
            }
            //signing view
            .sheet(isPresented: $signingSheet) {
                SigningView(entry: $entry)
                    .onDisappear {
                        signingSheet = false
                    }
            }
            .onAppear {
                //sets the date, location and diveCount to the persistant data
                if entry.date != nil {
                    date = entry.date!
                }
                if entry.location != nil {
                    location = entry.location!
                }
                if entry.dives.count == 6 || entry.dives.count == 11 {
                    entry.diveCount = entry.dives.count
                }
            }
        }
    }
    //deletes a dive from the dive list
    func deleteDive(at offsets: IndexSet) {
        entry.dives.remove(atOffsets: offsets)
        diverStore.saveDivers()
    }
    
    //adds all of the codes from the full dives to put in the "dives" list
    func encodeDives() {
        for dive in entry.dives {
            entry.diverEntries.dives.append(dive.code ?? "")
        }
    }
    //adds a number of the highest average scoring dives to the dive list equal to dive count
    func addBestDives() {
        var uniqueDiveList: [uniqueDives] = []
        //averages the result of each dive with the same name
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
        //sorts the list of dives with their averages
        uniqueDiveList = uniqueDiveList.sorted()
        //remove the dives thathave lower scores than the top up to an amount equal to the dive count
        while uniqueDiveList.count > entry.diveCount ?? 0 {
            uniqueDiveList.removeLast()
        }
        //adds the top dives to the dive list
        for dive in uniqueDiveList {
            entry.dives.append(dives(name: dive.name, degreeOfDiff: dive.degreeOfDifficulty, score: [], position: dive.position, roundScore: 0, code: dive.code))
        }
    }
    //takes the average scores of past dives that are the same as the selected dives to predict your score
    func predictedScore() -> Double {
        var average: Double = 0
        let calendar = Calendar.current
        let dateRange = calendar.date(byAdding: .weekOfMonth, value: -3, to: Date())!...Date()
        for dive in entry.dives {
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
    
    //takes the averages of all of your past dives to calculate which set of dive count dives would give you the best score possible
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
        while uniqueDiveList.count > entry.diveCount ?? 0 {
            uniqueDiveList.removeLast()
        }
        for dive in uniqueDiveList {
            average += dive.average
        }
        return average
    }
    //validates the entry and adds all errors to the error message
    func validateEntry() {
        errorMessage = ""
        //validates six dive entries
        if entry.diveCount == 6 {
            var dOW: Bool = false
            //check for dive of the week
            //checks forward dive of the week
            if findDiveOfTheWeek() == "Forward" {
                var diveNum = entry.dives[0].code!
                diveNum.removeLast()
                if Int(diveNum)! > 100 && Int(diveNum)! < 200 {
                    dOW = true
                    if entry.dives[0].degreeOfDiff > 1.8 {
                        entry.dives[0].degreeOfDiff = 1.8
                    }
                }
                else {
                    errorMessage += "The dive of the week is not the first dive in your entry. The dive of the week is \(findDiveOfTheWeek())"
                }
            }
            //checks back dive of the week
            else if findDiveOfTheWeek() == "Back" {
                var diveNum = entry.dives[0].code!
                diveNum.removeLast()
                if Int(diveNum)! > 200 && Int(diveNum)! < 300 {
                    dOW = true
                    if entry.dives[0].degreeOfDiff > 1.8 {
                        entry.dives[0].degreeOfDiff = 1.8
                    }
                }
                else {
                    errorMessage += "The dive of the week is not the first dive in your entry. The dive of the week is \(findDiveOfTheWeek())"
                }
            }
            //checks inward dive of the week
            else if findDiveOfTheWeek() == "Inward" {
                var diveNum = entry.dives[0].code!
                diveNum.removeLast()
                if Int(diveNum)! > 400 && Int(diveNum)! < 500 {
                    dOW = true
                    if entry.dives[0].degreeOfDiff > 1.8 {
                        entry.dives[0].degreeOfDiff = 1.8
                    }
                }
                else {
                    errorMessage += "The dive of the week is not the first dive in your entry. The dive of the week is \(findDiveOfTheWeek())"
                }
            }
            //checks twisting dive of the week
            else if findDiveOfTheWeek() == "Twisting" {
                var diveNum = entry.dives[0].code!
                diveNum.removeLast()
                if Int(diveNum)! > 5000 && Int(diveNum)! < 6000 {
                    dOW = true
                    if entry.dives[0].degreeOfDiff > 1.8 {
                        entry.dives[0].degreeOfDiff = 1.8
                    }
                }
                else {
                    errorMessage += "The dive of the week is not the first dive in your entry. The dive of the week is \(findDiveOfTheWeek())"
                }
            }
            //checks reverse dive of the week
            else if findDiveOfTheWeek() == "Reverse" {
                var diveNum = entry.dives[0].code!
                diveNum.removeLast()
                if Int(diveNum)! > 300 && Int(diveNum)! < 400 {
                    dOW = true
                    if entry.dives[0].degreeOfDiff > 1.8 {
                        entry.dives[0].degreeOfDiff = 1.8
                    }
                }
                //doesn't have dive of the week as the first dive
                else {
                    errorMessage += "The dive of the week is not the first dive in your entry. The dive of the week is \(findDiveOfTheWeek())"
                }
            }
            //checks the number of different categories and the number of each category without counting the first dive
            var allCategories: [Int] = []
            var uniqueCategories: Int = 0
            var skipFirstEntry = true
            for dive in entry.dives {
                if !skipFirstEntry {
                    var diveNum = dive.code!
                    diveNum.removeLast()
                    //forward dives
                    if Int(diveNum)! > 100 && Int(diveNum)! < 200 {
                        if !allCategories.contains(1) {
                            uniqueCategories += 1
                        }
                        allCategories.append(1)
                    }
                    //back dives
                    else if Int(diveNum)! > 200 && Int(diveNum)! < 300 {
                        if !allCategories.contains(2) {
                            uniqueCategories += 1
                        }
                        allCategories.append(2)
                        
                    }
                    //reverse dives
                    else if Int(diveNum)! > 300 && Int(diveNum)! < 400 {
                        if !allCategories.contains(3) {
                            uniqueCategories += 1
                        }
                        allCategories.append(3)
                        
                    }
                    //inward dives
                    else if Int(diveNum)! > 400 && Int(diveNum)! < 500 {
                        if !allCategories.contains(4) {
                            uniqueCategories += 1
                        }
                        allCategories.append(4)
                    }
                    //twist dives
                    else if Int(diveNum)! > 1000 {
                        if !allCategories.contains(5) {
                            uniqueCategories += 1
                        }
                        allCategories.append(5)
                        
                    }
                }
                //stops skipping loop
                else {
                    skipFirstEntry = false
                }
            }
            if uniqueCategories >= 4 {
                if dOW == true {
                }
            }
            //not enough unique categories
            else {
                errorMessage += "\nThe dives selected only includes \(uniqueCategories) groups besides the dive of the week"
            }
        }
        //checks 11 dive entry
        else if entry.diveCount == 11 {
            var allCategories: [Int] = []
            var uniqueCategories: Int = 0
            var totalDOD: Double = 0
            for dive in entry.dives {
                //checks the volentary dives
                if dive.volentary == true {
                    var diveNum = dive.code!
                    diveNum.removeLast()
                    //checks volentray categories
                    //forward dives
                    if Int(diveNum)! > 100 && Int(diveNum)! < 200 {
                        if !allCategories.contains(1) {
                            uniqueCategories += 1
                        }
                        allCategories.append(1)
                        totalDOD += dive.degreeOfDiff
                    }
                    //back dives
                    else if Int(diveNum)! > 200 && Int(diveNum)! < 300 {
                        if !allCategories.contains(2) {
                            uniqueCategories += 1
                        }
                        allCategories.append(2)
                        totalDOD += dive.degreeOfDiff
                        
                    }
                    //reverse dives
                    else if Int(diveNum)! > 300 && Int(diveNum)! < 400 {
                        if !allCategories.contains(3) {
                            uniqueCategories += 1
                        }
                        allCategories.append(3)
                        totalDOD += dive.degreeOfDiff
                        
                    }
                    //inward dives
                    else if Int(diveNum)! > 400 && Int(diveNum)! < 500 {
                        if !allCategories.contains(4) {
                            uniqueCategories += 1
                        }
                        allCategories.append(4)
                        totalDOD += dive.degreeOfDiff
                    }
                    //twist dives
                    else if Int(diveNum)! > 1000 {
                        if !allCategories.contains(5) {
                            uniqueCategories += 1
                        }
                        allCategories.append(5)
                        totalDOD += dive.degreeOfDiff
                        
                    }
                }
            }
            //checks if the sum of the volentary dives degree of difficulty is too high
            if totalDOD > 9 {
                errorMessage += "\nThe entered volentary dives exceed a degree of difficulty of nine"
            }
            //checks if there is a volentary dive for all 5 category
            if uniqueCategories == 5 {
            }
            else {
                errorMessage += "\nThe volentary dives selected only includes \(uniqueCategories) groups"
            }
            for dive in entry.dives {
                //checks non-volentary dives categories
                if dive.volentary != true {
                    var diveNum = dive.code!
                    diveNum.removeLast()
                    //forward dives
                    if Int(diveNum)! > 100 && Int(diveNum)! < 200 {
                        if !allCategories.contains(1) {
                            uniqueCategories += 1
                        }
                        allCategories.append(1)
                    }
                    //back dives
                    else if Int(diveNum)! > 200 && Int(diveNum)! < 300 {
                        if !allCategories.contains(2) {
                            uniqueCategories += 1
                        }
                        allCategories.append(2)
                        
                    }
                    //reverse dives
                    else if Int(diveNum)! > 300 && Int(diveNum)! < 400 {
                        if !allCategories.contains(3) {
                            uniqueCategories += 1
                        }
                        allCategories.append(3)
                        
                    }
                    //inward dives
                    else if Int(diveNum)! > 400 && Int(diveNum)! < 500 {
                        if !allCategories.contains(4) {
                            uniqueCategories += 1
                        }
                        allCategories.append(4)
                    }
                    //twist dives
                    else if Int(diveNum)! > 1000 {
                        if !allCategories.contains(5) {
                            uniqueCategories += 1
                        }
                        allCategories.append(5)
                        
                    }
                }
                //checks that there are all 5 categories in the non-volentary dives
                if uniqueCategories == 5 {
                }
                else {
                    errorMessage += "\nThe nonvolentary dives selected only includes \(uniqueCategories) groups"
                }
            }
            //check dive order for validation
            uniqueCategories = 0
            allCategories.removeAll()
            //checks the first 8 dives
            for dive in 0...7 {
                var diveNum = entry.dives[dive].code!
                diveNum.removeLast()
                //forward dives
                if Int(diveNum)! > 100 && Int(diveNum)! < 200 {
                    if !allCategories.contains(1) {
                        uniqueCategories += 1
                    }
                    allCategories.append(1)
                }
                //back dives
                else if Int(diveNum)! > 200 && Int(diveNum)! < 300 {
                    if !allCategories.contains(2) {
                        uniqueCategories += 1
                    }
                    allCategories.append(2)
                    
                }
                //reverse dives
                else if Int(diveNum)! > 300 && Int(diveNum)! < 400 {
                    if !allCategories.contains(3) {
                        uniqueCategories += 1
                    }
                    allCategories.append(3)
                    
                }
                //inward dives
                else if Int(diveNum)! > 400 && Int(diveNum)! < 500 {
                    if !allCategories.contains(4) {
                        uniqueCategories += 1
                    }
                    allCategories.append(4)
                }
                //twist dives
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
                    var diveNum = entry.dives[dive].code!
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
                        //checks if there are 3 of the same category in the first 8 dives
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
                //dives 1-5
                for dive in 0...4 {
                    if entry.dives[dive].volentary == true {
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
                //dives 5-8
                for dive in 5...7 {
                    if entry.dives[dive].volentary == true {
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
                //dives 9-11
                for dive in 8...10 {
                    if entry.dives[dive].volentary == true {
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
            entry.dq = false
            signingSheet = true
        }
    }
    
    //finds the dive of the week by moving the date back date by day until it hits the start of a dive of the week and returns that
    func findDiveOfTheWeek() -> String {
        var tempDate = entry.date ?? Date()
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
        DiveEntryView(entry: .constant(divers(dives: [], diverEntries: diverEntry(dives: [], level: 0, name: ""))))
    }
}
