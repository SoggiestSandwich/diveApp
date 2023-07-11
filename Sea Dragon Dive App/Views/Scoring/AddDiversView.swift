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
    @State private var JVList: [divers] = []
    @State private var VList: [divers] = []
    @State private var EList: [divers] = []
    @State private var allDivers: [diverEntry] = []
    @State private var diversWithDives: [divers] = []
    @State private var editingList = true
    @State private var showPopUp = false
    @State private var showAlert = false
    @State private var reviewed = false
    @State private var teamsArray: [String] = []
    
    @Binding var eventList: events
    
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
                    self.isPresentingScanner = false
                    
                    let tempCodes = Codes(name: code.string)
                    if tempCodes.name != "" {
                        let jsonCode = tempCodes.name.data(using: .utf8)!
                        let decoder = JSONDecoder()
                        let entries = try? decoder.decode(coachEntry.self, from: jsonCode)
                        if entries != nil {
                            coachList = []
                            if checkCodeValidity(entry: entries!) {
                                for team in teamsArray {
                                    if team == entries?.team {
                                        if !EList.isEmpty {
                                            var loops: Int = 0
                                            while loops < EList.count {
                                                if EList[loops].diverEntries.team == team {
                                                    EList.remove(at: loops)
                                                }
                                                else {
                                                    loops += 1
                                                }
                                            }
                                        }
                                        if !JVList.isEmpty {
                                            var loops: Int = 0
                                            while loops < JVList.count {
                                                if JVList[loops].diverEntries.team == team {
                                                    JVList.remove(at: loops)
                                                }
                                                else {
                                                    loops += 1
                                                }
                                            }
                                        }
                                        if !VList.isEmpty {
                                            var loops: Int = 0
                                            while loops < VList.count {
                                                if VList[loops].diverEntries.team == team {
                                                    VList.remove(at: loops)
                                                }
                                                else {
                                                    loops += 1
                                                }
                                            }
                                        }
                                    }
                                }
                                coachList.append(entries!)
                                sortDivers()
                            
                                eventList.EList = EList
                                eventList.JVList = JVList
                                eventList.VList = VList
                                eventStore.saveEvent()
                                eventList.EList = []
                                eventList.JVList = []
                                eventList.VList = []
                            }
                            else {
                                //popup saying invalid qr code was scanned
                            }
                        }
                        else {
                            //popup saying invalid qr code was scanned
                        }
                    }
                }
            }
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(!EList.isEmpty || !JVList.isEmpty || !VList.isEmpty ? "" : "No Divers Added")
                    .font(.largeTitle.bold())
                
                List {
                    Section(header: Text(!EList.isEmpty ? "Exhibition" : "").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                        ForEach(Array(zip(EList.indices, EList)), id: \.0) { index, diver in
                            Text("\(index + 1). \(diver.diverEntries.name)\n\(diver.diverEntries.team!)")
                        }
                        .onDelete(perform: deleteEDiver)
                        .onMove { (indexSet, index) in
                            self.EList.move(fromOffsets: indexSet, toOffset: index)
                        }
                    }
                    Section(header: Text(!JVList.isEmpty ? "Junior Varsity" : "").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                        ForEach(Array(zip(JVList.indices, JVList)), id: \.1) { index, diver in
                            Text("\(index + EList.count + 1). \(diver.diverEntries.name)\n\(diver.diverEntries.team!)")
                        }
                        .onDelete(perform: deleteJVDiver)
                        .onMove { (indexSet, index) in
                            self.JVList.move(fromOffsets: indexSet, toOffset: index)
                        }
                    }
                    Section(header: Text(!VList.isEmpty ? "Varsity" : "").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                        ForEach(Array(zip(VList.indices, VList)), id: \.1) { index, diver in
                            Text("\(index + EList.count + JVList.count + 1). \(diver.diverEntries.name)\n\(diver.diverEntries.team!)")
                        }
                        .onDelete(perform: deleteVDiver)
                        .onMove { (indexSet, index) in
                            self.VList.move(fromOffsets: indexSet, toOffset: index)
                        }
                    }
                }
                .environment(\.editMode, editingList ? .constant(.active) : .constant(.inactive))
                Spacer()
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
                if reviewed {
                    NavigationLink(destination: ScoreInfoView(diverList: diversWithDives, lastDiverIndex: diversWithDives.count - 1, EList: $EList, JVList: $JVList, VList: $VList, eventList: $eventList)) {
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
                            reviewed = true
                        }
                    } message: {
                        Text("Please hand this device to an official for review. press confirm to continue")
                    }
                    .alert("You must enter divers before starting an event", isPresented: $showAlert) {
                        Button("OK", role: .cancel) {}
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    eventList.EList = EList
                    eventList.JVList = JVList
                    eventList.VList = VList
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                }
            }
        }
        .onAppear {
                if !eventList.EList.isEmpty {
                    while !eventList.EList.isEmpty {
                        EList.append(eventList.EList[0])
                        eventList.EList.removeFirst()
                    }
                }
                if !eventList.JVList.isEmpty {
                    while !eventList.JVList.isEmpty {
                        JVList.append(eventList.JVList[0])
                        eventList.JVList.removeFirst()
                    }
                }
                if !eventList.VList.isEmpty {
                    while !eventList.VList.isEmpty {
                        VList.append(eventList.VList[0])
                        eventList.VList.removeFirst()
                    }
                }
            reviewed = false   }
    }
    
    func sortDivers() {
        for coach in coachList {
            for diver in coach.diverEntries {
                if diver.level == 0 {
                    EList.append(divers(dives: [], diverEntries: diver))
                    EList[EList.count - 1].diverEntries.team = coach.team
                    EList[EList.count - 1].diverEntries.score = 0
                }
                if diver.level == 1 {
                    JVList.append(divers(dives: [], diverEntries: diver))
                    JVList[JVList.count - 1].diverEntries.team = coach.team
                    JVList[JVList.count - 1].diverEntries.score = 0
                }
                if diver.level == 2 {
                    VList.append(divers(dives: [], diverEntries: diver))
                    VList[VList.count - 1].diverEntries.team = coach.team
                    VList[VList.count - 1].diverEntries.score = 0
                }
            }
        }
        //create array of every team
        for diver in EList {
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
        for diver in JVList {
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
        for diver in VList {
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
        if !EList.isEmpty {
            sortEListByTeam()
        }
        if !JVList.isEmpty {
            sortJVListByTeam()
        }
        if !VList.isEmpty {
            sortVListByTeam()
        }
    }
    
    func sortEListByTeam() {
        var index: Int = 0
        var tempEList: [divers] = []
        
        while !EList.isEmpty {
            var breakLoop = false
            for diver in 0..<EList.count {
                if breakLoop == false {
                    if EList[diver].diverEntries.team == teamsArray[index] {
                        tempEList.append(EList[diver])
                        EList.remove(at: diver)
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
            EList.append(tempEList[tempEList.count - 1])
            tempEList.remove(at: tempEList.count - 1)
        }
    }
    
    func sortJVListByTeam() {
        var index: Int = 0
        var tempJVList: [divers] = []
        
        while !JVList.isEmpty {
            var breakLoop = false
            for diver in 0..<JVList.count {
                if !breakLoop {
                    if JVList[diver].diverEntries.team == teamsArray[index] {
                        tempJVList.append(JVList[diver])
                        JVList.remove(at: diver)
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
            JVList.append(tempJVList[tempJVList.count - 1])
            tempJVList.remove(at: tempJVList.count - 1)
        }
    }
    
    
    func sortVListByTeam() {
        var index: Int = 0
        var tempVList: [divers] = []
        
        while !VList.isEmpty {
            var breakLoop = false
            for diver in 0..<VList.count {
                if !breakLoop {
                    if VList[diver].diverEntries.team == teamsArray[index] {
                        tempVList.append(VList[diver])
                        VList.remove(at: diver)
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
            VList.append(tempVList[tempVList.count - 1])
            tempVList.remove(at: tempVList.count - 1)
        }
    }
    
    func consolidateDiverList() -> [divers] {
        var allDivers: [divers] = []
        for diver in EList {
            allDivers.append(diver)
        }
        for diver in JVList {
            allDivers.append(diver)
        }
        for diver in VList {
            allDivers.append(diver)
        }
        return allDivers
    }
    
    func deleteEDiver(at offsets: IndexSet) {
        EList.remove(atOffsets: offsets)
    }
    func deleteJVDiver(at offsets: IndexSet) {
        JVList.remove(atOffsets: offsets)
    }
    func deleteVDiver(at offsets: IndexSet) {
        VList.remove(atOffsets: offsets)
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
                    return false
                }
            }
            
            //check levels
            if diver.level > 3 || diver.level < 0 {
                valid = false
            }
        }
        return valid
    }
    
    struct AddDiversView_Previews: PreviewProvider {
        static var previews: some View {
            AddDiversView(eventList: .constant(events(date: "", EList: [], JVList: [], VList: [])))
        }
    }
}
