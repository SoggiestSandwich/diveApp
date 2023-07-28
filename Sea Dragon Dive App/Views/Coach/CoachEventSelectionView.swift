//
//  CoachEventSelectionView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/15/23.
//

import SwiftUI
import CodeScanner

struct CoachEventSelectionView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var coachEntryStore: CoachEntryStore
    
    @State var name: String
    @State var team: String
    @State var failedScanAlert = false
    @State var isPresentingScanner = false
    @State private var scannedCode: String = ""
    @State var selectedCoachEntryIndex: Int = -1
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
                        let jsonCode = tempCodes.name.data(using: .utf8)!
                        let decoder = JSONDecoder()
                        let entries = try? decoder.decode(coachEntry.self, from: jsonCode)
                        if entries != nil {
                            coachEntryStore.coachesList[selectedCoachEntryIndex] = entries!
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
        .alert("Ivalid QR Code", isPresented: $failedScanAlert) {
            Button("OK", role: .cancel) {
                self.isPresentingScanner = false
            }
        } message: {
            Text("Could not find the needed data in the scanned QR Code")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
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
            List {
                if !coachEntryStore.coachesList.isEmpty {
                    ForEach(Array(zip(coachEntryStore.coachesList.indices, coachEntryStore.coachesList)), id: \.0) { index, coach in
                        if coach.finished != true {
                            HStack {
                                Text(coach.eventDate)
                                Divider()
                                NavigationLink(destination: CoachDiveEventView(name: name, team: team, coachListIndex: index, coachList: $coachEntryStore.coachesList[index])) {
                                    if coach.location == nil {
                                        Text("New dive event")
                                    }
                                    else {
                                        Text(coach.location ?? "")
                                    }
                                    Button {
                                    } label: {
                                        Text("Scan Results")
                                            .padding(5)
                                            .background (
                                                RoundedRectangle(cornerRadius: 5)
                                                    .stroke(lineWidth: 2)
                                            )
                                    }
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .onTapGesture {
                                        selectedCoachEntryIndex = index
                                        self.isPresentingScanner = true
                                    }
                                }
                                .sheet(isPresented: $isPresentingScanner) {
                                    self.ScannerSheet
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteEvent)
                }
                //list of current events
                Button {
                    coachEntryStore.addDiverEntry(coachEntry(diverEntries: [], eventDate: "", team: team, version: 0))
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
                            NavigationLink(destination: CoachResultsView(coachList: coach)) {
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
        .navigationBarBackButtonHidden(true)
    }
    
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
