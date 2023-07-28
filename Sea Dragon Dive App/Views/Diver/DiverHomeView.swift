//
//  DiverHomeView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/24/23.
//

import SwiftUI
import CodeScanner

struct DiverHomeView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var diverStore: DiverStore
    
    @State var username: String
    @State var userSchool: String
    @State private var isPresentingScanner = false
    @State private var code: String = ""
    @State private var value = ""
    @State private var scannedCode: String = ""
    @State private var failedScanAlert: Bool = false
    @State private var nonMatchingScan: Bool = false
    @State private var selectedEntry: divers = divers(dives: [], diverEntries: diverEntry(dives: [], level: 0, name: ""))
    @State private var selectedEntryIndex: Int = -1
    
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
                        nonMatchingScan = false
                        let jsonCode = tempCodes.name.data(using: .utf8)!
                        let decoder = JSONDecoder()
                        let entries = try? decoder.decode(resultsList.self, from: jsonCode)
                        if entries != nil {
                            //create new entry with scanned results or edit old entry
                            for dive in 0..<selectedEntry.dives.count {
                                    if selectedEntry.dives[dive].code! != entries!.diveResults[dive].code && !nonMatchingScan {
                                        failedScanAlert = true
                                        nonMatchingScan = true
                                    }
                                }
                                if !nonMatchingScan {
                                    selectedEntry.placement = entries!.placement
                                    selectedEntry.finished = true
                                    selectedEntry.diverEntries.totalScore = 0
                                    for dive in 0..<selectedEntry.dives.count {
                                        for score in entries!.diveResults[dive].score {
                                            var count = 0
                                            selectedEntry.dives[dive].score.append(scores(score: score, index: count))
                                            count += 1
                                        }
                                        for score in entries!.diveResults[dive].score {
                                            selectedEntry.dives[dive].roundScore += score * selectedEntry.dives[dive].degreeOfDiff
                                        }
                                        selectedEntry.diverEntries.totalScore! += selectedEntry.dives[dive].roundScore
                                        
                                    }
                                    diverStore.entryList[selectedEntryIndex] = selectedEntry
                                    diverStore.saveDivers()
                                    self.isPresentingScanner = false
                                }
                            else {
                                print("dives didn't match")
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
        .alert("Ivalid QR Code", isPresented: $failedScanAlert) {
            Button("OK", role: .cancel) {self.isPresentingScanner = false}
        } message: {
            Text("Could not find the needed data in the scanned QR Code")
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                //navigationlink or button?
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
                    List {
                        if !diverStore.entryList.isEmpty{
                            ForEach(Array(zip(diverStore.entryList.indices, diverStore.entryList)), id: \.0) { index, entry in
                                if entry.finished != true {
                                    NavigationLink(destination: DiveEntryView(username: username, userSchool: userSchool, entryList: $diverStore.entryList[index])) {
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
                                                    if entry.dq == true {
                                                        Text("Invalid Entry")
                                                            .foregroundColor(Color.purple)
                                                    }
                                                }
                                                Spacer()
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
                    List {
                        if diverStore.entryList.isEmpty {
                            Text("No past events")
                                .font(.body.bold())
                                .listRowBackground(colorScheme == .dark ? Color(red: 1, green: 1, blue: 1, opacity: 0.2) : Color(red: 0, green: 0, blue: 0, opacity: 0.1))
                        }
                        else {
                            ForEach(Array(zip(diverStore.entryList.indices, diverStore.entryList)), id: \.0) { index, entry in
                                if entry.finished == true {
                                    NavigationLink(destination: EventResultsView(entryList: entry)) {
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
                .navigationBarBackButtonHidden(true)
                .sheet(isPresented: $isPresentingScanner) {
                    self.ScannerSheet
                }
            }
        }
    }
    func top6DiveScore() -> Double {
        var highestScore: Double = 0
        for entry in diverStore.entryList {
            if entry.finished == true && entry.diverEntries.totalScore ?? 0 > highestScore && entry.dives.count == 6 {
                highestScore = entry.diverEntries.totalScore ?? 0
            }
        }
        return highestScore
    }
    func top11DiveScore() -> Double {
        var highestScore: Double = 0
        for entry in diverStore.entryList {
            if entry.finished == true && entry.diverEntries.totalScore ?? 0 > highestScore && entry.dives.count == 11 {
                highestScore = entry.diverEntries.totalScore ?? 0
            }
        }
        return highestScore
    }
}

struct DiverHomeView_Previews: PreviewProvider {
    static var previews: some View {
        DiverHomeView(username: "Kakaw", userSchool: "School")
            .environmentObject(DiverStore())
    }
}
