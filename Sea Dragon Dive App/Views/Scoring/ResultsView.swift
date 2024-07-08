//
//  ResultsView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/7/23.
//

import SwiftUI


struct ResultsView: View {
    @Environment(\.colorScheme) var colorScheme //detects if the device is in dark mode
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> //used for custom back button
    
    @EnvironmentObject var eventStore: EventStore //persistant scoring event data
    
    @State var unsortedDiverList: [divers] //list of all the divers
    @State var isPresentingTeamSelector: Bool = false //opens the qr code
    @State var sortedList: [divers] = [] //list of divers sorted by level and placement
    @Binding var event: events //event whose results are being shown
    @Binding var path: [String] //used to go back to the login view
    @Binding var currentDiver: Int //index of the last diver if they are dropped
    
    var body: some View {
            VStack {
                HStack {
                    //goes to event selection view
                    NavigationLink(destination: EventSelectionView(path: $path)) {
                        Image(systemName: "house")
                    }
                    Spacer()
                    //goes to scoring view
                    NavigationLink(destination: ScoreInfoView(diverList: unsortedDiverList, lastDiverIndex: unsortedDiverList.count - 1, event: $event, path: $path)) {
                        Text("Edit Event")
                    }
                }
                .padding(.horizontal)
                List {
                    //list divers in placement order
                    Section(header: Text(setVList().isEmpty ? "" : "Varsity").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                        VarsityResultsView(unsortedDiverList: unsortedDiverList, event: $event, path: $path)
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
        //puts the divers into a sorted list and shows the team selector sheet
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
        //sheet for team selector
        .sheet(isPresented: $isPresentingTeamSelector) {
            TeamSelevtorView(diverList: sortedList)
        }
        .onAppear {
            //puts divers into a list and drops the current diver if it is not the default
            unsortedDiverList = []
            for diver in event.EList {
                unsortedDiverList.append(diver)
            }
            for diver in event.JVList {
                unsortedDiverList.append(diver)
            }
            for diver in event.VList {
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
                event.finished = true
                saveEventData()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    //returns a list of exhibition divers from the sorted list
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
    //returns a list of junior varsity divers from the sorted list
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
    //returns a list of varsity divers from the sorted list
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
    //puts divers from unsorted list to it level and saves the event
    func saveEventData() {
        event.EList = []
        event.JVList = []
        event.VList = []
        
        for diver in unsortedDiverList {
            if diver.diverEntries.level == 0 {
                event.EList.append(diver)
            }
            else if diver.diverEntries.level == 1 {
                event.JVList.append(diver)
            }
            else if diver.diverEntries.level == 2 {
                event.VList.append(diver)
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
            divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 0, name: "Kakaw", team: "Kaw Kaw High", totalScore: 150), skip: true)], event: .constant(events(date: "", EList: [], JVList: [], VList: [], finished: true, judgeCount: 3, diveCount: 6, reviewed: true)), path: .constant([]), currentDiver: .constant(0))
    }
}
