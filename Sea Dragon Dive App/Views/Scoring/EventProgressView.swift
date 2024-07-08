//
//  EventProgressView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/12/23.
//

import SwiftUI

struct EventProgressView: View {
    @Environment(\.colorScheme) var colorScheme //detects if the device is in dark mode
    @Environment(\.presentationMode) var presentationMode //used for a custom back button
    
    @EnvironmentObject var eventStore: EventStore //persistant scoring event data
    
    @Binding var diverList: [divers] //list of all divers in the event
    @Binding var currentDiver: Int //index of the current diver in the scoring view
    @Binding var currentDive: Int //index of the current dive in the scoring view
    @Binding var lastDiverIndex: Int //index of the last non skipped diver
    @Binding var firstDiverIndex: Int //index of the first non skipped diver
    @Binding var event: events //the event being scored
    
    @State var selectedDiver: Int = -1 //index of the diver that has been selected
    @State var selectedDive: Int = -1 //index of the dive being selected
    @State var dropAlert: Bool = false //opens an alert for dropping a diver
    
    var body: some View {
            VStack {
                //list of each round of divers
                List {
                    ForEach(Array(zip(diverList[findDiverWithDiveCount()].dives.indices, diverList[findDiverWithDiveCount()].dives)), id: \.0) { index, dive in
                        DisclosureGroup("Round \(index + 1)") {
                            //lists the divers for each round
                            ForEach(Array(zip(diverList.indices, diverList)), id: \.0) { diverIndex, diver in
                                if index < diver.dives.count {
                                    HStack {
                                        //sets the selected dive and diver to the selected indices
                                        Button {
                                            selectedDive = index
                                            selectedDiver = diverIndex
                                        } label : {
                                            Text("\(diverIndex + 1). \(diver.diverEntries.name)\n\(diver.diverEntries.team ?? "")")
                                                .foregroundColor(diver.skip == true ? .red : colorScheme == .dark ? .white : .black)
                                        }
                                        Spacer()
                                        //checkmark for scored dives
                                        if diver.dives[index].scored == true {
                                            Image(systemName: "checkmark.square")
                                                .interpolation(.none).resizable().frame(width: 30, height: 30, alignment: .bottomTrailing)
                                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                                .onTapGesture {
                                                    currentDiver = diverIndex
                                                    currentDive = index
                                                    dropAlert = true
                                                    findLastDiverIndex()
                                                    findFirstDiverIndex()
                                                    saveEventData()
                                                    event.diveCount = 0
                                                    for diver in diverList {
                                                        if diver.dives.count > event.diveCount && diver.skip != true {
                                                            event.diveCount = diver.dives.count
                                                        }
                                                    }
                                                }
                                        }
                                        //red circle x for dropped divers dives
                                        else if diver.skip == true {
                                            Image(systemName: "xmark.circle.fill")
                                                .interpolation(.none).resizable().frame(width: 30, height: 30, alignment: .bottomTrailing)
                                                .onTapGesture {
                                                    diverList[diverIndex].skip = false
                                                    findLastDiverIndex()
                                                    findFirstDiverIndex()
                                                    saveEventData()
                                                    event.diveCount = 0
                                                    for diver in diverList {
                                                        if diver.dives.count > event.diveCount && diver.skip != true {
                                                            event.diveCount = diver.dives.count
                                                        }
                                                    }
                                                }
                                                .foregroundColor(.red)
                                        }
                                        //empty box for unscored dives
                                        else {
                                            Image(systemName: "square")
                                                .interpolation(.none).resizable().frame(width: 30, height: 30, alignment: .bottomTrailing)
                                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                                .onTapGesture {
                                                    currentDiver = diverIndex
                                                    currentDive = index
                                                    dropAlert = true
                                                    findLastDiverIndex()
                                                    findFirstDiverIndex()
                                                    saveEventData()
                                                    event.diveCount = 0
                                                    for diver in diverList {
                                                        if diver.dives.count > event.diveCount && diver.skip != true {
                                                            event.diveCount = diver.dives.count
                                                        }
                                                    }
                                                }
                                        }
                                    }
                                    .listRowBackground(selectedDive == index && selectedDiver == diverIndex ? .blue : colorScheme == .dark ? Color.black : Color.white)
                                }
                            }
                        }
                    }
                }
                //sets the current dive and diver to the selected and goes back to the scoring view
                Button {
                    if selectedDive != -1 && selectedDiver != -1 {
                        currentDive = selectedDive
                        currentDiver = selectedDiver
                        self.presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("Jump to Round & Diver")
                }
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding()
                .padding(.horizontal)
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(lineWidth: 2)
                    )
            }
        //alert for dropping a diver
        .alert("Drop this diver?", isPresented: $dropAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Confirm") {
                for count in 0..<diverList[currentDiver].dives.count {
                    if count >= currentDive {
                        while !diverList[currentDiver].dives[count].score.isEmpty {
                            diverList[currentDiver].dives[count].score.removeFirst()
                        }
                        diverList[currentDiver].dives[count].scored = false
                    }
                }
                
                diverList[currentDiver].dives[currentDive].scored = false
                diverList[currentDiver].skip = true
                saveEventData()
                event.diveCount = 0
                for diver in diverList {
                    if diver.dives.count > event.diveCount && diver.skip != true {
                        event.diveCount = diver.dives.count
                    }
                }
            }
        }
        .onAppear {
            findLastDiverIndex()
            findFirstDiverIndex()
        }
        .navigationBarBackButtonHidden(true) //removes default back button
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing){
                //goes back to scoring view
                Button("Scoring") {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    //finds the last index of non skipped divers
    func findLastDiverIndex() {
        lastDiverIndex = diverList.count - 1
        var breakLoop = false
        var fullCount = false
        for diver in 0..<diverList.count {
            if diverList[diver].dives.count == event.diveCount {
                fullCount = true
            }
        }
        for diver in 0..<diverList.count {
            if !breakLoop {
                if diverList[diverList.count - (1 + diver)].skip == true || diverList[diverList.count - (1 + diver)].dives.count < event.diveCount && fullCount {
                    lastDiverIndex -= 1
                }
                else {
                    breakLoop = true
                }
            }
        }
    }
    //finds the first index of non skipped divers
    func findFirstDiverIndex() {
        firstDiverIndex = 0
        var breakLoop = false
        for diver in 0..<diverList.count {
            if !breakLoop {
                if diverList[diver].skip == true {
                    firstDiverIndex += 1
                }
                else {
                    breakLoop = true
                }
            }
        }
    }
    //puts the divers into three lists and saves the data
    func saveEventData() {
        event.EList = []
        event.JVList = []
        event.VList = []
        
        for diver in diverList {
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
    //minds the diver with the most dives and returns their index
    func findDiverWithDiveCount() -> Int {
        var mostDives = 0
        var mostDivesIndex = 0
        for diver in 0..<diverList.count {
            if diverList[diver].dives.count > mostDives {
                mostDives = diverList[diver].dives.count
                mostDivesIndex = diver
            }
        }
        return mostDivesIndex
    }
}

struct EventProgressView_Previews: PreviewProvider {
    static var previews: some View {
        EventProgressView(diverList: .constant([divers(dives: [dives(name: "diveName", degreeOfDiff: 1, score: [scores(score: 0, index: 0), scores(score: 1, index: 1), scores(score: 2, index: 2)], position: "tempPos", roundScore: 0)], diverEntries: diverEntry(dives: ["test1", "test2"], level: 0, name: "Kakaw", team: "teamName"), skip: false)]), currentDiver: .constant(0), currentDive: .constant(0), lastDiverIndex: .constant(0), firstDiverIndex: .constant(0), event: .constant(events(date: "", EList: [], JVList: [], VList: [], finished: false, judgeCount: 0, diveCount: 6, reviewed: true)))
    }
}
