//
//  AnnounceEventProgress.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/14/24.
//

import SwiftUI

struct AnnounceEventProgress: View {
    @Environment(\.colorScheme) var colorScheme //detects if the device is in dark mode
    @Environment(\.presentationMode) var presentationMode //used to make a custom back button
    
    @Binding var diversList: [diverEntry] //list of the divers
    @Binding var currentDiver: Int //index of the current diver to jump to divers
    @Binding var currentDive: Int //index of the current dive to jump to dives
    @Binding var lastDiverIndex: Int //index of the last legal diver
    @Binding var firstDiverIndex: Int //index of the first legal diver
    
    @State var diveCount: Int //greatest number of dives
    
    @State var selectedDiver: Int = -1 //index of the diver that is currently selected
    @State var selectedDive: Int = -1 //index of the dive that is currently selected
    @State var dropAlert: Bool = false //triggers an alert for dropping divers
    
    //main view
    var body: some View {
        VStack {
            List {
                ForEach(Array(zip(diversList[findDiverWithDiveCount()].dives.indices, diversList[findDiverWithDiveCount()].dives)), id: \.0) { index, dive in
                    //has a dropdown for each dive as displayed by rounds
                    DisclosureGroup("Round \(index + 1)") {
                        ForEach(Array(zip(diversList.indices, diversList)), id: \.0) { diverIndex, diver in
                            //stops displaying divers after they don't have any more dives
                            if index < diver.dives.count {
                                HStack {
                                    //each diver is a button that selects that dive and diver
                                    Button {
                                        selectedDive = index
                                        selectedDiver = diverIndex
                                    } label : {
                                        Text("\(diverIndex + 1). \(diver.name)\n\(diver.team ?? "")")
                                            .foregroundColor(diver.dq == true ? .red : colorScheme == .dark ? .white : .black)
                                    }
                                    Spacer()
                                    //if the diver is dq'ed an x is shown otherwise a square
                                    if diver.dq == true {
                                        Image(systemName: "xmark.circle.fill")
                                            .interpolation(.none).resizable().frame(width: 30, height: 30, alignment: .bottomTrailing)
                                            .onTapGesture {
                                                diversList[diverIndex].dq = false
                                                findLastDiverIndex()
                                                findFirstDiverIndex()
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
                                            }
                                    }
                                }
                                .listRowBackground(selectedDive == index && selectedDiver == diverIndex ? .blue : colorScheme == .dark ? Color.black : Color.white)
                            }
                        }
                    }
                }
            }
            //sets the current diver and dive and goes back to the last view
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
            //dq's the diver
            diversList[currentDiver].dq = true
        }
    }
    .onAppear {
        //finds the first and last index of legal divers
        findLastDiverIndex()
        findFirstDiverIndex()
    }
    .navigationBarBackButtonHidden(true) //removes default back button
    .toolbar {
        ToolbarItem(placement: .navigationBarTrailing){
            Button("Scoring") {
                //takes you back to last view
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
    
    //finds the last legal diver index
    func findLastDiverIndex() {
        lastDiverIndex = diversList.count
        var breakLoop = false
        for diver in 0..<diversList.count {
            if !breakLoop {
                if diversList[diversList.count - (1 + diver)].dq == true {
                    lastDiverIndex -= 1
                }
                else {
                    breakLoop = true
                }
            }
        }
    }
    //finds the first legal diver index
    func findFirstDiverIndex() {
        firstDiverIndex = 0
        var breakLoop = false
        for diver in 0..<diversList.count {
            if !breakLoop {
                if diversList[diver].dq == true {
                    firstDiverIndex += 1
                }
                else {
                    breakLoop = true
                }
            }
        }
    }
    //finds the largest count of dives and the index of that
    func findDiverWithDiveCount() -> Int {
        var mostDives = 0
        var mostDivesIndex = 0
        for diver in 0..<diversList.count {
            if diversList[diver].dives.count == diveCount {
                return diver
            }
            if diversList[diver].dives.count > mostDives {
                mostDives = diversList[diver].dives.count
                mostDivesIndex = diver
            }
        }
        return mostDivesIndex
    }
}

#Preview {
    AnnounceEventProgress(diversList: .constant([diverEntry(dives: ["test1", "test2"], level: 0, name: "Kakaw", team: "teamName")]), currentDiver: .constant(0), currentDive: .constant(0), lastDiverIndex: .constant(0), firstDiverIndex: .constant(0), diveCount: 2)
}

