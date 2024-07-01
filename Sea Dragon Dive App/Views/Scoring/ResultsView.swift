//
//  ResultsView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/7/23.
//

import SwiftUI


struct ResultsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var eventStore: EventStore
    
    @State var unsortedDiverList: [divers]
    @State var isPresentingTeamSelector: Bool = false
    @State var sortedList: [divers] = []
    @Binding var eventList: events
    @Binding var path: [String]
    @Binding var currentDiver: Int
    
    var body: some View {
            VStack {
                HStack {
                    NavigationLink(destination: EventSelectionView(path: $path)) {
                        Image(systemName: "house")
                    }
                    Spacer()
                    NavigationLink(destination: ScoreInfoView(diverList: unsortedDiverList, lastDiverIndex: unsortedDiverList.count - 1, eventList: $eventList, path: $path)) {
                        Text("Edit Event")
                    }
                }
                .padding(.horizontal)
                List {
                    //list divers in placement order
                    Section(header: Text(setVList().isEmpty ? "" : "Varsity").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                        VarsityResultsView(unsortedDiverList: unsortedDiverList, eventList: $eventList, path: $path)
                    }
                    Section(header: Text(setJVList().isEmpty ? "" : "Junior Varsity").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                        ForEach(Array(zip(setJVList().indices, setJVList())), id: \.1) { index, diver in
                            HStack {
                                Text("\(diver.skip == true || diver.diverEntries.dq == true ? "DQ" : "\(String(diver.placement!)).")")
                                    .foregroundColor(diver.placement == 1 ? diver.skip == true || diver.diverEntries.dq == true ? colorScheme == .dark ? .white : .black : .black : colorScheme == .dark ? .white : .black)
                                Text("\(diver.diverEntries.name)\n\(diver.diverEntries.team ?? "")")
                                    .foregroundColor(diver.placement == 1 ? diver.skip == true || diver.diverEntries.dq == true ? colorScheme == .dark ? .white : .black : .black : colorScheme == .dark ? .white : .black)
                                Spacer()
                                if diver.placementScore != nil {
                                    Text(diver.placementScore == -1 || diver.diverEntries.dq == true ? "-" : String(format: "%.2f", diver.placementScore!))
                                        .foregroundColor(diver.placement == 1 ? diver.skip == true || diver.diverEntries.dq == true ? colorScheme == .dark ? .white : .black : .black : colorScheme == .dark ? .white : .black)
                                }
                            }
                            .listRowBackground(diver.skip == true || diver.diverEntries.dq == true ? colorScheme == .dark ? Color(red: 1, green: 1, blue: 1, opacity: 0.125) : Color.white : diver.placement == 1 ? Color.yellow : diver.placement == 2 ? Color.gray : diver.placement == 3 ? Color.brown : colorScheme == .dark ? .black : .white)
                        }
                    }
                    
                    Section(header: Text(setEList().isEmpty ? "" : "Exhibition").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                        ForEach(setEList(), id: \.hashValue) { diver in
                            HStack {
                                Text("\(diver.skip == true || diver.diverEntries.dq == true ? "DQ" : "")")
                                    .padding(.trailing)
                                Text("\(diver.diverEntries.name)\n\(diver.diverEntries.team ?? "")")
                                Spacer()
                                if diver.placementScore != nil {
                                    Text(diver.placementScore == -1 || diver.diverEntries.dq == true ? "-" : String(format: "%.2f", diver.placementScore!))
                                }
                            }
                        }
                    }
                }
            }
            Button {
                sortedList = []
                for diver in setEList() {
                    sortedList.append(diver)
                }
                for diver in setJVList() {
                    sortedList.append(diver)
                }
                
                for diver in setVList() {
                    sortedList.append(diver)
                }

                isPresentingTeamSelector = true
            } label: {
                Text("Create QR Code")
                    .font(.title2.bold())
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                    )
            }
        .sheet(isPresented: $isPresentingTeamSelector) {
            TeamSelevtorView(diverList: sortedList)
        }
        .onAppear {
            unsortedDiverList = []
            for diver in eventList.EList {
                unsortedDiverList.append(diver)
            }
            for diver in eventList.JVList {
                unsortedDiverList.append(diver)
            }
            for diver in eventList.VList {
                unsortedDiverList.append(diver)
            }
            for diver in 0..<unsortedDiverList.count {
                if unsortedDiverList[diver].skip != true {
                        unsortedDiverList[diver].placementScore = unsortedDiverList[diver].diverEntries.totalScore
                }
                else {
                    unsortedDiverList[diver].placementScore = -1
                }
            }
            
            if currentDiver != -1 {
                unsortedDiverList[currentDiver].skip = true
                eventList.finished = true
                saveEventData()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func setEList() -> [divers] {
        var eList: [divers] = []
        let sortedDiverList = unsortedDiverList.sorted()
        for diver in sortedDiverList {
            if diver.diverEntries.level == 0 {
                eList.append(diver)
            }
        }
        return eList
    }
    func setJVList() -> [divers] {
        var jvList: [divers] = []
        var num = 0
        let sortedDiverList = unsortedDiverList.sorted()
        for diver in sortedDiverList {
            if diver.diverEntries.level == 1 {
                num = num + 1
                jvList.append(diver)
                if jvList.count == 1 {
                    jvList[jvList.count - 1].placement = num
                }
                else {
                    if jvList[jvList.count - 1].placementScore == jvList[jvList.count - 2].placementScore {
                        jvList[jvList.count - 1].placement = jvList[jvList.count - 2].placement
                    }
                    else {
                        jvList[jvList.count - 1].placement = num
                    }
                }
            }
        }
        return jvList
    }
    func setVList() -> [divers] {
        var vList: [divers] = []
        var num = 0
        let sortedDiverList = unsortedDiverList.sorted()
        for diver in sortedDiverList {
            if diver.diverEntries.level == 2 {
                num = num + 1
                vList.append(diver)
                if vList.count == 1 {
                    vList[vList.count - 1].placement = num
                }
                else {
                    if vList[vList.count - 1].placementScore ?? -1 == vList[vList.count - 2].placementScore ?? -1 {
                        vList[vList.count - 1].placement = vList[vList.count - 2].placement
                    }
                    else {
                        vList[vList.count - 1].placement = num
                    }
                }
            }
        }
        return vList
    }
    
    func saveEventData() {
        eventList.EList = []
        eventList.JVList = []
        eventList.VList = []
        
        for diver in unsortedDiverList {
            if diver.diverEntries.level == 0 {
                eventList.EList.append(diver)
            }
            else if diver.diverEntries.level == 1 {
                eventList.JVList.append(diver)
            }
            else if diver.diverEntries.level == 2 {
                eventList.VList.append(diver)
            }
        }
        eventStore.saveEvent()
    }

    
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(unsortedDiverList: [
            divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 2, name: "Kakawington", team: "Kaw Kawing Ton High", totalScore: 150)),
            divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 2, name: "Kakaw", team: "Kaw Kaw High", totalScore: 150)),
            divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 2, name: "Kakawella", team: "Kaw Kaw Ella High", totalScore: 139.25)),
            divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 2, name: "Kakawnda", team: "Kaw Kaw Ella High", totalScore: 98.43), skip: true),
            divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 1, name: "Kakawington", team: "Kaw Kawing Ton High", totalScore: 102), skip: true),
            divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 1, name: "Kakaw", team: "Kaw Kaw High", totalScore: 104.2), skip: true),
            divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 0, name: "Kakawington", team: "Kaw Kawing Ton High", totalScore: 102)),
            divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 0, name: "Kakaw", team: "Kaw Kaw High", totalScore: 150), skip: true)], eventList: .constant(events(date: "", EList: [], JVList: [], VList: [], finished: true, judgeCount: 3, diveCount: 6, reviewed: true)), path: .constant([]), currentDiver: .constant(0))
    }
}
