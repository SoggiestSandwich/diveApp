//
//  ScoreInfoView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/26/23.
//

import SwiftUI

struct ScoreInfoView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var eventStore: EventStore
    
    @State var diverList: [divers]
    @State var lastDiverIndex: Int
    @State var firstDiverIndex: Int = 0
    
    @State var dropDiverAlert = false
    @State var backAlert = false
    @State private var currentDiver: Int = 0
    @State private var currentDive: Int = 0
    @State private var halfAdded: Bool = true
    @State private var currentIndex: Int = 0
    @State private var dropLastDiver: Bool = false
    @State private var scoredDivesALert: Bool = false
    @State private var finishAlert: Bool = false
    
    @Binding var eventList: events
    @Binding var path: [String]
    
    var body: some View {
            VStack {
                HStack {
                    Button {
                        //toggles to previous diver or sends notification that this is the first dive?
                        if currentDiver == firstDiverIndex && currentDive == 0 {
                            
                        }
                        else if currentDiver - 1 > -1 {
                            currentDiver -= 1
                            while diverList[currentDiver].dives.count < currentDive + 1 || diverList[currentDiver].dives[currentDive].score.isEmpty && diverList[currentDiver].skip == true {
                                if currentDiver > 0 {
                                    currentDiver -= 1
                                }
                                else {
                                    currentDiver = diverList.count - 1
                                    currentDive = currentDive - 1
                                }
                            }
                            currentIndex = diverList[currentDiver].dives[currentDive].score.count
                        }
                        else {
                            currentDiver = diverList.count - 1
                            currentDive = currentDive - 1
                            while diverList[currentDiver].dives.count <  currentDive + 1 || diverList[currentDiver].dives[currentDive].score.isEmpty && diverList[currentDiver].skip == true {
                                if currentDiver > 0 {
                                    currentDiver -= 1
                                }
                                else {
                                    currentDiver = diverList.count - 1
                                    currentDive = currentDive - 1
                                }
                            }
                            currentIndex = diverList[currentDiver].dives[currentDive].score.count
                        }
                        halfAdded = true
                    } label: {
                        Text("Previous Diver")
                            .padding(.bottom)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .bold()
                            .frame(width: UIScreen.main.bounds.size.width * 0.45, height: verticalSizeClass == .compact ? 40 : UIScreen.main.bounds.size.height * 0.06)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                            )
                            .overlay(
                                Text(previousDiver())
                                    .padding(.top)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .font(.subheadline)
                            )
                            .padding(.leading)
                    }
                    Spacer()
                    if currentDiver + 1 == lastDiverIndex && currentDive + 1 == eventList.diveCount && allDivesScored() &&  (diverList[currentDiver].dives[currentDive].score.count == eventList.judgeCount) {
                        //finish event
                        Button {
                            diverList[currentDiver].dives[currentDive].scored = true
                            eventList.finished = true
                            saveEventData()
                            finishAlert = true
                        } label: {
                            Text("Finish Event")
                                .padding(.bottom)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .bold()
                                .frame(width: UIScreen.main.bounds.size.width * 0.45, height: verticalSizeClass == .compact ? 40 : UIScreen.main.bounds.size.height * 0.06)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                                )
                                .padding(.trailing)
                        }
                    }
                    else {
                        Button {
                            findLastDiverIndex()
                            if (diverList[currentDiver].dives[currentDive].score.count < 3 && diverList[currentDiver].dives[currentDive].score.count > 0) || (diverList[currentDiver].dives[currentDive].score.count < 5 && diverList[currentDiver].dives[currentDive].score.count > 3) || diverList[currentDiver].dives[currentDive].score.count > 7 {
                                
                            }
                            else if diverList[currentDiver].skip == true && currentDiver >= lastDiverIndex && allDivesScored() {
                                finishAlert = true
                            }
                            else if diverList[currentDiver].skip == true && currentDiver >= lastDiverIndex && !allDivesScored() {
                                scoredDivesALert = true
                            }
                            else if currentDiver + 1 == lastDiverIndex && currentDive + 1 == eventList.diveCount && !allDivesScored() {
                                scoredDivesALert = true
                            }
                            else if currentDiver + 1 == lastDiverIndex && currentDive + 1 == eventList.diveCount && allDivesScored() {
                                diverList[currentDiver].skip = true
                                eventList.finished = true
                                saveEventData()
                                dropLastDiver = true
                            }
                            else {
                                //toggles to next diver or sends notification that this is the last dive?
                                if diverList[currentDiver].dives[currentDive].score.count == eventList.judgeCount {
                                    toggleNextDiver()
                                }
                                else if diverList[currentDiver].dives[currentDive].score.count == 0 {
                                    var lastDiver = true
                                    for diver in diverList {
                                        if diver.skip != true && diver.hashValue != diverList[currentDiver].hashValue {
                                            lastDiver = false
                                        }
                                    }
                                    if lastDiver == true {
                                        diverList[currentDiver].skip = true
                                        dropLastDiver = true
                                    }
                                    else {
                                        if diverList[currentDiver].skip == true {
                                            findLastDiverIndex()
                                            findFirstDiverIndex()
                                            toggleNextDiver()
                                        }
                                        else {
                                            dropDiverAlert = true
                                        }
                                    }
                                }
                                halfAdded = true
                            }
                        } label: {
                            Text(currentDiver + 1 >= lastDiverIndex && currentDive >= eventList.diveCount - 1 ? "Finish Event" : "Next Diver")
                                .padding(.bottom)
                                .foregroundColor(colorScheme == .dark ? diverList[currentDiver].dives[currentDive].score.count != eventList.judgeCount && diverList[currentDiver].dives[currentDive].score.count != 0 ? .gray : .white : diverList[currentDiver].dives[currentDive].score.count != eventList.judgeCount && diverList[currentDiver].dives[currentDive].score.count != 0 ? .gray : .black)
                                .bold()
                                .frame(width: UIScreen.main.bounds.size.width * 0.45, height: verticalSizeClass == .compact ? 40 : UIScreen.main.bounds.size.height * 0.06)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(colorScheme == .dark ? diverList[currentDiver].dives[currentDive].score.count != eventList.judgeCount && diverList[currentDiver].dives[currentDive].score.count != 0 ? .gray : .white : diverList[currentDiver].dives[currentDive].score.count != eventList.judgeCount && diverList[currentDiver].dives[currentDive].score.count != 0 ? .gray : .black, lineWidth: 2)
                                )
                                .overlay(
                                    Text(currentDiver + 1 == lastDiverIndex && currentDive >= eventList.diveCount - 1 ? "" : nextDiver())
                                        .padding(.top)
                                        .foregroundColor(colorScheme == .dark ? diverList[currentDiver].dives[currentDive].score.count != eventList.judgeCount && diverList[currentDiver].dives[currentDive].score.count != 0 ? .gray : .white : diverList[currentDiver].dives[currentDive].score.count != eventList.judgeCount && diverList[currentDiver].dives[currentDive].score.count != 0 ? .gray : .black)
                                        .font(.subheadline)
                                )
                                .padding(.trailing)
                        }
                        .alert("No scores were submitted", isPresented: $dropDiverAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Confirm") {
                                diverList[currentDiver].skip = true
                                clearFutureScores()
                                findLastDiverIndex()
                                findFirstDiverIndex()
                                toggleNextDiver()
                            }
                        } message: {
                            Text("would you like to continue and drop this diver?")
                        }
                        .alert("No scores were submitted", isPresented: $dropLastDiver) {
                            Button("Cancel", role: .cancel) {
                                diverList[currentDiver].skip = false
                                eventList.finished = false
                                saveEventData()
                            }
                            NavigationLink(destination: ResultsView(unsortedDiverList: diverList, eventList: $eventList, path: $path)) {
                                Text("Confirm")
                            }
                        } message: {
                            Text("would you like to continue and drop this diver?\nIf confirmed the event will be completed.")
                        }
                        .alert("There are unscored dives", isPresented: $scoredDivesALert) {
                            Button("OK", role: .cancel) {
                                var breakLoop = false
                                for diver in  0..<diverList.count {
                                    if diverList[diver].skip != true {
                                        for dive in 0..<diverList[diver].dives.count {
                                            if diverList[diver].dives[dive].scored != true && !breakLoop {
                                                currentDiver = diver
                                                currentDive = dive
                                                breakLoop = true
                                            }
                                        }
                                    }
                                }
                            }
                        } message: {
                            Text("Please score all dives or drop divers with unscored dives to finish the event")
                        }
                        .disabled(diverList[currentDiver].dives[currentDive].score.count != eventList.judgeCount && diverList[currentDiver].dives[currentDive].score.count != 0)
                    }
                }
                .padding(verticalSizeClass == .regular ? .horizontal : .top)
                
                Spacer()
                Text(diverList[currentDiver].diverEntries.name)
                    .font(.title2.bold())
                    .foregroundColor(diverList[currentDiver].skip == true ? .red : colorScheme == .dark ? .white : .black)
                Text("\(diverList[currentDiver].diverEntries.team ?? "")\nDive \(currentDive + 1) - \(diverList[currentDiver].dives[currentDive].name) - \(diverList[currentDiver].dives[currentDive].position)\nDegree of Difficulty: \(String(diverList[currentDiver].dives[currentDive].degreeOfDiff))")
                    .padding(.horizontal)
                    .font(.system(size: verticalSizeClass == .regular ? 20 : 15))
                
                Spacer()
                
                ScoreSelectorView(halfAdded: $halfAdded, currentIndex: $currentIndex, currentDiver: $currentDiver, diverList: $diverList, currentDive: $currentDive, eventList: $eventList)
            }
            
        .alert("Finish Event?", isPresented: $finishAlert) {
            Button("Cancel", role: .cancel) {
                diverList[currentDiver].dives[currentDive].scored = false
                eventList.finished = false
                saveEventData()
            }
            NavigationLink(destination: ResultsView(unsortedDiverList: diverList, eventList: $eventList, path: $path)) {
                Text("Confirm")
            }
        }
        .onAppear {
            currentIndex = diverList[currentDiver].dives[currentDive].score.count
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    saveEventData()
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing){
                NavigationLink(destination: EventProgressView(diverList: $diverList, currentDiver: $currentDiver, currentDive: $currentDive, lastDiverIndex: $lastDiverIndex, firstDiverIndex: $firstDiverIndex, eventList: $eventList)) {
                    Text("View event progress")
                }
            }
        }
    }
    
    func nextDiver() -> String {
        var num: Int = 1
        var keepLooping = true
        if currentDiver < diverList.count - 1 {
            while diverList[currentDiver + num].dives.count < eventList.diveCount || diverList[currentDiver + num].skip == true && diverList[currentDiver + num].dives[currentDive].score.isEmpty && keepLooping {
                keepLooping = false
                for diver in diverList {
                    if diver.skip != true {
                        keepLooping = true
                    }
                }
                if currentDiver + num < diverList.count - 1 {
                    num += 1
                }
                else {
                    num = -currentDiver
                }
            }
            return diverList[currentDiver + num].diverEntries.name
        }
        else if currentDiver == diverList.count - 1 && currentDive != eventList.diveCount - 1 {
            //make it look at next dive
            num = -currentDiver
            while diverList[currentDiver + num].dives.count < eventList.diveCount || diverList[currentDiver + num].skip == true && diverList[currentDiver + num].dives[currentDive + 1].score.isEmpty && keepLooping {
                keepLooping = false
                for diver in diverList {
                    if diver.skip != true {
                        keepLooping = true
                    }
                }
                if currentDiver + num < diverList.count - 1 {
                    num += 1
                }
                else {
                    num = -currentDiver
                }
            }
            return diverList[currentDiver + num].diverEntries.name
        }
        else {
            return ""
        }
    }
    
    func previousDiver() -> String {
        var num: Int = -1
        var tempCurrentDive = currentDive
        if currentDiver != firstDiverIndex || currentDive != 0 {
            if currentDiver > firstDiverIndex {
                while diverList[currentDiver + num].dives.count <= currentDive || diverList[currentDiver + num].dives[tempCurrentDive].score.isEmpty && diverList[currentDiver + num].skip == true {
                    if currentDiver + num > 0 {
                        num -= 1
                    }
                    else {
                        tempCurrentDive = tempCurrentDive - 1
                        num = (diverList.count - 1) - currentDiver
                    }
                }
                return diverList[currentDiver + num].diverEntries.name
            }
            else if currentDiver == firstDiverIndex && currentDive != 0 {
                num = (diverList.count - 1) - currentDiver
                while diverList[currentDiver + num].dives.count <= currentDive - 1 || diverList[currentDiver + num].dives[currentDive - 1].score.isEmpty && diverList[currentDiver + num].skip == true{
                    if currentDiver + num > -1 {
                        num -= 1
                    }
                    else {
                        num = (diverList.count - 1) - currentDiver
                    }
                }
                return diverList[currentDiver + num].diverEntries.name
            }
            else {
                return ""
            }
        }
        else {            return ""
        }
    }
    
    func toggleNextDiver() {
        if !diverList[currentDiver].dives[currentDive].score.isEmpty {
            diverList[currentDiver].dives[currentDive].scored = true
        }
        if currentDiver + 1 < diverList.count {
            currentDiver = currentDiver + 1
            while diverList[currentDiver].skip == true && diverList[currentDiver].dives[currentDive].score.isEmpty || diverList[currentDiver].dives.count <= currentDive {
                if currentDiver + 1 < diverList.count {
                    currentDiver += 1
                }
                else {
                    currentDiver = 0
                    currentDive = currentDive + 1
                }
            }
            currentIndex = diverList[currentDiver].dives[currentDive].score.count
        }
        else {
            currentDiver = 0
            currentDive = currentDive + 1
            while diverList[currentDiver].skip == true && diverList[currentDiver].dives[currentDive].score.isEmpty || diverList[currentDiver].dives.count <= currentDive {
                if currentDiver + 1 < diverList.count {
                    currentDiver += 1
                }
                else {
                    currentDiver = 0
                    currentDive = currentDive + 1
                }
            }
            currentIndex = diverList[currentDiver].dives[currentDive].score.count
        }
    }
    
    func findLastDiverIndex() {
        lastDiverIndex = diverList.count
        var breakLoop = false
        var fullCount = false
        for diver in 0..<diverList.count {
            if diverList[diver].dives.count == eventList.diveCount {
                fullCount = true
            }
        }
        for diver in 0..<diverList.count {
            if !breakLoop {
                if diverList[diverList.count - (1 + diver)].skip == true || diverList[diverList.count - (1 + diver)].dives.count < eventList.diveCount && fullCount {
                    lastDiverIndex -= 1
                }
                else {
                    breakLoop = true
                }
            }
        }
    }
    func findFirstDiverIndex() {
        firstDiverIndex = 0
        var breakLoop = false
        for diver in 0..<diverList.count {
            if !breakLoop {
                if diverList[diver].skip == true && diverList[diver].dives[0].score.isEmpty {
                    firstDiverIndex += 1
                }
                else {
                    breakLoop = true
                }
            }
        }
    }
    
    func clearFutureScores() {
        for diver in 0..<diverList[currentDiver].dives.count {
            if diver == currentDive {
                diverList[currentDiver].dives[diver].scored = false
            }
            else if diver > currentDive && !diverList[currentDiver].dives[diver].score.isEmpty {
                while !diverList[currentDiver].dives[diver].score.isEmpty {
                    diverList[currentDiver].dives[diver].score.remove(at: 0)
                }
                diverList[currentDiver].diverEntries.totalScore! -= diverList[currentDiver].dives[diver].roundScore
                diverList[currentDiver].dives[diver].roundScore = 0
                diverList[currentDiver].dives[diver].scored = false
            }
        }
    }
    
    func allDivesScored() -> Bool {
        for diver in diverList {
            for dive in diver.dives {
                if dive.score.count != eventList.judgeCount && diver.skip != true && dive != diver.dives[diver.dives.count - 1] {
                    return false
                }
            }
        }
        return true
    }
    func saveEventData() {
        eventList.EList = []
        eventList.JVList = []
        eventList.VList = []
        
        for diver in diverList {
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

struct ScoreInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreInfoView(diverList: [divers(dives: [dives(name: "diveName", degreeOfDiff: 1, score: [], position: "tempPos", roundScore: 0)], diverEntries: diverEntry(dives: ["test1", "test2"], level: 0, name: "Kakaw", team: "teamName"))], lastDiverIndex: 1, eventList: .constant(events(date: "", EList: [], JVList: [], VList: [], finished: false, judgeCount: 3, diveCount: 6, reviewed: true)), path: .constant([]))
    }
}
