//
//  AddDiversView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/15/23.
//

import SwiftUI
import CodeScanner

struct AddDiversView: View {
    @Environment(\.colorScheme) var colorScheme //detects if the device is in dark mode
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> //used to make custom back button
    
    //tables from the database
    @FetchRequest(entity: Dive.entity(), sortDescriptors: []) var fetchedDives: FetchedResults<Dive>
    @FetchRequest(entity: Position.entity(), sortDescriptors: []) var fetchedPositions: FetchedResults<Position>
    @FetchRequest(entity: WithPosition.entity(), sortDescriptors: []) var fetchedWithPositions: FetchedResults<WithPosition>
    
    @EnvironmentObject var eventStore: EventStore //persistant event data
    
    @State private var isPresentingScanner = false //used to open the qr scanner
    @State private var code: String = "" //the code being scanned in
    @State private var coachList: [coachEntry] = [] //list of coach entries that are scanned in
    @State private var allDivers: [diverEntry] = [] //list of the dive entries that are used to make the divers list
    @State private var diversWithDives: [divers] = [] //list of divers that is shown
    @State private var editingList = true //sets the list to editing mode for deleting and reordering
    @State private var showPopUp = false //used to open a popup for official approval
    @State private var showAlert = false //used to open an alert informing the user they need to add divers
    @State private var teamsArray: [String] = [] //an array with all the team names of the entries
    @State private var failedScanAlert: Bool = false //used to open an alert for a failed qr code scan
    @State private var diverInfoSheet: Bool = false //opens sheet for viewing the divers dives
    @State private var sentDiver: divers = divers(dives: [], diverEntries: diverEntry(dives: [], level: 0, name: "")) //diver that is being viewed in the diver info view
    @State private var failedScanMessage: String = "Could not find the needed data in the scanned QR Code\n" //message that is shown when a qr code scan fails
    @State private var showQRCodeSheet: Bool = false //opens to qr scanner
    
    @Binding var event: events //the event that is having divers added to
    @Binding var path: [String] //used to go back to login view
    
