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
    
    @FetchRequest(entity: Dive.entity(), sortDescriptors: []) var fetchedDives: FetchedResults<Dive>
    @FetchRequest(entity: Position.entity(), sortDescriptors: []) var fetchedPositions: FetchedResults<Position>
    @FetchRequest(entity: WithPosition.entity(), sortDescriptors: []) var fetchedWithPositions: FetchedResults<WithPosition>
    
    @State private var isPresentingScanner = false
    @State private var code: String = ""
    @State private var value = ""
    @State private var scannedCode: String = ""
    @State private var coachList: [coachEntry] = []
    @State private var JVList: [diverEntry] = []
    @State private var VList: [diverEntry] = []
    @State private var EList: [diverEntry] = []
    @State private var allDivers: [diverEntry] = []
    @State private var diversWithDives: [divers] = []
    @State private var editingList = true
    @State private var showPopUp = false
    @State private var showAlert = false
    
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
                            if checkCodeValidity(entry: entries!) {
                                coachList = []
                                coachList.append(entries!)
                                sortDivers()
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
                Text("No Divers Added")
                    .font(.largeTitle.bold())
                
                List {
                    Section(header: Text("Exhibition").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                        ForEach(Array(zip(EList.indices, EList)), id: \.0) { index, diver in
                            Text("\(index + 1). \(diver.name)\n\(diver.team!)")
                        }
                        .onDelete(perform: deleteEDiver)
                        .onMove { (indexSet, index) in
                            self.EList.move(fromOffsets: indexSet, toOffset: index)
                        }
                    }
                    Section(header: Text("Junior Varsity").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                        ForEach(Array(zip(JVList.indices, JVList)), id: \.1) { index, diver in
                            Text("\(index + EList.count + 1). \(diver.name)\n\(diver.team!)")
                        }
                        .onDelete(perform: deleteJVDiver)
                        .onMove { (indexSet, index) in
                            self.JVList.move(fromOffsets: indexSet, toOffset: index)
                        }
                    }
                    Section(header: Text("Varsity").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                        ForEach(Array(zip(VList.indices, VList)), id: \.1) { index, diver in
                            Text("\(index + EList.count + JVList.count + 1). \(diver.name)\n\(diver.team!)")
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
                .alert("Official's Approval Required", isPresented: $showPopUp) {
                    Button("Cancel", role: .cancel) {}
                    NavigationLink(destination: ScoreInfoView(diverList: diversWithDives)) {
                        Text("Confirm")
                    }
                } message: {
                    Text("Has an official reviewed the dive entries and diver order?")
                }
                .alert("You must enter divers before starting an event", isPresented: $showAlert) {
                    Button("OK", role: .cancel) {}
                }
            }
        }
    }
    
    func sortDivers() {
        for coach in coachList {
            for diver in coach.diverEntries {
                if diver.level == 0 {
                    EList.append(diver)
                    EList[EList.count - 1].team = coach.team
                    EList[EList.count - 1].score = 0
                }
                if diver.level == 1 {
                    JVList.append(diver)
                    JVList[JVList.count - 1].team = coach.team
                    JVList[JVList.count - 1].score = 0
                }
                if diver.level == 2 {
                    VList.append(diver)
                    VList[VList.count - 1].team = coach.team
                    VList[VList.count - 1].score = 0
                }
            }
        }
    }
    
    func consolidateDiverList() -> [diverEntry] {
        var allDivers: [diverEntry] = []
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
        for diver in consolidateDiverList() {
            var diveList: [dives] = []
            for dive in diver.dives {
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
                
                let newDive = dives(name: name, degreeOfDiff: dOD, score: 0, position: positionName)
                diveList.append(newDive)
            }
            diversWithDives.append(divers(dives: diveList, diverEntries: diver))
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
            AddDiversView()
        }
    }
}
