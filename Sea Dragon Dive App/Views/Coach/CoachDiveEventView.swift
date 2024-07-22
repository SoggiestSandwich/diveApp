//
//  CoachDiveEventView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/15/23.
//

import SwiftUI
import CodeScanner

struct CoachDiveEventView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass //detects if the device is vertical
    @Environment(\.colorScheme) var colorScheme //detects if the device is in dark mode
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> //used to make custom back button
    
    @EnvironmentObject var coachEntryStore: CoachEntryStore //persistant data for coach entries
    
    //fetched tables from the database
    @FetchRequest(entity: Dive.entity(), sortDescriptors: []) var fetchedDives: FetchedResults<Dive>
    @FetchRequest(entity: Position.entity(), sortDescriptors: []) var fetchedPositions: FetchedResults<Position>
    @FetchRequest(entity: WithPosition.entity(), sortDescriptors: []) var fetchedWithPositions: FetchedResults<WithPosition>
    
    @State var failedScanAlert = false //triggers an alert for a failed qr scan
    @State var isPresentingScanner = false //opens the qr scanner
    //@State private var scannedCode: String = ""
    @State private var date: Date = Date() //the events date
    @State private var location: String = "" //the events location
    @State private var showQRCodeSheet = false //opens the qr code image view
    @State var name: String //name of the coach
    @State var team: String //name of the coaches school/team
    @State var taskComplete: Bool = false //holds the date picker until the view entry task completes
    @State var coachListIndex: Int //index of the coach entry selected
    
    
    @Binding var entry: coachEntry //the seleced coach entry
    
    //simple struct for holding an identifiable qr code string
    struct Codes: Identifiable {
        let name: String
        let id = UUID()
    }
    //qr scanner
    var ScannerSheet : some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                if case let .success(code) = result {
                    //if it successfully scans it will uncompress the code to json then decode it to a diverEntry
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
                        var entries = try? decoder.decode(diverEntry.self, from: jsonCode)
                        if entries != nil {
                            entries!.finishedEntry = true
                            
                            entry.diverEntries.append(entries!) //add the diver entry to the coaches entry
                            //find full dives
                            findDives(diverIndex: entry.diverEntries.count - 1)
                            coachEntryStore.saveDiverEntry()
                            self.isPresentingScanner = false
                        }
                        else {
                            //popup saying invalid qr code was scanned
                            failedScanAlert = true
                        }
                    }
                }
            }
        )
        //alert for a failed qr code scan
        .alert("Ivalid QR Code", isPresented: $failedScanAlert) {
            Button("OK", role: .cancel) {
                self.isPresentingScanner = false
            }
        } message: {
            Text("Could not find the needed data in the scanned QR Code")
        }
    }
    //main view
    var body: some View {
        VStack {
            HStack {
                //custom back button
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                Spacer()
                Text("Dive Event")
                    .padding(.trailing)
                    .padding(.trailing)
                Spacer()
                //opens the qr scanner
                Button {
                    self.isPresentingScanner = true
                } label: {
                    VStack {
                        Image(systemName: "qrcode")
                            .interpolation(.none).resizable().frame(width: 25, height: 25)
                        Text("Scan")
                            .padding(-8)
                    }
                }
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .sheet(isPresented: $isPresentingScanner) {
                    self.ScannerSheet
                }
            }
            .padding()
            .background(colorScheme == .dark ? Color(red: 1, green: 1, blue: 1, opacity: 0.2) : Color(red: 0, green: 0, blue: 0, opacity: 0.1))
            .padding(5)
            VStack {
                HStack {
                    Text("Date")
                    Spacer()
                    //make date picker
                    if taskComplete {
                        DatePicker("", selection: $date, displayedComponents: [.date])
                            .onChange(of: date) { _ in
                                entry.eventDate = date.formatted(date: .numeric, time: .omitted)
                                coachEntryStore.saveDiverEntry()
                            }
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
                    //location textfield
                    TextField("Enter Location", text: $location)
                        .onChange(of: location) { _ in
                            entry.location = location
                            coachEntryStore.saveDiverEntry()
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
            
            Text("Dive Entries")
                .font(.title.bold())
            //list of all of the diver entries separated by their level
            List {
                //varsity divers
                DisclosureGroup("Varsity") {
                    ForEach(Array(zip(entry.diverEntries.indices, entry.diverEntries)), id: \.0) { index, diver in
                        if diver.level == 2 {
                            //goes to diver editor
                            NavigationLink(destination: DiverEditorView(selectedCoachEntryIndex: coachListIndex, selectedDiverEntryIndex: index, eventDate: entry.eventDate)) {
                                    HStack {
                                        Text("\(index + 1)")
                                            .padding(5)
                                            .background(
                                                Circle()
                                                    .stroke(lineWidth: 2)
                                            )
                                    Text(diver.name)
                                }
                            }
                            .id(UUID())
                        }
                    }
                    .onDelete(perform: deleteDiver)
                }
                //junior varsity divers
                DisclosureGroup("Junior Varsity") {
                    ForEach(Array(zip(entry.diverEntries.indices, entry.diverEntries)), id: \.0) { index, diver in
                        if diver.level == 1 {
                            //goes to diver editor
                            NavigationLink(destination: DiverEditorView(selectedCoachEntryIndex: coachListIndex, selectedDiverEntryIndex: index, eventDate: entry.eventDate)) {
                                    HStack {
                                        Text("\(index + 1)")
                                            .padding(5)
                                            .background(
                                                Circle()
                                                    .stroke(lineWidth: 2)
                                            )
                                    Text(diver.name)
                                }
                            }
                            .id(UUID())
                        }
                    }
                    .onDelete(perform: deleteDiver)
                    
                }
                //exhibition divers
                DisclosureGroup("Exhibition") {
                    ForEach(Array(zip(entry.diverEntries.indices, entry.diverEntries)), id: \.0) { index, diver in
                        if diver.level == 0 {
                            //goes to diver editor
                            NavigationLink(destination: DiverEditorView(selectedCoachEntryIndex: coachListIndex, selectedDiverEntryIndex: index, eventDate: entry.eventDate)) {
                                    HStack {
                                        Text("\(index + 1)")
                                            .padding(5)
                                            .background(
                                                Circle()
                                                    .stroke(lineWidth: 2)
                                            )
                                    Text(diver.name)
                                }
                            }
                            .id(UUID())
                        }
                    }
                    .onDelete(perform: deleteDiver)
                    
                }
                if hasUnfinishedDivers() {
                    //shows all newly created divers with incomplete entries
                    DisclosureGroup("Unfinished diver entries") {
                        ForEach(Array(zip(entry.diverEntries.indices, entry.diverEntries)), id: \.0) { index, diver in
                            if diver.finishedEntry == nil || diver.finishedEntry == false {
                                //goes to the diver editor
                                NavigationLink(destination: DiverEditorView(selectedCoachEntryIndex: coachListIndex, selectedDiverEntryIndex: index, eventDate: entry.eventDate)) {
                                    HStack {
                                        Text("\(index + 1)")
                                            .padding(5)
                                            .background(
                                                Circle()
                                                    .stroke(lineWidth: 2)
                                            )
                                        Text(diver.name)
                                    }
                                }
                                .id(UUID())
                            }
                        }
                        .onDelete(perform: deleteDiver)
                        
                    }
                }
            }
            //adds an unfinished diver entry
            Button {
                coachEntryStore.coachesList[coachListIndex].diverEntries.append(diverEntry(dives: [], level: -1, name: "", finishedEntry: false))
            } label: {
                Text("Add Diver")
                    .padding(7)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .background(
                        Rectangle()
                            .stroke(lineWidth: 2)
                    )
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            //opens the qr code image for the divers event
            Button {
                coachEntryStore.saveDiverEntry()
                showQRCodeSheet = true
            } label: {
                HStack {
                    Text("Finish and Give to Scorekeeper")
                        .padding(7)
                        .background(
                            Rectangle()
                                .stroke(lineWidth: 2)
                        )
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
            .disabled(entry.location != "" && entry.diverEntries.isEmpty) //button is disabled if there is no location or no divers
            //qr code image view
            .sheet(isPresented: $showQRCodeSheet) {
                CoachEntryQRCodeView(code: findQRCode())
            }
        }
        .onAppear {
            //sets the date to the current date if there is not another date selected
            if entry.eventDate.isEmpty {
                entry.eventDate = Date().formatted(date: .numeric, time: .omitted)
            }
        }
        .navigationBarBackButtonHidden(true) //disables the default back button
        .task {
            //sets the location
            if entry.location != nil {
                location = entry.location ?? ""
            }
            taskComplete = true
        }
    }
    //encodes the coaches entry into json and compresses it and returns the compressed data in string form
    func findQRCode() -> String {
        var coachEntry = coachEntry(diverEntries: [], eventDate: entry.eventDate, team: entry.team, version: 0)
        coachEntry.diverEntries = []
        for diver in 0..<entry.diverEntries.count {
            //diverEntry assembly
            var diveEntries = diverEntry(dives: [], level: entry.diverEntries[diver].level, name: entry.diverEntries[diver].name)
            
            
            for dive in 0..<entry.diverEntries[diver].dives.count {
                diveEntries.dives.append(entry.diverEntries[diver].fullDives![dive].code ?? "")
            }
            diveEntries.volentary = []
            for dive in 0..<entry.diverEntries[diver].fullDives!.count {
                diveEntries.volentary!.append(entry.diverEntries[diver].fullDives![dive].volentary ?? false)
                
            }
            coachEntry.diverEntries.append(diveEntries)
        }
        let encoder = JSONEncoder()
        let data = try! encoder.encode(coachEntry)
        let optimizedData : Data = try! data.gzipped(level: .bestCompression)
        return optimizedData.base64EncodedString()
    }
    //removes a diver from the entry at the given index
    func deleteDiver(at offsets: IndexSet) {
        entry.diverEntries.remove(atOffsets: offsets)
        coachEntryStore.saveDiverEntry()
    }
    //returns true if all divers have finished entries otherwise returns false
    func hasUnfinishedDivers() -> Bool {
        for diver in entry.diverEntries {
            if diver.finishedEntry == false {
                return true
            }
        }
        return false
    }
    //puts the dives from the persistant data into the divelist and fillsn out the full dive details
    func findDives(diverIndex: Int) {
        var diveList: [dives] = []
        var diveCodeCount = 0
        for diveCode in entry.diverEntries[diverIndex].dives {
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
                                    diveList.append(dives(name: fetchedDive.diveName ?? "", degreeOfDiff: fetchedWithPosition.degreeOfDifficulty, score: [], position: fetchedPosition.positionName ?? "", roundScore: 0, code: diveCode, volentary: entry.diverEntries[diverIndex].volentary![diveCodeCount]))
                                }
                            }
                        }
                    }
                }
            }
            diveCodeCount += 1
        }
        entry.diverEntries[diverIndex].fullDives = diveList
    }
}

struct CoachDiveEventView_Previews: PreviewProvider {
    static var previews: some View {
        CoachDiveEventView(name: "name", team: "Team", coachListIndex: 0, entry: .constant(coachEntry(diverEntries: [diverEntry(dives: [], level: 1, name: "Name")], eventDate: "Date", team: "Team", version: 0)))
    }
}
