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
    
    @State private var isPresentingScanner = false
    @State private var code: String = ""
    @State private var value = ""
    @State private var scannedCode: String = ""
    @State private var coachList: [coachEntry] = []
    @State private var JVList: [diverEntry] = []
    @State private var VList: [diverEntry] = []
    @State private var EList: [diverEntry] = []
    @State private var editingList = true
    
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
                            coachList.append(entries!)
                            sortDivers()
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
                    Section(header: Text("Junior Varsity").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                        ForEach(Array(zip(JVList.indices, JVList)), id: \.0) { index, diver in
                            Text("\(index + 1). \(diver.name)\n\(diver.team!)")
                        }
                        .onMove { (indexSet, index) in
                            self.JVList.move(fromOffsets: indexSet, toOffset: index)
                        }
                    }
                    Section(header: Text("Varsity").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                        ForEach(Array(zip(VList.indices, VList)), id: \.1) { index, diver in
                            Text("\(index + JVList.count + 1). \(diver.name)\n\(diver.team!)")
                        }
                        .onMove { (indexSet, index) in
                            self.VList.move(fromOffsets: indexSet, toOffset: index)
                        }
                    }
                    Section(header: Text("Exhibition").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                        ForEach(Array(zip(EList.indices, EList)), id: \.1) { index, diver in
                            Text("\(index + JVList.count + VList.count + 1). \(diver.name)\n\(diver.team!)")
                        }
                        .onMove { (indexSet, index) in
                            self.EList.move(fromOffsets: indexSet, toOffset: index)
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
                NavigationLink(destination: ScoreInfoView()) {
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
        }
    }
    
    func sortDivers() {
        JVList = []
        VList = []
        EList = []
        for coach in coachList {
            for diver in coach.diverEntries {
                if diver.level == 0 {
                    JVList.append(diver)
                    JVList[JVList.count - 1].team = coach.team
                }
                if diver.level == 1 {
                    VList.append(diver)
                    VList[VList.count - 1].team = coach.team
                }
                if diver.level == 2 {
                    EList.append(diver)
                    EList[EList.count - 1].team = coach.team
                }
            }
        }
    }
}

struct AddDiversView_Previews: PreviewProvider {
    static var previews: some View {
        AddDiversView()
    }
}
