//
//  EventProgressView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/12/23.
//

import SwiftUI

struct EventProgressView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var eventStore: EventStore
    
    @Binding var diverList: [divers]
    @Binding var currentDiver: Int
    @Binding var currentDive: Int
    @Binding var lastDiverIndex: Int
    @Binding var firstDiverIndex: Int
    @Binding var eventList: events
    
    @State var selectedDiver: Int = -1
    @State var selectedDive: Int = -1
    @State var dropAlert: Bool = false
    
    var body: some View {
            VStack {
                List {
                    ForEach(Array(zip(diverList[findDiverWithDiveCount()].dives.indices, diverList[findDiverWithDiveCount()].dives)), id: \.0) { index, dive in
                        DisclosureGroup("Round \(index + 1)") {
                            ForEach(Array(zip(diverList.indices, diverList)), id: \.0) { diverIndex, diver in
                                if index < diver.dives.count {
                                    HStack {
                                        Button {
                                            selectedDive = index
                                            selectedDiver = diverIndex
                                        } label : {
                                            Text("\(diverIndex + 1). \(diver.diverEntries.name)\n\(diver.diverEntries.team ?? "")")
                                                .foregroundColor(diver.skip == true ? .red : colorScheme == .dark ? .white : .black)
                                        }
                                        Spacer()
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
                                                }
                                        }
                                        else if diver.skip == true {
                                            Image(systemName: "xmark.circle.fill")
                                                .interpolation(.none).resizable().frame(width: 30, height: 30, alignment: .bottomTrailing)
                                                .onTapGesture {
                                                    diverList[diverIndex].skip = false
                                                    findLastDiverIndex()
                                                    findFirstDiverIndex()
                                                    saveEventData()
                                                }
                                                .foregroundColor(.red)
                                        }
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
                                                }
                                        }
                                    }
                                    .listRowBackground(selectedDive == index && selectedDiver == diverIndex ? .blue : colorScheme == .dark ? Color.black : Color.white)
                                }
                            }
                        }
                    }
                }
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
            }
        }
        .onAppear {
            findLastDiverIndex()
            findFirstDiverIndex()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing){
                Button("Scoring") {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    func findLastDiverIndex() {
        lastDiverIndex = diverList.count
        var breakLoop = false
        for diver in 0..<diverList.count {
            if !breakLoop {
                if diverList[diverList.count - (1 + diver)].skip == true {
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
                if diverList[diver].skip == true {
                    firstDiverIndex += 1
                }
                else {
                    breakLoop = true
                }
            }
        }
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
    
    func findDiverWithDiveCount() -> Int {
        var mostDives = 0
        var mostDivesIndex = 0
        for diver in 0..<diverList.count {
            if diverList[diver].dives.count == eventList.diveCount {
                return diver
            }
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
        EventProgressView(diverList: .constant([divers(dives: [dives(name: "diveName", degreeOfDiff: 1, score: [scores(score: 0, index: 0), scores(score: 1, index: 1), scores(score: 2, index: 2)], position: "tempPos", roundScore: 0)], diverEntries: diverEntry(dives: ["test1", "test2"], level: 0, name: "Kakaw", team: "teamName"), skip: false)]), currentDiver: .constant(0), currentDive: .constant(0), lastDiverIndex: .constant(0), firstDiverIndex: .constant(0), eventList: .constant(events(date: "", EList: [], JVList: [], VList: [], finished: false, judgeCount: 0, diveCount: 6, reviewed: true)))
    }
}
