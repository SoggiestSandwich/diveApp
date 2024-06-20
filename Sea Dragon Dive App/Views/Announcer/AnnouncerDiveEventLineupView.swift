//
//  AnnouncerDiveEventLineupView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/13/24.
//

import SwiftUI
import CodeScanner //used for reading qr code

struct AnnouncerDiveEventLineupView: View {
    @Environment(\.colorScheme) var colorScheme //detects if in dark mode
    
    @FetchRequest(entity: Dive.entity(), sortDescriptors: []) var fetchedDives: FetchedResults<Dive> //the dive table from the database
    @FetchRequest(entity: Position.entity(), sortDescriptors: []) var fetchedPositions: FetchedResults<Position> //the position table from the database
    @FetchRequest(entity: WithPosition.entity(), sortDescriptors: []) var fetchedWithPositions: FetchedResults<WithPosition> //the withPosition table of the database
    
    @EnvironmentObject var announcerEventStore: AnnouncerEventStore //the persistant Announcer data
    
    @State var failedScanAlert: Bool = false //used to bring up a failed scan alert
    @State private var scannedCode: String = "" //the code that is scanned from the qr code
    @State var isPresentingScanner = false //used to bring up the scanner sheet
    @State var diverList: [diverEntry] = [] //list of divers in the event that are displayed when scanned in
    
    @Binding var path: [String] //the navigation stack's path used to go back to the login view

    //the code scanned in
    struct Codes: Identifiable {
        let name: String
        let id = UUID()
    }
    
    //the sheet used to scan in qr codes
    var ScannerSheet: some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                if case let .success(code) = result {
                    self.scannedCode = code.string //on a successful scan the code is taken into scannedCode
                    
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
                        //decodes the json to announcerEvent
                        let decoder = JSONDecoder()
                        let entries = try? decoder.decode(announcerEvent.self, from: jsonCode)
                        if entries != nil {
                            announcerEventStore.event = entries!
                            announcerEventStore.saveEvent()
                            
                            //assembles diverlist based off of the announcer event store
                            diverList = []
                            for diver in 0..<announcerEventStore.event.diver.count {
                                diverList.append(diverEntry(dives: announcerEventStore.event.diver[diver].dives, level: -1, name: announcerEventStore.event.diver[diver].name, team: announcerEventStore.event.diver[diver].school))
                                diverList[diver].fullDives = []
                                //finds the dives details based off of the code
                                for dive in announcerEventStore.event.diver[diver].dives {
                                    var name: String = ""
                                    var positionId: Int64 = -1
                                    var positionName: String = ""
                                    var dOD: Double = 0.0
                                    var number = dive
                                    number.removeLast()
                                    var letter = dive
                                    while letter.count > 1 {
                                        letter.removeFirst()
                                    }
                                    for fetchedDive in fetchedDives {
                                        if fetchedDive.diveNbr == Int(number)! {
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
                                        if fetchedWithPosition.positionId == positionId && fetchedWithPosition.diveNbr == Int(number)! {
                                            dOD = fetchedWithPosition.degreeOfDifficulty
                                        }
                                    }
                                    diverList[diver].fullDives?.append(dives(name: name, degreeOfDiff: dOD, score: [], position: positionName, roundScore: 0))
                                }
                            }
                            
                            self.isPresentingScanner = false //closes the qr reader
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
    
    //main view
    var body: some View {
        VStack {
            HStack {
                Button {
                    path = [] //go back to login view
                } label: {
                    Image(systemName: "gearshape.fill")
                        .interpolation(.none).resizable().frame(width: UIScreen.main.bounds.size.height * 0.03, height: UIScreen.main.bounds.size.height * 0.03)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                Spacer()
            }
            .padding()
            .background(colorScheme == .dark ? Color(red: 1, green: 1, blue: 1, opacity: 0.2) : Color(red: 0, green: 0, blue: 0, opacity: 0.1))
            .padding(5)
            Spacer()
            List {
                ForEach(Array(zip(announcerEventStore.event.diver.indices, announcerEventStore.event.diver)), id: \.0) { index, diver in
                    VStack(alignment: .leading) {
                        Text("\(index + 1). \(diver.name)")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Text("\(diver.school)")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                }
            }
            Spacer()
            Button {
                //opens qr scanner to scan in divers
                self.isPresentingScanner = true
            } label: {
                Text("Import New Dive Event")
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
            NavigationLink("Start Event", destination: AnnounceDiveView(firstDiverIndex: 0, lastDiverIndex: diverList.count - 1, diverList: $diverList))
                    .foregroundColor(announcerEventStore.event.diver.isEmpty ? .gray : colorScheme == .dark ? .white : .black)
                    .bold()
                    .padding(15)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(announcerEventStore.event.diver.isEmpty ? .gray : colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                    )
            
        }
        .onAppear {
            if announcerEventStore.event.diver.isEmpty {
                self.isPresentingScanner = true //opens the scanner if there is not an event when you reach this view
            }
        }
        .task {
            //assembles a list of divers from the persistant data
            if !announcerEventStore.event.diver.isEmpty {
                diverList = []
                for diver in 0..<announcerEventStore.event.diver.count {
                    diverList.append(diverEntry(dives: announcerEventStore.event.diver[diver].dives, level: -1, name: announcerEventStore.event.diver[diver].name, team: announcerEventStore.event.diver[diver].school))
                    diverList[diver].fullDives = []
                    //assembles the dive details based on the dive codes
                    for dive in announcerEventStore.event.diver[diver].dives {
                        var name: String = ""
                        var positionId: Int64 = -1
                        var positionName: String = ""
                        var dOD: Double = 0.0
                        var number = dive
                        number.removeLast()
                        var letter = dive
                        while letter.count > 1 {
                            letter.removeFirst()
                        }
                        for fetchedDive in fetchedDives {
                            if fetchedDive.diveNbr == Int(number)! {
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
                            if fetchedWithPosition.positionId == positionId && fetchedWithPosition.diveNbr == Int(number)! {
                                dOD = fetchedWithPosition.degreeOfDifficulty
                            }
                        }
                        diverList[diver].fullDives?.append(dives(name: name, degreeOfDiff: dOD, score: [], position: positionName, roundScore: 0))
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentingScanner) {
            self.ScannerSheet //qr scanner
        }
        .navigationBarBackButtonHidden(true) //removes default back button
    }
}

#Preview {
    AnnouncerDiveEventLineupView(path: .constant([]))
        .environmentObject(AnnouncerEventStore())
}