    //struct that holds an identifiable qr code
    struct Codes: Identifiable {
        let name: String
        let id = UUID()
    }
    //qr code scanner view
    var ScannerSheet : some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                //successful scan
                if case let .success(code) = result {
                    //
                    let tempCodes = Codes(name: code.string)
                    if tempCodes.name != "" {
                        let base64Data = tempCodes.name.data(using: .utf8)
                        //uncompressing code into json
                        let data = Data(base64Encoded: base64Data!)
                        let compressedJsonCode = data
                        let jsonCode: Data
                        if compressedJsonCode!.isGzipped {
                            jsonCode = try! compressedJsonCode!.gunzipped()
                        }
                        else {
                            jsonCode = compressedJsonCode!
                        }
                        //decode json into coach entry data
                        let decoder = JSONDecoder()
                        let entries = try? decoder.decode(coachEntry.self, from: jsonCode)
                        if entries != nil {
                            coachList = []
                            //sorts the diver entries in the coach entries into their corresponding level.
                            if checkCodeValidity(entry: entries!) {
                                if !event.EList.isEmpty || !event.JVList.isEmpty || !event.VList.isEmpty {
                                    makeTeamsArray()
                                }
                                for team in teamsArray {
                                    if team == entries?.team {
                                        if !event.EList.isEmpty {
                                            var loops: Int = 0
                                            while loops < event.EList.count {
                                                if event.EList[loops].diverEntries.team == team {
                                                    event.EList.remove(at: loops)
                                                }
                                                else {
                                                    loops += 1
                                                }
                                            }
                                        }
                                        if !event.JVList.isEmpty {
                                            var loops: Int = 0
                                            while loops < event.JVList.count {
                                                if event.JVList[loops].diverEntries.team == team {
                                                    event.JVList.remove(at: loops)
                                                }
                                                else {
                                                    loops += 1
                                                }
                                            }
                                        }
                                        if !event.VList.isEmpty {
                                            var loops: Int = 0
                                            while loops < event.VList.count {
                                                if event.VList[loops].diverEntries.team == team {
                                                    event.VList.remove(at: loops)
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
                                
                                event.reviewed = false
                                self.isPresentingScanner = false //closes qr scanner
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
        //aler for an invalid qr scan
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
            Text(!event.EList.isEmpty || !event.JVList.isEmpty || !event.VList.isEmpty ? "" : "No Divers Added")
                .font(.largeTitle.bold())
            //list of all divers in the event
            List {
                //exhibition divers
                Section(header: Text(!event.EList.isEmpty ? "Exhibition" : "").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                    ForEach(Array(zip(event.EList.indices, event.EList)), id: \.0) { index, diver in
                        //opens the diver info view for the diver selected
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
                    }
                    .onDelete(perform: deleteEDiver)
                    .onMove { (indexSet, index) in
                        event.reviewed = false
                        self.event.EList.move(fromOffsets: indexSet, toOffset: index)
                        eventStore.saveEvent()
                    }
                }
                //junior varsity divers
                Section(header: Text(!event.JVList.isEmpty ? "Junior Varsity" : "").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                    ForEach(Array(zip(event.JVList.indices, event.JVList)), id: \.1) { index, diver in
                        //opens the diver info view for the diver selected
                        Button {
                            sentDiver = diver
                            diverInfoSheet = true
                        } label: {
                            VStack(alignment: .leading) {
                                Text("\(index + 1 + event.EList.count). \(diver.diverEntries.name)")
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
                        event.reviewed = false
                        self.event.JVList.move(fromOffsets: indexSet, toOffset: index)
                    }
                }
                //varsity divers
                Section(header: Text(!event.VList.isEmpty ? "Varsity" : "").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                    ForEach(Array(zip(event.VList.indices, event.VList)), id: \.1) { index, diver in
                        //opens the diver info view for the diver selected
                        Button {
                            sentDiver = diver
                            diverInfoSheet = true
                        } label: {
                            VStack(alignment: .leading) {
                                Text("\(index + 1 + event.EList.count + event.JVList.count). \(diver.diverEntries.name)")
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
                        event.reviewed = false
                        self.event.VList.move(fromOffsets: indexSet, toOffset: index)
                    }
                }
            }
            .environment(\.editMode, editingList ? .constant(.active) : .constant(.inactive)) //sets the list to editing mode for deleting and reordering
            Spacer()
            HStack {
                VStack {
                    //opens the qr scanner view to scan from coach
                    Button {
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
                    //qr code scanner sheet
                    .sheet(isPresented: $isPresentingScanner) {
                        self.ScannerSheet
                    }
                    
                    //moves to the score view once divers are entered and confirmed that official has verified it
                    if event.reviewed {
                        //goes to the score info view to begin scoring the event
                        NavigationLink(destination: ScoreInfoView(diverList: diversWithDives, lastDiverIndex: diversWithDives.count - 1, event: $event, path: $path)) {
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
                        //pulls up official review popup
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
                        //alert that asks for officials approval
                        .alert("Official's Approval Required", isPresented: $showPopUp) {
                            Button("Cancel", role: .cancel) {}
                            Button("Confirm") {
                                event.reviewed = true
                                eventStore.saveEvent()
                            }
                        } message: {
                            Text("Please hand this device to an official for review. press confirm to continue")
                        }
                        //alert that tells the user to add divers
                        .alert("You must enter divers before starting an event", isPresented: $showAlert) {
                            Button("OK", role: .cancel) {}
                        }
                    }
                }
                if event.reviewed {
                    //creates a qr code to be sent to the announcer
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
                    //qr code view for the announcer to scan
                    .sheet(isPresented: $showQRCodeSheet) {
                        CoachEntryQRCodeView(code: createdQrCode())
                    }
                }
            }
        }
        .onAppear {
            //makes a final diver list if any level isn't empty for if the event has already been approved by the official in re-entering
            if !event.EList.isEmpty || !event.JVList.isEmpty || !event.VList.isEmpty {
                makeFinalDiverList()
            }
        }
        .navigationBarBackButtonHidden(true) //removes the default back button
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                //saves the events data to persistant data and goes back a view
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
        //sheet for the diver's info
        .sheet(isPresented: $diverInfoSheet) {
            diverInfoView(diver: $sentDiver, diveCount: event.diveCount)
        }
    }
    //sorts the divers into their level and then sort the order based on what team they are on
    func sortDivers() {
        for coach in coachList {
            for diver in coach.diverEntries {
                if diver.level == 0 {
                    event.EList.append(divers(dives: [], diverEntries: diver))
                    event.EList[event.EList.count - 1].diverEntries.team = coach.team
                    event.EList[event.EList.count - 1].diverEntries.totalScore = 0
                }
                if diver.level == 1 {
                    event.JVList.append(divers(dives: [], diverEntries: diver))
                    event.JVList[event.JVList.count - 1].diverEntries.team = coach.team
                    event.JVList[event.JVList.count - 1].diverEntries.totalScore = 0
                }
                if diver.level == 2 {
                    event.VList.append(divers(dives: [], diverEntries: diver))
                    event.VList[event.VList.count - 1].diverEntries.team = coach.team
                    event.VList[event.VList.count - 1].diverEntries.totalScore = 0
                }
            }
        }
        //create array of every team
        makeTeamsArray()
        if !event.EList.isEmpty {
            sortEListByTeam()
        }
        if !event.JVList.isEmpty {
            sortJVListByTeam()
        }
        if !event.VList.isEmpty {
            sortVListByTeam()
        }
    }
    
    //makes an array of every team name
    func makeTeamsArray() {
        for diver in event.EList {
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
        for diver in event.JVList {
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
        for diver in event.VList {
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
    //reorders the exhibition divers based on their team
    func sortEListByTeam() {
        var index: Int = 0
        var tempEList: [divers] = []
        while !event.EList.isEmpty {
            var breakLoop = false
            //loops through the EList and moves a diver to the temp list if they match the team at the index
            for diver in 0..<event.EList.count {
                if breakLoop == false {
                    if event.EList[diver].diverEntries.team == teamsArray[index] {
                        tempEList.append(event.EList[diver])
                        event.EList.remove(at: diver)
                        breakLoop = true
                    }
                }
            }
            if index != teamsArray.count - 1 {
                //next team
                index += 1
            }
            else {
                //go back to the start of the team array
                index = 0
            }
        }
        //move the templist divers back into the EList with the new order
        while !tempEList.isEmpty {
            event.EList.append(tempEList[tempEList.count - 1])
            tempEList.remove(at: tempEList.count - 1)
        }
    }
    //reorders to junior varsity divers based on their team
    func sortJVListByTeam() {
        var index: Int = 0
        var tempJVList: [divers] = []
        
        while !event.JVList.isEmpty {
            var breakLoop = false
            //loops through the JVList and moves a diver to the temp list if they match the team at the index
            for diver in 0..<event.JVList.count {
                if !breakLoop {
                    if event.JVList[diver].diverEntries.team == teamsArray[index] {
                        tempJVList.append(event.JVList[diver])
                        event.JVList.remove(at: diver)
                        breakLoop = true
                    }
                }
            }
            if index != teamsArray.count - 1 {
                //next team
                index += 1
            }
            else {
                //go back to the start of the team array
                index = 0
            }
        }
        //move the templist divers back into the JVList with the new order
        while !tempJVList.isEmpty {
            event.JVList.append(tempJVList[tempJVList.count - 1])
            tempJVList.remove(at: tempJVList.count - 1)
        }
    }
    
    //reorders to varsity divers based on their team
    func sortVListByTeam() {
        var index: Int = 0
        var tempVList: [divers] = []
        
        while !event.VList.isEmpty {
            var breakLoop = false
            //loops through the VList and moves a diver to the temp list if they match the team at the index
            for diver in 0..<event.VList.count {
                if !breakLoop {
                    if event.VList[diver].diverEntries.team == teamsArray[index] {
                        tempVList.append(event.VList[diver])
                        event.VList.remove(at: diver)
                        breakLoop = true
                    }
                }
            }
            if index != teamsArray.count - 1 {
                //next team
                index += 1
            }
            else {
                //go back to the start of the team array
                index = 0
            }
        }
        //move the templist divers back into the VList with the new order
        while !tempVList.isEmpty {
            event.VList.append(tempVList[tempVList.count - 1])
            tempVList.remove(at: tempVList.count - 1)
        }
    }
    //takes all the divers from the diffferent levels and returns them in one list
    func consolidateDiverList() -> [divers] {
        var allDivers: [divers] = []
        for diver in event.EList {
            allDivers.append(diver)
        }
        for diver in event.JVList {
            allDivers.append(diver)
        }
        for diver in event.VList {
            allDivers.append(diver)
        }
        return allDivers
    }
    //removes a diver from the EList at the given index
    func deleteEDiver(at offsets: IndexSet) {
        event.EList.remove(atOffsets: offsets)
        event.reviewed = false
        eventStore.saveEvent()
    }
    //removes a diver from the JVList at the given index
    func deleteJVDiver(at offsets: IndexSet) {
        event.JVList.remove(atOffsets: offsets)
        event.reviewed = false
        eventStore.saveEvent()
    }
    //removes a diver from the VList at the given index
    func deleteVDiver(at offsets: IndexSet) {
        event.VList.remove(atOffsets: offsets)
        event.reviewed = false
        eventStore.saveEvent()
    }
    //makes a list with all divers with their full dive info from their code to be sent to the scoring view
    func makeFinalDiverList() {
        diversWithDives = []
        //loops through all divers
        for diver in consolidateDiverList() {
            var diveList: [dives] = []
            if diver.dives.isEmpty {
                //loops through all the dive codes
                for dive in diver.diverEntries.dives! {
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
                    //full dive
                    let newDive = dives(name: name, degreeOfDiff: dOD, score: [], position: positionName, roundScore: 0, code: dive)
                    diveList.append(newDive)
                }
                diversWithDives.append(divers(dives: diveList, diverEntries: diver.diverEntries, dq: diver.diverEntries.dq))
            }
            else {
                diversWithDives.append(diver)
            }
        }
    }
    //checks if the divers entries in the coach entry are valid
    func checkCodeValidity(entry: coachEntry) -> Bool {
        var valid = false
        //loops through all diver entries in the coach entry
        for diver in entry.diverEntries {
            //check dive num and code
            for dive in diver.dives! {
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
            if diver.dives!.count > event.diveCount {
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
        //loops through all diver entries in the first coach entry which is cleared after each is validated
        for diver in 0..<coachList[0].diverEntries.count {
            if coachList[0].diverEntries[diver].dives!.count < event.diveCount {
                coachList[0].diverEntries[diver].dq = true
            }
            if coachList[0].diverEntries[diver].dives!.count == 6 {
                //check for dive of the week
                var tempDiveCode = coachList[0].diverEntries[diver].dives![0]
                tempDiveCode.removeLast()
                if findDiveOfTheWeek().contains(Int(tempDiveCode)!) {
                    
                }
                else {
                    //DQ
                    coachList[0].diverEntries[diver].dq = true
                }
                if !skipFirstDive {
                    uniqueCategories = []
                    uniqueCategoryCount = 0
                    for dive in coachList[0].diverEntries[diver].dives! {
                        var tempDiveCode = dive
                        tempDiveCode.removeLast()
                        if Int(tempDiveCode)! < 200 {
                            if !uniqueCategories.contains(1) {
                                uniqueCategoryCount += 1
                            }
                            uniqueCategories.append(1)
                        }
                        else if Int(tempDiveCode)! < 300 {
                            if !uniqueCategories.contains(2) {
                                uniqueCategoryCount += 1
                            }
                            uniqueCategories.append(2)
                        }
                        else if Int(tempDiveCode)! < 400 {
                            if !uniqueCategories.contains(3) {
                                uniqueCategoryCount += 1
                            }
                            uniqueCategories.append(3)
                        }
                        else if Int(tempDiveCode)! < 500 {
                            if !uniqueCategories.contains(4) {
                                uniqueCategoryCount += 1
                            }
                            uniqueCategories.append(4)
                        }
                        else if Int(tempDiveCode)! < 6000 {
                            if !uniqueCategories.contains(5) {
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
            else if coachList[0].diverEntries[diver].dives!.count == 11 {
                coachList[0].diverEntries[diver].fullDives = []
                var fullDive = dives(name: "", degreeOfDiff: 0, score: [], position: "", roundScore: 0)
                for dive in 0..<coachList[0].diverEntries[diver].dives!.count {
                    var number = coachList[0].diverEntries[diver].dives![dive]
                    number.removeLast()
                    var letter = coachList[0].diverEntries[diver].dives![dive]
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
                    fullDive.code = coachList[0].diverEntries[diver].dives![dive]
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
                    var diveNum = coachList[0].diverEntries[diver].dives![dive]
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
                        var diveNum = coachList[0].diverEntries[diver].dives![dive]
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
    //finds the dive of the week by going back day by day until it hits the start of a week and returns that dives code
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
    //returns a string to be sent through a qr code
    func createdQrCode() -> String {
        var announcerEvent = announcerEvent(diver: [])
        //loops through each diver
        for diver in diversWithDives {
            announcerEvent.diver.append(announcerDiver(name: diver.diverEntries.name, school: diver.diverEntries.team ?? "", dives: []))
            //loops through each dive
            for dive in diver.diverEntries.dives! {
                announcerEvent.diver[announcerEvent.diver.count - 1].dives.append(dive)
            }
        }
        //encode data to json
        let encoder = JSONEncoder()
        let data = try! encoder.encode(announcerEvent)
        // json compression
        let optimizedData : Data = try! data.gzipped(level: .bestCompression)
        return optimizedData.base64EncodedString()
    }
    
    struct AddDiversView_Previews: PreviewProvider {
        static var previews: some View {
            AddDiversView(event: .constant(events(date: "", EList: [], JVList: [], VList: [], finished: false, judgeCount: 3, diveCount: 6, reviewed: false)), path: .constant([]))
        }
    }
}
