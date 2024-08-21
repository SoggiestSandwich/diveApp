//
//  DiverHomeView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/24/23.
//

import SwiftUI
import CodeScanner

struct DiverHomeView: View {
    //fetches from the database
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.diveNbr)
    ]) var fetchedDives: FetchedResults<Dive>
    @FetchRequest(entity: Position.entity(), sortDescriptors: []) var fetchedPositions: FetchedResults<Position>
    @FetchRequest(entity: WithPosition.entity(), sortDescriptors: []) var fetchedWithPositions: FetchedResults<WithPosition>
    
    //detects device orientation
    @Environment(\.verticalSizeClass) var verticalSizeClass
    //detects if dark mode or not
    @Environment(\.colorScheme) var colorScheme
    //used to go back to login screen
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    //persistent data for the diver
    @EnvironmentObject var diverStore: DiverStore
    
    //state variables
    @State var username: String
    @State var userSchool: String
    @State private var isPresentingScanner = false
    @State private var code: String = ""
    @State private var value = ""
    @State private var scannedCode: String = ""
    @State private var failedScanAlert: Bool = false
    @State private var nonMatchingScan: Bool = false
    @State private var misMatchDiveAlert: Bool = false
    @State private var selectedEntry: divers = divers(dives: [], diverEntries: diverEntry(dives: [], level: 0, name: ""))
    @State private var selectedEntryIndex: Int = -1
    @State private var entries: diverEntry? = nil
    
    //simple struct for holding the string from qr codes
    struct Codes: Identifiable {
        let name: String
        let id = UUID()
    }
    
    //sheet using a view that reads qr codes
    var ScannerSheet : some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                if case let .success(code) = result {
                    self.scannedCode = code.string
                    
                    let tempCodes = Codes(name: code.string)
                    if tempCodes.name != "" {
                        nonMatchingScan = false
                        let  base64Data = tempCodes.name.data(using: .utf8)
                        let data = Data(base64Encoded: base64Data!)
                        //let result = String(data: data!, encoding: .utf8)
                        let compressedJsonCode = data
                        //uncompress data
                        let jsonCode: Data
                        if compressedJsonCode!.isGzipped {
                            jsonCode = try! compressedJsonCode!.gunzipped()
                            print(String(data: jsonCode, encoding: .utf8) ?? "")
                        }
                        else {
                            jsonCode = compressedJsonCode!
                        }
                        let decoder = JSONDecoder()
                        entries = try? decoder.decode(diverEntry.self, from: jsonCode)
                        if entries != nil {
                            //create new entry with scanned results or edit old entry
                            for dive in 0..<selectedEntry.dives.count {
                                if selectedEntry.dives[dive].code! != entries!.scoringDives![dive].diveId && !nonMatchingScan {
                                    misMatchDiveAlert = true
                                }
                            }
                            if !misMatchDiveAlert {
                                addScores(entries: entries!)
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
        //invalid qr code alert
        .alert("Ivalid QR Code", isPresented: $failedScanAlert) {
            Button("OK", role: .cancel) {self.isPresentingScanner = false}
        } message: {
            Text("Could not find the needed data in the scanned QR Code")
        }
        //dive error alert
        .alert("Dives Don't Match", isPresented: $misMatchDiveAlert) {
            Button("Cancel", role: .cancel) {
                nonMatchingScan = true
                self.isPresentingScanner = false
            }
            //replaces the old event with the scanned
            Button("Continue") {
                addScores(entries: entries!)
                nonMatchingScan = false
            }
        } message: {
            Text("One or more dives do not match between the scanned code and the entered dives would you like to continue and replace old dives?")
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                //custom back button
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .interpolation(.none).resizable().frame(width: UIScreen.main.bounds.size.height * 0.03, height: UIScreen.main.bounds.size.height * 0.03)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                Spacer()
                Text(username)
                    .font(.title2.bold())
            }
            .padding()
            .background(colorScheme == .dark ? Color(red: 1, green: 1, blue: 1, opacity: 0.2) : Color(red: 0, green: 0, blue: 0, opacity: 0.1))
            .padding(5)
            HStack {
                Text("Diver Statistics")
                    .font(.title.bold())
                    .padding(.horizontal)
                Spacer()
            }
            HStack {
                Text("Top 6 Dive Score:")
                Spacer()
                Text(String(format: "%.2f", top6DiveScore()))
            }
            .padding(.horizontal)
            HStack {
                Text("Top 11 Dive Score:")
                Spacer()
                Text(String(format: "%.2f", top11DiveScore()))
            }
            .padding(.horizontal)
            //send to BestDivesView
            NavigationLink(destination: BestDivesView()){
                HStack {
                    Text("Review My Best Dive Scores")
                        .font(.body.bold())
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding()
                .background(colorScheme == .dark ? Color(red: 1, green: 1, blue: 1, opacity: 0.2) : Color(red: 0, green: 0, blue: 0, opacity: 0.1))
                .padding(5)
            }
            //allows the vertical arrangement switch to horizontal when the device is turned
            adaptiveStack(horizontalStack: verticalSizeClass == .regular ? false : true) {
                VStack {
                    HStack {
                        Text("Dive Entries")
                            .font(.title.bold())
                            .padding(.horizontal)
                        Spacer()
                    }
                    if diverStore.entryList.isEmpty {
                        Text("No current dive entries")
                    }
                    //list of unfinished dive entries
                    List {
                        if !diverStore.entryList.isEmpty{
                            ForEach(Array(zip(diverStore.entryList.indices, diverStore.entryList)), id: \.0) { index, entry in
                                if entry.finished != true {
                                    //each entry is a navigationLink to the DiveEntryView
                                    NavigationLink(destination: DiveEntryView(entry: $diverStore.entryList[index])) {
                                        //the the entry is fully filled out it shows entry with a button to scan the results
                                        if !diverStore.entryList[index].dives.isEmpty && diverStore.entryList[index].diverEntries.level != -1 && diverStore.entryList[index].location != nil {
                                            HStack {
                                                Text(diverStore.entryList[index].date?.formatted(date: .abbreviated, time: .omitted) ?? Date().formatted(date: .abbreviated, time: .omitted))
                                                    .frame(width: 60)
                                                Divider()
                                                VStack {
                                                    HStack {
                                                        Image(systemName: "location.fill")
                                                        Text(diverStore.entryList[index].location ?? "")
                                                    }
                                                    //shows if the entry is valid
                                                    if entry.dq == true {
                                                        Text("Invalid Entry")
                                                            .foregroundColor(Color.purple)
                                                    }
                                                }
                                                Spacer()
                                                //brings up the qr scanner to scan in results
                                                Button {
                                                    self.isPresentingScanner = true
                                                } label: {
                                                    Text("Scan Results After Event")
                                                        .padding(5)
                                                        .multilineTextAlignment(.center)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 15)
                                                                .stroke(lineWidth: 2)
                                                        )
                                                        .onTapGesture {
                                                            selectedEntry = diverStore.entryList[index]
                                                            selectedEntryIndex = index
                                                            self.isPresentingScanner = true
                                                        }
                                                }
                                            }
                                        }
                                        //if entry is missing anything  it shows as a new entry
                                        else {
                                            HStack {
                                                Text("\(Date().formatted(date: .abbreviated, time: .omitted))")
                                                    .frame(width: 60)
                                                Divider()
                                                Text("New Dive Entry")
                                            }
                                        }
                                    }
                                }
                            }
                            .onDelete(perform: diverStore.deleteDiver)
                        }
                        //adds an empty diver to the persistant diver data
                        Button {
                            diverStore.addDiver(divers(dives: [], diverEntries: diverEntry(dives: [], level: -1, name: username)))
                        } label: {
                            Rectangle()
                                .stroke(colorScheme == .dark ? .white : .black, lineWidth: 2)
                                .padding(.horizontal)
                                .padding(.horizontal)
                                .padding(.horizontal)
                                .padding(.horizontal)
                                .overlay(
                                    HStack {
                                        Image(systemName: "plus.circle")
                                        Text("Create a Dive Entry")
                                            .font(.body.bold())
                                    }
                                )
                        }
                    }
                    .listStyle(InsetListStyle())
                    .scrollContentBackground(.hidden)
                }
                VStack {
                    HStack {
                        Text("Past Events")
                            .font(.title.bold())
                            .padding(.horizontal)
                        Spacer()
                    }
                    //list of finished entries
                    List {
                        //if no entries are finished it shown that there are no past events
                        if diverStore.entryList.isEmpty {
                            Text("No past events")
                                .font(.body.bold())
                                .listRowBackground(colorScheme == .dark ? Color(red: 1, green: 1, blue: 1, opacity: 0.2) : Color(red: 0, green: 0, blue: 0, opacity: 0.1))
                        }
                        else {
                            ForEach(Array(zip(diverStore.entryList.indices, diverStore.entryList)), id: \.0) { index, entry in
                                if entry.finished == true {
                                    //each finished entry has a navigaionLink to view the results of the event
                                    NavigationLink(destination: EventResultsView(entry: entry)) {
                                        if !diverStore.entryList[index].dives.isEmpty && diverStore.entryList[index].diverEntries.level != -1 && diverStore.entryList[index].location != nil {
                                            HStack {
                                                Text(diverStore.entryList[index].date?.formatted(date: .abbreviated, time: .omitted) ?? Date().formatted(date: .abbreviated, time: .omitted))
                                                    .frame(width: 60)
                                                Divider()
                                                VStack {
                                                    HStack {
                                                        Image(systemName: "location.fill")
                                                        Text(diverStore.entryList[index].location ?? "")
                                                    }
                                                    Text(String(format: "%.2f", diverStore.entryList[index].diverEntries.totalScore ?? 0))
                                                }
                                                Spacer()
                                            }
                                        }
                                        else {
                                            Text("Edit Dive Entry")
                                        }
                                    }
                                }
                            }
                            .onDelete(perform: diverStore.deleteDiver)
                            .listRowBackground(colorScheme == .dark ? Color(red: 1, green: 1, blue: 1, opacity: 0.2) : Color(red: 0, green: 0, blue: 0, opacity: 0.1))
                        }
                    }
                    .listStyle(InsetListStyle())
                    .scrollContentBackground(.hidden)
                }
                .navigationBarBackButtonHidden(true) //deletes default back button
                //qr code scanner sheet
                .sheet(isPresented: $isPresentingScanner) {
                    self.ScannerSheet
                }
            }
        }
    }
    //finds the entry with the greatest total score and returns that score for six dive entries
    func top6DiveScore() -> Double {
        var highestScore: Double = 0
        for entry in diverStore.entryList {
            if entry.finished == true && entry.diverEntries.totalScore ?? 0 > highestScore && entry.dives.count == 6 {
                highestScore = entry.diverEntries.totalScore ?? 0
            }
        }
        return highestScore
    }
    //finds the entry with the greatest total score and returns that score for eleven dive entries
    func top11DiveScore() -> Double {
        var highestScore: Double = 0
        for entry in diverStore.entryList {
            if entry.finished == true && entry.diverEntries.totalScore ?? 0 > highestScore && entry.dives.count == 11 {
                highestScore = entry.diverEntries.totalScore ?? 0
            }
        }
        return highestScore
    }
    //
    func addScores(entries: diverEntry) {
        for result in 0..<entries.scoringDives!.count {
            if entries.scoringDives![result].diveId != selectedEntry.dives[result].code {
                //finds and replaces nonmatching dives
                var diveNbr = entries.scoringDives![result].diveId
                diveNbr!.removeLast()
                for fetchedDive in fetchedDives {
                    if Int(diveNbr!)! == fetchedDive.diveNbr {
                        selectedEntry.dives[result].name = fetchedDive.diveName ?? ""
                        var divePos = entries.scoringDives![result].diveId
                        while divePos!.count > 1 {
                            divePos!.removeFirst()
                        }
                        for fetchedPosition in fetchedPositions {
                            if divePos == fetchedPosition.positionCode {
                                selectedEntry.dives[result].position = fetchedPosition.positionName ?? ""
                                for fetchedWithPosition in fetchedWithPositions {
                                    if fetchedDive.diveNbr == fetchedWithPosition.diveNbr && fetchedPosition.positionId == fetchedWithPosition.positionId {
                                        selectedEntry.dives[result].degreeOfDiff = fetchedWithPosition.degreeOfDifficulty
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        selectedEntry.placement = entries.placement
        selectedEntry.finished = true
        selectedEntry.diverEntries.totalScore = 0
        for dive in 0..<selectedEntry.dives.count {
            //adds the scores from results to the entry
            for score in entries.scoringDives![dive].scores {
                var count = 0
                selectedEntry.dives[dive].score.append(scores(score: Double(score)!, index: count))
                count += 1
            }
            selectedEntry.dives[dive].roundScore = entries.scoringDives![dive].diveTotal
        }
        selectedEntry.diverEntries.totalScore = entries.totalScore
        
        //sets the entry into the persistant data and saves it
        diverStore.entryList[selectedEntryIndex] = selectedEntry
        diverStore.saveDivers()
        self.isPresentingScanner = false //close qr scanner
    }
}

struct DiverHomeView_Previews: PreviewProvider {
    static var previews: some View {
        DiverHomeView(username: "Kakaw", userSchool: "School")
            .environmentObject(DiverStore())
    }
}
