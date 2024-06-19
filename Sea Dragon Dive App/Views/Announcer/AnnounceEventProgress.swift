//
//  AnnounceEventProgress.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/14/24.
//

import SwiftUI

struct AnnounceEventProgress: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var eventStore: EventStore
    
    @Binding var diverList: [diverEntry]
    @Binding var currentDiver: Int
    @Binding var currentDive: Int
    @Binding var lastDiverIndex: Int
    @Binding var firstDiverIndex: Int
    
    @State var diveCount: Int
    
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
                                        Text("\(diverIndex + 1). \(diver.name)\n\(diver.team ?? "")")
                                            .foregroundColor(diver.dq == true ? .red : colorScheme == .dark ? .white : .black)
                                    }
                                    Spacer()
                                    if diver.dq == true {
                                        Image(systemName: "xmark.circle.fill")
                                            .interpolation(.none).resizable().frame(width: 30, height: 30, alignment: .bottomTrailing)
                                            .onTapGesture {
                                                diverList[diverIndex].dq = false
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
            diverList[currentDiver].dq = true
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
                if diverList[diverList.count - (1 + diver)].dq == true {
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
                if diverList[diver].dq == true {
                    firstDiverIndex += 1
                }
                else {
                    breakLoop = true
                }
            }
        }
    }
    func findDiverWithDiveCount() -> Int {
        var mostDives = 0
        var mostDivesIndex = 0
        for diver in 0..<diverList.count {
            if diverList[diver].dives.count == diveCount {
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

#Preview {
    AnnounceEventProgress(diverList: .constant([diverEntry(dives: ["test1", "test2"], level: 0, name: "Kakaw", team: "teamName")]), currentDiver: .constant(0), currentDive: .constant(0), lastDiverIndex: .constant(0), firstDiverIndex: .constant(0), diveCount: 2)
}
