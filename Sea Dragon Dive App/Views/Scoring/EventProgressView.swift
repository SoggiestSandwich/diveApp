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
    
    @Binding var diverList: [divers]
    @Binding var currentDiver: Int
    @Binding var currentDive: Int
    @Binding var lastDiverIndex: Int
    @Binding var firstDiverIndex: Int
    
    @State var selectedDiver: Int = -1
    @State var selectedDive: Int = -1
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(Array(zip(diverList[0].dives.indices, diverList[0].dives)), id: \.0) { index, dive in
                        DisclosureGroup("Round \(index + 1)") {
                            ForEach(Array(zip(diverList.indices, diverList)), id: \.0) { diverIndex, diver in
                                HStack {                                        Text("\(diverIndex + 1). \(diver.diverEntries.name)\n\(diver.diverEntries.team ?? "")")
                                            .foregroundColor(diver.skip == true ? .red : colorScheme == .dark ? .white : .black)
                                            .onTapGesture(perform: {
                                                selectedDive = index
                                                selectedDiver = diverIndex
                                            })
                                    Spacer()
                                    if diver.dives[index].scored == true {
                                        Button{
                                            currentDiver = diverIndex
                                            currentDive = index
                                            
                                            for count in 0..<diverList[diverIndex].dives.count {
                                                if count >= index {
                                                    while !diverList[diverIndex].dives[count].score.isEmpty {
                                                        diverList[diverIndex].dives[count].score.removeFirst()
                                                    }
                                                    diverList[diverIndex].dives[count].scored = false
                                                }
                                            }
                                            
                                            diverList[diverIndex].dives[index].scored = false
                                            diverList[diverIndex].skip = true
                                            findLastDiverIndex()
                                            findFirstDiverIndex()
                                        }label: {
                                            Image(systemName: "checkmark.square")
                                                .interpolation(.none).resizable().frame(width: 30, height: 30, alignment: .bottomTrailing)
                                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                        }
                                    }
                                    else if diver.skip == true {
                                        Button{
                                            diverList[diverIndex].skip = false
                                            findLastDiverIndex()
                                            findFirstDiverIndex()
                                        }label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .interpolation(.none).resizable().frame(width: 30, height: 30, alignment: .bottomTrailing)
                                        }
                                        .foregroundColor(.red)
                                    }
                                    else {
                                        Button{
                                            diverList[diverIndex].skip = true
                                            findLastDiverIndex()
                                            findFirstDiverIndex()
                                        }label: {
                                            Image(systemName: "square")
                                                .interpolation(.none).resizable().frame(width: 30, height: 30, alignment: .bottomTrailing)
                                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                        }
                                    }
                                }
                                .listRowBackground(selectedDive == index && selectedDiver == diverIndex ? .blue : colorScheme == .dark ? Color.black : Color.white)
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
}

struct EventProgressView_Previews: PreviewProvider {
    static var previews: some View {
        EventProgressView(diverList: .constant([divers(dives: [dives(name: "diveName", degreeOfDiff: 1, score: [scores(score: 0, index: 0), scores(score: 1, index: 1), scores(score: 2, index: 2)], position: "tempPos", roundScore: 0)], diverEntries: diverEntry(dives: ["test1", "test2"], level: 0, name: "Kakaw", team: "teamName"), skip: false)]), currentDiver: .constant(0), currentDive: .constant(0), lastDiverIndex: .constant(0), firstDiverIndex: .constant(0))
    }
}
