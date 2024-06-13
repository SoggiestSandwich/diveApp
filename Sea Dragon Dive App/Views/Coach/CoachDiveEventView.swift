//
//  CoachDiveEventView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/15/23.
//

import SwiftUI
import CodeScanner

struct CoachDiveEventView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var coachEntryStore: CoachEntryStore
    
    @State var failedScanAlert = false
    @State var isPresentingScanner = false
    @State private var scannedCode: String = ""
    @State private var date: Date = Date()
    @State private var location: String = ""
    @State private var showQRCodeSheet = false
    @State var name: String
    @State var team: String
    @State var taskComplete: Bool = false
    @State var coachListIndex: Int
    
    
    @Binding var coachList: coachEntry
    
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
                        var entries = try? decoder.decode(diverEntry.self, from: jsonCode)
                        if entries != nil {
                            entries!.finishedEntry = true
                            
                            coachList.diverEntries.append(entries!)
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
        VStack {
            HStack {
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
                                coachList.eventDate = date.formatted(date: .numeric, time: .omitted)
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
                    TextField("Enter Location", text: $location)
                        .onChange(of: location) { _ in
                            coachList.location = location
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
            List {
                DisclosureGroup("Varsity") {
                    ForEach(Array(zip(coachList.diverEntries.indices, coachList.diverEntries)), id: \.0) { index, diver in
                        if diver.level == 2 {
                            NavigationLink(destination: DiverEditorView(selectedCoachEntryIndex: coachListIndex, selectedDiverEntryIndex: index, eventDate: coachList.eventDate)) {
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
                DisclosureGroup("Junior Varsity") {
                    ForEach(Array(zip(coachList.diverEntries.indices, coachList.diverEntries)), id: \.0) { index, diver in
                        if diver.level == 1 {
                            NavigationLink(destination: DiverEditorView(selectedCoachEntryIndex: coachListIndex, selectedDiverEntryIndex: index, eventDate: coachList.eventDate)) {
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
                DisclosureGroup("Exhibition") {
                    ForEach(Array(zip(coachList.diverEntries.indices, coachList.diverEntries)), id: \.0) { index, diver in
                        if diver.level == 0 {
                            NavigationLink(destination: DiverEditorView(selectedCoachEntryIndex: coachListIndex, selectedDiverEntryIndex: index, eventDate: coachList.eventDate)) {
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
                    DisclosureGroup("Unfinished diver entries") {
                        ForEach(Array(zip(coachList.diverEntries.indices, coachList.diverEntries)), id: \.0) { index, diver in
                            if diver.finishedEntry == nil || diver.finishedEntry == false {
                                NavigationLink(destination: DiverEditorView(selectedCoachEntryIndex: coachListIndex, selectedDiverEntryIndex: index, eventDate: coachList.eventDate)) {
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
            .disabled(coachList.location != "" && coachList.diverEntries.isEmpty)
            .sheet(isPresented: $showQRCodeSheet) {
                CoachEntryQRCodeView(url: findQRCode())
            }
        }
        .onAppear {
            if coachList.eventDate.isEmpty {
                coachList.eventDate = Date().formatted(date: .numeric, time: .omitted)
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            if coachList.location != nil {
                location = coachList.location ?? ""
            }
            taskComplete = true
        }
    }
    func findQRCode() -> String {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(coachList)
        let optimizedData : Data = try! data.gzipped(level: .bestCompression)
        return optimizedData.base64EncodedString()
    }
    func deleteDiver(at offsets: IndexSet) {
        coachList.diverEntries.remove(atOffsets: offsets)
        coachEntryStore.saveDiverEntry()
    }
    func hasUnfinishedDivers() -> Bool {
        for diver in coachList.diverEntries {
            if diver.finishedEntry == false {
                return true
            }
        }
        return false
    }
}

struct CoachDiveEventView_Previews: PreviewProvider {
    static var previews: some View {
        CoachDiveEventView(name: "name", team: "Team", coachListIndex: 0, coachList: .constant(coachEntry(diverEntries: [diverEntry(dives: [], level: 1, name: "Name")], eventDate: "Date", team: "Team", version: 0)))
    }
}
