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
    @State var tempCurrentDiver: Int = -1
    
    @Binding var eventList: events
    @Binding var path: [String]
    
    var body: some View {
            VStack {
                HStack {
                    //previous button
                    Button {
                        //toggle back one diver by reducing current diver by 1 or going to end of the diver list and and going back 1 on current dive
                        togglePreviousDiver()
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
                                Text(currentDiver == firstDiverIndex && currentDive <= 0 ? "" : previousDiver())
                                    .padding(.top)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .font(.subheadline)
                            )
                            .padding(.leading)
                    }
                    Spacer()
                    //next button
                    Button {
                        if diverList[currentDiver].dives[currentDive].score.count == eventList.judgeCount || diverList[currentDiver].skip == true && diverList[currentDiver].dives.count - 1 >= eventList.diveCount {
                            if currentDiver < lastDiverIndex || currentDive < eventList.diveCount - 1 {
                                toggleNextDiver()
                            }
                            else if !allDivesScored(){
                                scoredDivesALert = true
                            }
                            else {
                                diverList[currentDiver].dives[currentDive].scored = true
                                eventList.finished = true
                                saveEventData()
                                finishAlert = true
                            }
                        }
                        else {
                            //drop current diver (finish event if all other divers have their scores)
                            if currentDiver < lastDiverIndex || currentDive < eventList.diveCount - 1 && diverList[currentDiver].diverEntries.name != nextDiver() {
                                //just drop
                                dropDiverAlert = true
                            }
                            else if !allDivesScored() && diverList[currentDiver].diverEntries.name != nextDiver(){
                                //alert unscored dives
                                scoredDivesALert = true
                            }
                            else {
                                dropLastDiver = true
                            }
                            
                        }
                    } label: {
                        Text(currentDiver >= lastDiverIndex && currentDive >= eventList.diveCount - 1 ? "Finish Event" : "Next Diver")
                            .padding(.bottom)
                            .foregroundColor(colorScheme == .dark ? diverList[currentDiver].dives[currentDive].score.count != eventList.judgeCount && diverList[currentDiver].dives[currentDive].score.count != 0 ? .gray : .white : diverList[currentDiver].dives[currentDive].score.count != eventList.judgeCount && diverList[currentDiver].dives[currentDive].score.count != 0 ? .gray : .black)
                            .bold()
                            .frame(width: UIScreen.main.bounds.size.width * 0.45, height: verticalSizeClass == .compact ? 40 : UIScreen.main.bounds.size.height * 0.06)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(colorScheme == .dark ? diverList[currentDiver].dives[currentDive].score.count != eventList.judgeCount && diverList[currentDiver].dives[currentDive].score.count != 0 ? .gray : .white : diverList[currentDiver].dives[currentDive].score.count != eventList.judgeCount && diverList[currentDiver].dives[currentDive].score.count != 0 ? .gray : .black, lineWidth: 2)
                            )
                            .overlay(
                                Text(currentDiver >= lastDiverIndex && currentDive >= eventList.diveCount - 1 ? "" : nextDiver())
                                    .padding(.top)
                                    .foregroundColor(colorScheme == .dark ? diverList[currentDiver].dives[currentDive].score.count != eventList.judgeCount && diverList[currentDiver].dives[currentDive].score.count != 0 ? .gray : .white : diverList[currentDiver].dives[currentDive].score.count != eventList.judgeCount && diverList[currentDiver].dives[currentDive].score.count != 0 ? .gray : .black)
                                    .font(.subheadline)
                            )
                            .padding(.trailing)
                    }
                    .disabled(diverList[currentDiver].dives[currentDive].score.count != eventList.judgeCount && diverList[currentDiver].dives[currentDive].score.count != 0)
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
                NavigationLink(destination: ResultsView(unsortedDiverList: diverList, eventList: $eventList, path: $path, currentDiver: $tempCurrentDiver)) {
                    Text("Confirm")
                }
            }
            .alert("There are unscored dives", isPresented: $scoredDivesALert) {
                Button("OK", role: .cancel) {
                    
                }
            }
            .alert("No scores were submitted", isPresented: $dropDiverAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Confirm") {
                    diverList[currentDiver].skip = true
                    clearFutureScores()
                    findLastDiverIndex()
                    findFirstDiverIndex()
                    toggleNextDiver()
                    eventList.diveCount = 0
                    for diver in diverList {
                        if diver.dives.count > eventList.diveCount && diver.skip != true {
                            eventList.diveCount = diver.dives.count
                        }
                    }
                }
            } message: {
                Text("would you like to continue and drop this diver?")
            }
            .alert("No scores were submitted", isPresented: $dropLastDiver) {
                Button("Cancel", role: .cancel) {
                    //diverList[currentDiver].skip = false
                    //eventList.finished = false
                    //saveEventData()
                }
                NavigationLink("Confirm", destination: ResultsView(unsortedDiverList: diverList, eventList: $eventList, path: $path, currentDiver: $currentDiver))
            } message: {
                Text("would you like to continue and drop this diver?\nIf confirmed the event will be completed.")
            }
            .onAppear {
                eventList.diveCount = 0
                for diver in diverList {
                    if diver.dives.count > eventList.diveCount && diver.skip != true {
                        eventList.diveCount = diver.dives.count
                    }
                }
                currentIndex = diverList[currentDiver].dives[currentDive].score.count
                findFirstDiverIndex()
                findLastDiverIndex()
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
            }    }
    
    func nextDiver() -> String {
        var nextDiver: Int = currentDiver + 1
        var nextDiverDive: Int = currentDive
        if currentDiver == diverList.count - 1 && currentDive != eventList.diveCount - 1 {
            //make it look at next dive
            nextDiver = 0
            nextDiverDive += 1
        }
            while diverList[nextDiver].dives.count <= nextDiverDive || diverList[nextDiver].skip == true && diverList[nextDiver].dives[nextDiverDive].score.isEmpty {
                if nextDiver < diverList.count - 1 {
                    nextDiver += 1
                }
                else {
                    nextDiver = 0
                    nextDiverDive += 1
                }
            }
            return diverList[nextDiver].diverEntries.name
    }
    
    func previousDiver() -> String {
        var prevDiver: Int = currentDiver - 1
        var prevDiverDive: Int = currentDive
        if currentDiver == 0 && currentDive != 0 {
            //make it look at previous dive
            prevDiver = diverList.count - 1
        }
        while diverList[prevDiver].dives.count <= prevDiverDive || diverList[prevDiver].skip == true && diverList[prevDiver].dives[prevDiverDive].score.isEmpty {
            if prevDiver > 0 {
                prevDiver -= 1
            }
            else {
                prevDiver = diverList.count - 1
                prevDiverDive -= 1
            }
        }
            return diverList[prevDiver].diverEntries.name
    }
    
    func toggleNextDiver() {
        if !diverList[currentDiver].dives[currentDive].score.isEmpty {
            diverList[currentDiver].dives[currentDive].scored = true
        }
        
        if currentDiver + 1 < diverList.count {
            currentDiver = currentDiver + 1
        }
        else {
            currentDiver = 0
            currentDive = currentDive + 1
        }
        
            while diverList[currentDiver].dives.count <= currentDive || diverList[currentDiver].skip == true && diverList[currentDiver].dives[currentDive].score.isEmpty  {
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
    
    func togglePreviousDiver() {
        //toggles to previous diver or sends notification that this is the first dive?
        if currentDiver != firstDiverIndex || currentDive != 0 {
            if currentDiver - 1 > -1 {
                currentDiver -= 1
            }
            else {
                currentDiver = diverList.count - 1
                currentDive = currentDive - 1
            }
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
        halfAdded = true
    }
    
    func findLastDiverIndex() {
        lastDiverIndex = diverList.count - 1
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
                if dive != diverList[currentDiver].dives[currentDive] {
                    if dive.score.count != eventList.judgeCount && diver.skip != true && dive != diver.dives[diver.dives.count - 1] {
                        return false
                    }
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
        ScoreInfoView(diverList: [divers(dives: [dives(name: "diveName", degreeOfDiff: 1, score: [], position: "tempPos", roundScore: 0)], diverEntries: diverEntry(dives: ["test1", "test2"], level: 0, name: "Kakaw", team: "teamName"))], lastDiverIndex: 1, eventList: .constant(events(date: "", EList: [], JVList: [], VList: [], finished: false, judgeCount: 0, diveCount: 2, reviewed: true)), path: .constant([]))
    }
}
