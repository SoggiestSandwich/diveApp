//
//  VarsityResultsView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/3/24.
//

import SwiftUI

struct VarsityResultsView: View {
    @Environment(\.colorScheme) var colorScheme //detects if the device is in dark mode
    
    @State var unsortedDiverList: [divers] //list of all divers
    @Binding var event: events //the scoring event being shown
    
    var body: some View {
        //loops through all varsity divers
        ForEach(Array(zip(setVList().indices, setVList())), id: \.1) { index, diver in
            HStack {
                Text("\(diver.skip == true || diver.diverEntries.dq == true ? "DQ" : "\(String(diver.placement!)).")")
                    .padding(.trailing)
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
        .onAppear {
            //creates the diver list from each list
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
        }
    }
    //sorts the diver list and returns a list of sorted varsity divers
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
}

#Preview {
    VarsityResultsView(unsortedDiverList: [
        divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 2, name: "Kakawington", team: "Kaw Kawing Ton High", totalScore: 150)),
        divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 2, name: "Kakaw", team: "Kaw Kaw High", totalScore: 150)),
        divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 2, name: "Kakawella", team: "Kaw Kaw Ella High", totalScore: 139.25)),
        divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 2, name: "Kakawnda", team: "Kaw Kaw Ella High", totalScore: 98.43), skip: true),
        divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 1, name: "Kakawington", team: "Kaw Kawing Ton High", totalScore: 102), skip: true),
        divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 1, name: "Kakaw", team: "Kaw Kaw High", totalScore: 104.2), skip: true),
        divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 0, name: "Kakawington", team: "Kaw Kawing Ton High", totalScore: 102)),
        divers(dives: [dives(name: "diveName", degreeOfDiff: 1.1, score: [scores(score: 0, index: 0)], position: "p", roundScore: 0)], diverEntries: diverEntry(dives: ["", "", ""], level: 0, name: "Kakaw", team: "Kaw Kaw High", totalScore: 150), skip: true)], event: .constant(events(date: "", EList: [], JVList: [], VList: [], finished: true, judgeCount: 3, diveCount: 6, reviewed: true)))
}
