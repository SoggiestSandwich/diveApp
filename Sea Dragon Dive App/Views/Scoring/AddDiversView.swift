//
//  AddDiversView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/15/23.
//

import SwiftUI
import CodeScanner

struct AddDiversView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @FetchRequest(entity: Dive.entity(), sortDescriptors: []) var fetchedDives: FetchedResults<Dive>
    @FetchRequest(entity: Position.entity(), sortDescriptors: []) var fetchedPositions: FetchedResults<Position>
    @FetchRequest(entity: WithPosition.entity(), sortDescriptors: []) var fetchedWithPositions: FetchedResults<WithPosition>
    
    @EnvironmentObject var eventStore: EventStore
    
    @State private var isPresentingScanner = false
    @State private var code: String = ""
    @State private var value = ""
    @State private var scannedCode: String = ""
    @State private var coachList: [coachEntry] = []
    @State private var allDivers: [diverEntry] = []
    @State private var diversWithDives: [divers] = []
    @State private var editingList = true
    @State private var showPopUp = false
    @State private var showAlert = false
    @State private var teamsArray: [String] = []
    @State private var failedScanAlert: Bool = false
    @State private var diverInfoSheet: Bool = false
    @State private var sentDiver: divers = divers(dives: [], diverEntries: diverEntry(dives: [], level: 0, name: ""))
    @State private var failedScanMessage: String = "Could not find the needed data in the scanned QR Code\n"
    @State private var showQRCodeSheet: Bool = false
    
    @Binding var eventList: events
    @Binding var path: [String]
    
    struct Codes: Identifiable {
        let name: String
        let id = UUID()
    }
    
    var ScannerSheet : some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                if case let .success(code) = result {
                    self.scannedCode = code.string
                    
                    let tempCodes = Codes(name: code.string)
                    if tempCodes.name != "" {
                        let  base64Data = tempCodes.name.data(using: .utf8)
                        let data = Data(base64Encoded: base64Data!)
                        //let result = String(data: data!, encoding: .utf8)
                        let compressedJsonCode = data
                        //uncompress data
                        let jsonCode: Data
                        if compressedJsonCode!.isGzipped {
                            jsonCode = try! compressedJsonCode!.gunzipped()
                        }
                        else {
                            jsonCode = compressedJsonCode!
                        }
                        let decoder = JSONDecoder()
                        let entries = try? decoder.decode(coachEntry.self, from: jsonCode)
                        if entries != nil {
                            coachList = []
                            if checkCodeValidity(entry: entries!) {
                                if !eventList.EList.isEmpty || !eventList.JVList.isEmpty || !eventList.VList.isEmpty {
                                    makeTeamsArray()
                                }
                                for team in teamsArray {
                                    if team == entries?.team {
                                        if !eventList.EList.isEmpty {
                                            var loops: Int = 0
                                            while loops < eventList.EList.count {
                                                if eventList.EList[loops].diverEntries.team == team {
                                                    eventList.EList.remove(at: loops)
                                                }
                                                else {
                                                    loops += 1
                                                }
                                            }
                                        }
                                        if !eventList.JVList.isEmpty {
                                            var loops: Int = 0
                                            while loops < eventList.JVList.count {
                                                if eventList.JVList[loops].diverEntries.team == team {
                                                    eventList.JVList.remove(at: loops)
                                                }
                                                else {
                                                    loops += 1
                                                }
                                            }
                                        }
                                        if !eventList.VList.isEmpty {
                                            var loops: Int = 0
                                            while loops < eventList.VList.count {
                                                if eventList.VList[loops].diverEntries.team == team {
                                                    eventList.VList.remove(at: loops)
                                                }
                                                else {
                                                    loops += 1
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                coachList.append(entries!)
                                validateNewDivers()
                                sortDivers()
                                
                                eventStore.saveEvent()
                                
                                eventList.reviewed = false
                                self.isPresentingScanner = false
                            }
                            else {
                                //popup saying invalid qr code was scanned
                                failedScanAlert = true
                            }
                        }
                        else {
                            //popup saying invalid qr code was scanned
                            failedScanAlert = true
                        }
                    }
                }
            }
        )
        .alert("Ivalid QR Code", isPresented: $failedScanAlert) {
            Button("OK", role: .cancel) {
                failedScanMessage = "Could not find the needed data in the scanned QR Code\n"
                self.isPresentingScanner = false
            }
        } message: {
            Text(failedScanMessage)
        }
    }
    
    var body: some View {
        VStack {
            Text(!eventList.EList.isEmpty || !eventList.JVList.isEmpty || !eventList.VList.isEmpty ? "" : "No Divers Added")
                .font(.largeTitle.bold())
            
            List {
                Section(header: Text(!eventList.EList.isEmpty ? "Exhibition" : "").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                    ForEach(Array(zip(eventList.EList.indices, eventList.EList)), id: \.0) { index, diver in
                        Button {
                            sentDiver = diver
                            diverInfoSheet = true
                        } label: {
                            VStack(alignment: .leading) {
                                Text("\(index + 1). \(diver.diverEntries.name)")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Text("\(diver.diverEntries.team!)")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Text(diver.diverEntries.dq == true ? "Invalid Entry" : "")
                                    .foregroundColor(.purple)
                            }
                        }
                        .sheet(isPresented: $diverInfoSheet) {
                            diverInfoView(diverList: $sentDiver)
                        }
                    }
                    .onDelete(perform: deleteEDiver)
                    .onMove { (indexSet, index) in
                        eventList.reviewed = false
                        self.eventList.EList.move(fromOffsets: indexSet, toOffset: index)
                        eventStore.saveEvent()
                    }
                }
                Section(header: Text(!eventList.JVList.isEmpty ? "Junior Varsity" : "").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                    ForEach(Array(zip(eventList.JVList.indices, eventList.JVList)), id: \.1) { index, diver in
                        Button {
                            sentDiver = diver
                            diverInfoSheet = true
                        } label: {
                            VStack(alignment: .leading) {
                                Text("\(index + 1 + eventList.EList.count). \(diver.diverEntries.name)")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Text("\(diver.diverEntries.team!)")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Text(diver.diverEntries.dq == true ? "Invalid Entry" : "")
                                    .foregroundColor(.purple)
                            }
                        }
                    }
                    .onDelete(perform: deleteJVDiver)
                    .onMove { (indexSet, index) in
                        self.eventList.JVList.move(fromOffsets: indexSet, toOffset: index)
                    }
                }
                Section(header: Text(!eventList.VList.isEmpty ? "Varsity" : "").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                    ForEach(Array(zip(eventList.VList.indices, eventList.VList)), id: \.1) { index, diver in
                        Button {
                            sentDiver = diver
                            diverInfoSheet = true
                        } label: {
                            VStack(alignment: .leading) {
                                Text("\(index + 1 + eventList.EList.count + eventList.JVList.count). \(diver.diverEntries.name)")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Text("\(diver.diverEntries.team!)")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Text(diver.diverEntries.dq == true ? "Invalid Entry" : "")
                                    .foregroundColor(.purple)
                            }
                        }
                    }
                    .onDelete(perform: deleteVDiver)
                    .onMove { (indexSet, index) in
                        self.eventList.VList.move(fromOffsets: indexSet, toOffset: index)
                    }
                }
            }
            
            .environment(\.editMode, editingList ? .constant(.active) : .constant(.inactive))
            Spacer()
            HStack {
                VStack {
                    Button {
                        //opens qr scanner to scan in divers
                        self.isPresentingScanner = true
                    } label: {
                        Text("Add Divers")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .bold()
                            .padding(15)
                            .padding(.horizontal)
                            .padding(.horizontal)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                            )
                    }
                    .sheet(isPresented: $isPresentingScanner) {
                        self.ScannerSheet
                    }
                    
                    //moves to the score view once divers are entered and confirmed that official has verified it(needs to be added later)
                    if eventList.reviewed {
                        NavigationLink(destination: ScoreInfoView(diverList: diversWithDives, lastDiverIndex: diversWithDives.count - 1, eventList: $eventList, path: $path)) {
                            Text("Start Event")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .bold()
                                .padding(15)
                                .padding(.horizontal)
                                .padding(.horizontal)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                                    
                                )
                        }
                    }
                    else {
                        Button {
                            if !consolidateDiverList().isEmpty {
                                //add all aspects to divers struct
                                makeFinalDiverList()
                                showPopUp = true
                            }
                            else {
                                showAlert = true
                            }
                        } label: {
                            Text("Official Review")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .bold()
                                .padding(15)
                                .padding(.horizontal)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                                    
                                )
                        }
                        .alert("Official's Approval Required", isPresented: $showPopUp) {
                            Button("Cancel", role: .cancel) {}
                            Button("Confirm") {
                                eventList.reviewed = true
                                eventStore.saveEvent()
                            }
                        } message: {
                            Text("Please hand this device to an official for review. press confirm to continue")
                        }
                        .alert("You must enter divers before starting an event", isPresented: $showAlert) {
                            Button("OK", role: .cancel) {}
                        }
                    }
                }
                if eventList.reviewed {
                    Button {
                        showQRCodeSheet = true
                    } label: {
                        Text("Send To Announcer")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .bold()
                            .padding(15)
                            .padding(.horizontal)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                                
                            )
                    }
                    .sheet(isPresented: $showQRCodeSheet) {
                        CoachEntryQRCodeView(url: createdQrCode())
                    }
                }
            }
        }
        .onAppear {
            if !eventList.EList.isEmpty || !eventList.JVList.isEmpty || !eventList.VList.isEmpty {
                makeFinalDiverList()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    eventStore.saveEvent()
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                }
            }
        }
    }
    
    func sortDivers() {
        for coach in coachList {
            for diver in coach.diverEntries {
                if diver.level == 0 {
                    eventList.EList.append(divers(dives: [], diverEntries: diver))
                    eventList.EList[eventList.EList.count - 1].diverEntries.team = coach.team
                    eventList.EList[eventList.EList.count - 1].diverEntries.totalScore = 0
                }
                if diver.level == 1 {
                    eventList.JVList.append(divers(dives: [], diverEntries: diver))
                    eventList.JVList[eventList.JVList.count - 1].diverEntries.team = coach.team
                    eventList.JVList[eventList.JVList.count - 1].diverEntries.totalScore = 0
                }
                if diver.level == 2 {
                    eventList.VList.append(divers(dives: [], diverEntries: diver))
                    eventList.VList[eventList.VList.count - 1].diverEntries.team = coach.team
                    eventList.VList[eventList.VList.count - 1].diverEntries.totalScore = 0
                }
            }
        }
        //create array of every team
        makeTeamsArray()
        if !eventList.EList.isEmpty {
            sortEListByTeam()
        }
        if !eventList.JVList.isEmpty {
            sortJVListByTeam()
        }
        if !eventList.VList.isEmpty {
            sortVListByTeam()
        }
    }
    
    func makeTeamsArray() {
        for diver in eventList.EList {
            var addTeam = true
            for tempTeam in teamsArray {
                if diver.diverEntries.team == tempTeam {
                    addTeam = false
                }
            }
            if addTeam == true {
                teamsArray.append(diver.diverEntries.team!)
            }
        }
        for diver in eventList.JVList {
            var addTeam = true
            for tempTeam in teamsArray {
                if diver.diverEntries.team == tempTeam {
                    addTeam = false
                }
            }
            if addTeam == true {
                teamsArray.append(diver.diverEntries.team!)
            }
        }
        for diver in eventList.VList {
            var addTeam = true
            for tempTeam in teamsArray {
                if diver.diverEntries.team == tempTeam {
                    addTeam = false
                }
            }
            if addTeam == true {
                teamsArray.append(diver.diverEntries.team!)
            }
        }
    }
    
    func sortEListByTeam() {
        var index: Int = 0
        var tempEList: [divers] = []
        
        while !eventList.EList.isEmpty {
            var breakLoop = false
            for diver in 0..<eventList.EList.count {
                if breakLoop == false {
                    if eventList.EList[diver].diverEntries.team == teamsArray[index] {
                        tempEList.append(eventList.EList[diver])
                        eventList.EList.remove(at: diver)
                        breakLoop = true
                    }
                }
            }
            if index != teamsArray.count - 1 {
                index += 1
            }
            else {
                index = 0
            }
        }
        while !tempEList.isEmpty {
            eventList.EList.append(tempEList[tempEList.count - 1])
            tempEList.remove(at: tempEList.count - 1)
        }
    }
    
    func sortJVListByTeam() {
        var index: Int = 0
        var tempJVList: [divers] = []
        
        while !eventList.JVList.isEmpty {
            var breakLoop = false
            for diver in 0..<eventList.JVList.count {
                if !breakLoop {
                    if eventList.JVList[diver].diverEntries.team == teamsArray[index] {
                        tempJVList.append(eventList.JVList[diver])
                        eventList.JVList.remove(at: diver)
                        breakLoop = true
                    }
                }
            }
            if index != teamsArray.count - 1 {
                index += 1
            }
            else {
                index = 0
            }
        }
        while !tempJVList.isEmpty {
            eventList.JVList.append(tempJVList[tempJVList.count - 1])
            tempJVList.remove(at: tempJVList.count - 1)
        }
    }
    
    
    func sortVListByTeam() {
        var index: Int = 0
        var tempVList: [divers] = []
        
        while !eventList.VList.isEmpty {
            var breakLoop = false
            for diver in 0..<eventList.VList.count {
                if !breakLoop {
                    if eventList.VList[diver].diverEntries.team == teamsArray[index] {
                        tempVList.append(eventList.VList[diver])
                        eventList.VList.remove(at: diver)
                        breakLoop = true
                    }
                }
            }
            if index != teamsArray.count - 1 {
                index += 1
            }
            else {
                index = 0
            }
        }
        while !tempVList.isEmpty {
            eventList.VList.append(tempVList[tempVList.count - 1])
            tempVList.remove(at: tempVList.count - 1)
        }
    }
    
    func consolidateDiverList() -> [divers] {
        var allDivers: [divers] = []
        for diver in eventList.EList {
            allDivers.append(diver)
        }
        for diver in eventList.JVList {
            allDivers.append(diver)
        }
        for diver in eventList.VList {
            allDivers.append(diver)
        }
        return allDivers
    }
    
    func deleteEDiver(at offsets: IndexSet) {
        eventList.EList.remove(atOffsets: offsets)
        eventList.reviewed = false
        eventStore.saveEvent()
    }
    func deleteJVDiver(at offsets: IndexSet) {
        eventList.JVList.remove(atOffsets: offsets)
        eventList.reviewed = false
        eventStore.saveEvent()
    }
    func deleteVDiver(at offsets: IndexSet) {
        eventList.VList.remove(atOffsets: offsets)
        eventList.reviewed = false
        eventStore.saveEvent()
    }
    
    func makeFinalDiverList() {
        diversWithDives = []
        for diver in consolidateDiverList() {
            var diveList: [dives] = []
            if diver.dives.isEmpty {
                for dive in diver.diverEntries.dives {
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
                    diveList.append(newDive)
                }
                diversWithDives.append(divers(dives: diveList, diverEntries: diver.diverEntries))
            }
            else {
                diversWithDives.append(diver)
            }
        }
    }
    func checkCodeValidity(entry: coachEntry) -> Bool {
        var valid = false
        
        for diver in entry.diverEntries {
            //check dive num and code
            for dive in diver.dives {
                valid = false
                var tempDive = dive
                while tempDive.count > 1 {
                    tempDive.remove(at: tempDive.startIndex)
                }
                var tempPosId: Int64 = -1
                for fetchedPosition in fetchedPositions {
                    if tempDive.uppercased() == fetchedPosition.positionCode {
                        tempPosId = fetchedPosition.positionId
                    }
                }
                for fetchedWithPosition in fetchedWithPositions {
                    if Int(dive.dropLast()) ?? 0 == fetchedWithPosition.diveNbr && tempPosId == fetchedWithPosition.positionId {
                        valid = true
                    }
                }
                if !valid {
                    failedScanMessage += "A diver includes a nonexistant dive\n"
                    return false
                }
            }
            
            //check levels
            if diver.level > 3 || diver.level < 0 {
                failedScanMessage += "A diver has a nonexistant level of competition\n"
                valid = false
            }
            
            //check dive count
            if diver.dives.count > eventList.diveCount {
                //message saying to many dives
                failedScanMessage += "A diver has too many dives\n"
                return false
            }
        }
        return valid
    }
    
    func validateNewDivers() {
        var skipFirstDive = true
        var uniqueCategories: [Int] = []
        var uniqueCategoryCount: Int = 0
        for diver in 0..<coachList[0].diverEntries.count {
            if coachList[0].diverEntries[diver].dives.count < eventList.diveCount {
                coachList[0].diverEntries[diver].dq = true
            }
            if coachList[0].diverEntries[diver].dives.count == 6 {
                //check for dive of the week
                var tempDiveCode = coachList[0].diverEntries[diver].dives[0]
                tempDiveCode.removeLast()
                if findDiveOfTheWeek().contains(Int(tempDiveCode)!) {
                    
                }
                else {
                    //DQ
                    coachList[0].diverEntries[diver].dq = true
                }
                if !skipFirstDive {
                    for dive in coachList[0].diverEntries[diver].dives {
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
                        
                    }
                    else {
                        //DQ for not having 4 categories
                        coachList[0].diverEntries[diver].dq = true
                    }
                }
            }
            else if coachList[0].diverEntries[diver].dives.count == 11 {
                coachList[0].diverEntries[diver].fullDives = []
                var fullDive = dives(name: "", degreeOfDiff: 0, score: [], position: "", roundScore: 0)
                for dive in 0..<coachList[0].diverEntries[diver].dives.count {
                    var number = coachList[0].diverEntries[diver].dives[dive]
                    number.removeLast()
                    var letter = coachList[0].diverEntries[diver].dives[dive]
                    var positionId: Int64 = 0
                    
                    while letter.count > 1 {
                        letter.removeFirst()
                    }
                    for fetchedDive in fetchedDives {
                        if fetchedDive.diveNbr == Int(number)! {
                            fullDive.name = fetchedDive.diveName ?? ""
                        }
                    }
                    for fetchedPosition in fetchedPositions {
                        if fetchedPosition.positionCode == letter.uppercased() {
                            positionId = fetchedPosition.positionId
                            fullDive.position = fetchedPosition.positionName ?? ""
                        }
                    }
                    for fetchedWithPosition in fetchedWithPositions {
                        if fetchedWithPosition.positionId == positionId && fetchedWithPosition.diveNbr == Int(number)! {
                            fullDive.degreeOfDiff = fetchedWithPosition.degreeOfDifficulty
                        }
                    }
                    fullDive.code = coachList[0].diverEntries[diver].dives[dive]
                    fullDive.volentary = coachList[0].diverEntries[diver].volentary?[dive]
                    coachList[0].diverEntries[diver].fullDives!.append(fullDive)
                }
                var allCategories: [Int] = []
                var uniqueCategories: Int = 0
                var totalDOD: Double = 0
                for dive in coachList[0].diverEntries[diver].fullDives! {
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
                    coachList[0].diverEntries[diver].dq = true
                }
                if uniqueCategories == 5 {
                }
                else {
                    coachList[0].diverEntries[diver].dq = true
                }
                
                for dive in coachList[0].diverEntries[diver].fullDives! {
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
                        coachList[0].diverEntries[diver].dq = true
                    }
                }
                //check dive order for validation
                uniqueCategories = 0
                allCategories.removeAll()
                for dive in 0...7 {
                    var diveNum = coachList[0].diverEntries[diver].dives[dive]
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
                        var diveNum = coachList[0].diverEntries[diver].dives[dive]
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
                                coachList[0].diverEntries[diver].dq = true
                                breakLoop = true
                            }
                        }
                    }
                    //check the volentary to optional ratio
                    var volentaryCount = 0
                    for dive in 0...4 {
                        if coachList[0].diverEntries[diver].fullDives![dive].volentary == true {
                            volentaryCount += 1
                        }
                    }
                    if volentaryCount == 2 {
                        //success
                    }
                    else {
                        coachList[0].diverEntries[diver].dq = true
                    }
                    volentaryCount = 0
                    for dive in 5...7 {
                        if coachList[0].diverEntries[diver].fullDives![dive].volentary == true {
                            volentaryCount += 1
                        }
                    }
                    if volentaryCount == 2 {
                        //success
                    }
                    else {
                        coachList[0].diverEntries[diver].dq = true
                    }
                    volentaryCount = 0
                    for dive in 8...10 {
                        if coachList[0].diverEntries[diver].fullDives![dive].volentary == true {
                            volentaryCount += 1
                        }
                    }
                    if volentaryCount == 1 {
                        //success
                    }
                    else {
                        coachList[0].diverEntries[diver].dq = true
                    }
                }
                else {
                    coachList[0].diverEntries[diver].dq = true
                }
            }
            skipFirstDive = false
        }
    }
    
    func findDiveOfTheWeek() -> ClosedRange<Int> {
        var tempDate = Date()
        var dateComponents = DateComponents()
        dateComponents.month = 0
        dateComponents.day = -1
        dateComponents.year = 0
        while tempDate.formatted(date: .numeric, time: .omitted) != "8/13/2023" {
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
    
    func createdQrCode() -> String {
        var announcerEvent = announcerEvent(diver: [])
        for diver in diversWithDives {
            announcerEvent.diver.append(announcerDiver(name: diver.diverEntries.name, school: diver.diverEntries.team ?? "", dives: []))
            for dive in diver.diverEntries.dives {
                announcerEvent.diver[announcerEvent.diver.count - 1].dives.append(dive)
            }
        }
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(announcerEvent)
        // json compression
        let optimizedData : Data = try! data.gzipped(level: .bestCompression)
        return optimizedData.base64EncodedString()
    }
    
    struct AddDiversView_Previews: PreviewProvider {
        static var previews: some View {
            AddDiversView(eventList: .constant(events(date: "", EList: [], JVList: [], VList: [], finished: false, judgeCount: 3, diveCount: 6, reviewed: false)), path: .constant([]))
        }
    }
}
