//
//  ResultsView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/7/23.
//

import SwiftUI


struct ResultsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var unsortedDiverList: [divers]
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    //list divers in placement order
                    Section(header: Text("Varsity").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                        ForEach(Array(zip(setVList().indices, setVList())), id: \.1) { index, diver in
                            HStack {
                                Text("\(diver.placement ?? 0).")
                                    .padding(.trailing)
                                Text("\(diver.diverEntries.name)\n\(diver.diverEntries.team ?? "")")
                                Spacer()
                                Text(String(format: "%.2f", diver.diverEntries.score ?? 0))
                            }
                            .listRowBackground(diver.placement == 1 ? Color.yellow : diver.placement == 2 ? Color.gray : diver.placement == 3 ? Color.brown : colorScheme == .dark ? .black : .white)
                        }
                    }
                    Section(header: Text("Junior Varsity").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                        ForEach(Array(zip(setJVList().indices, setJVList())), id: \.1) { index, diver in
                            HStack {
                                Text("\(diver.placement ?? 0).")
                                    .padding(.trailing)
                                Text("\(diver.diverEntries.name)\n\(diver.diverEntries.team ?? "")")
                                Spacer()
                                Text(String(format: "%.2f", diver.diverEntries.score ?? 0))
                            }
                            .listRowBackground(diver.placement == 1 ? Color.yellow : diver.placement == 2 ? Color.gray : diver.placement == 3 ? Color.brown : colorScheme == .dark ? .black : .white)
                        }
                    }
                    
                    Section(header: Text("Exhibition").font(.title2.bold()).foregroundColor(colorScheme == .dark ? .white : .black)) {
                        ForEach(setEList(), id: \.hashValue) { diver in
                            HStack {
                                Text("\(diver.diverEntries.name)\n\(diver.diverEntries.team ?? "")")
                                Spacer()
                                Text(String(format: "%.2f", diver.diverEntries.score ?? 0))
                            }
                        }
                    }
                }
            }
            Button {
                
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
        }
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
                    if jvList[jvList.count - 1].diverEntries.score == jvList[jvList.count - 2].diverEntries.score {
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
                    if vList[vList.count - 1].diverEntries.score == vList[vList.count - 2].diverEntries.score {
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
    
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(unsortedDiverList: [
            divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 2, name: "Kakawington", team: "Kaw Kawing Ton High", score: 150)),
            divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 2, name: "Kakaw", team: "Kaw Kaw High", score: 150)),
            divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 2, name: "Kakawella", team: "Kaw Kaw Ella High", score: 139.25)),
            divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 2, name: "Kakawnda", team: "Kaw Kaw Ella High", score: 98.43)),
            divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 1, name: "Kakawington", team: "Kaw Kawing Ton High", score: 102)),
            divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 1, name: "Kakaw", team: "Kaw Kaw High", score: 104.2)),
            divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 0, name: "Kakawington", team: "Kaw Kawing Ton High", score: 102)),
            divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 0, name: "Kakaw", team: "Kaw Kaw High", score: 150))])
    }
}
