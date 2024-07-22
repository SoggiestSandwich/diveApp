//
//  CoachEventSelectionView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/15/23.
//

import SwiftUI
import CodeScanner
import Gzip

struct CoachEventSelectionView: View {
    @Environment(\.colorScheme) var colorScheme //detects if the device is in dark mode
    
    @EnvironmentObject var coachEntryStore: CoachEntryStore //persistant data of coach entries
    
    @State var name: String //coaches name
    @State var team: String //coaches school/team name
    @State var failedScanAlert = false //triggers an alert when a qr code scan fails
    @State var isPresentingScanner = false //opens the qr scanner
    @State private var scannedCode: String = "" //the string read from the qr code
    @State var selectedCoachEntryIndex: Int = -1 //the index of the entry being selected
    @Binding var path: [String]
    
    //simple struct for holding identifiable codes
    struct Codes: Identifiable {
        let name: String
        let id = UUID()
    }
    //qr scanner
    var ScannerSheet : some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                //stores the code into tempCodes on a sucessful scan
                if case let .success(code) = result {
                    let tempCodes = Codes(name: code.string)
                    //if it scans a non-empty string it will attempt to uncompress to json then decode the json into a coachEntry
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
                        //if the code can be turned into a coaschEntry sets the loacation and finished
                        if entries != nil && entries?.team == coachEntryStore.coachesList[selectedCoachEntryIndex].team{
                            let tempLocation = coachEntryStore.coachesList[selectedCoachEntryIndex].location
                            coachEntryStore.coachesList[selectedCoachEntryIndex] = entries!
                            coachEntryStore.coachesList[selectedCoachEntryIndex].location = tempLocation
                            coachEntryStore.coachesList[selectedCoachEntryIndex].finished = true
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
        //alert for a failed scan
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
        VStack(alignment: .leading) {
            HStack {
                //button that brings you back to the login view
                Button {
                    path = []
                } label: {
                    Image(systemName: "gearshape.fill")
                        .interpolation(.none).resizable().frame(width: UIScreen.main.bounds.size.height * 0.03, height: UIScreen.main.bounds.size.height * 0.03)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                Spacer()
                Text(name)
                    .font(.title.bold())
            }
            .padding()
            .background(colorScheme == .dark ? Color(red: 1, green: 1, blue: 1, opacity: 0.2) : Color(red: 0, green: 0, blue: 0, opacity: 0.1))
            .padding(5)
            Spacer()
            Text("Current Events")
                .font(.title)
                .padding(.horizontal)
            //list of all non-finished coach entries
            List {
                if !coachEntryStore.coachesList.isEmpty {
                    ForEach(Array(zip(coachEntryStore.coachesList.indices, coachEntryStore.coachesList)), id: \.0) { index, coach in
                        if coach.finished != true {
                            HStack {
                                Text(coach.eventDate)
                                Divider()
                                //goes to the view for editing coach entries
                                NavigationLink(destination: CoachDiveEventView(name: name, team: team, coachListIndex: index, entry: $coachEntryStore.coachesList[index])) {
                                    if coach.location == nil {
                                        Text("New dive event")
                                    }
                                    else {
                                        Text(coach.location ?? "")
                                    }
                                    //button that opens the qr code scanner
                                    Text("Scan Results")
                                        .padding(5)
                                        .background (
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(lineWidth: 2)
                                        )
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .onTapGesture {
                                        selectedCoachEntryIndex = index
                                        self.isPresentingScanner = true
                                    }
                                }
                                //qr code canner sheet
                                .sheet(isPresented: $isPresentingScanner) {
                                    self.ScannerSheet
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteEvent)
                }
                //adds a coach entry to the coach entry persistant data
                Button {
                    coachEntryStore.addCoachEntry(coachEntry(diverEntries: [], eventDate: "", team: team, version: 0))
                    coachEntryStore.saveDiverEntry()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Create a new dive event")
                    }
                }
                .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            Text("Past Events")
                .font(.title)
                .padding(.horizontal)
            List {
                //list of past events
                if !coachEntryStore.coachesList.isEmpty {
                    ForEach(coachEntryStore.coachesList, id: \.hashValue) { coach in
                        if coach.finished == true {
                            NavigationLink(destination: CoachResultsView(entry: coach)) {
                                HStack {
                                    Text(coach.eventDate)
                                    Divider()
                                    Text(coach.location ?? "")
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteEvent)
                }
            }
        }
        .navigationBarBackButtonHidden(true) //removes the default back button
    }
    //removes a coach entry from the coach entry persistant data at the entered index
    func deleteEvent(at offsets: IndexSet) {
        coachEntryStore.coachesList.remove(atOffsets: offsets)
        coachEntryStore.saveDiverEntry()
    }
}

struct CoachEventSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CoachEventSelectionView(name: "Name", team: "Team", path: .constant([]))
            .environmentObject(CoachEntryStore())
    }
}
