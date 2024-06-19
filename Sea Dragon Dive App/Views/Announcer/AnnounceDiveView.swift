//
//  AnnounceDiveView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/13/24.
//

import SwiftUI

struct AnnounceDiveView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var announcerEventStore: AnnouncerEventStore
    
    @State var currentDiver: Int = 0
    @State var currentDive: Int = 0
    @State var withdrawAlert: Bool = false
    @State var firstDiverIndex: Int
    @State var lastDiverIndex: Int
    @State var diverWithLastDiveIndex: Int = 0
    @State var diverWithFirstMaxDiveIndex: Int = 0
    @State var verbosity: Bool = true
    @State var diveCount: Int = 0
    @State var lowestDiveCount: Int = 11
    
    @Binding var diverList: [diverEntry]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    withdrawAlert = true
                } label: {
                    Text("Withdraw")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .bold()
                        .padding(10)
                        .padding(.horizontal)
                        .overlay(
                            Rectangle()
                                .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                        )
                }
                .padding()
                .alert("Withdrawn", isPresented: $withdrawAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Confirm") {
                        diverList[currentDiver].dq = true
                        if currentDiver != lastDiverIndex {
                            toggleNextDiver()
                        }
                        else {
                            toggleNextRound()
                        }
                        setFirstAndLastDiverIndex()
                        diveCount = 0
                        var first = true
                        for diver in 0..<diverList.count {
                            if diverList[diver].dives.count >= diveCount && diverList[diver].dq != true {
                                diveCount = diverList[diver].dives.count
                                diverWithLastDiveIndex = diver
                            }
                        }
                        for diver in 0..<diverList.count {
                            if diverList[diver].dives.count == diveCount && diverList[diver].dq != true {
                                if first {
                                    first = false
                                    diverWithFirstMaxDiveIndex = diver
                                }
                            }
                        }
                        lowestDiveCount = 11
                        for diver in 0..<diverList.count {
                            if diverList[diver].dives.count < diveCount && diverList[diver].dq != true {
                                lowestDiveCount = diverList[diver].dives.count
                            }
                        }

                    }
                } message: {
                    Text("Has \(diverList[currentDiver].name) been withdrawn from the competition?")
                }
                Spacer()
                //verbose switch
                Toggle("Verbose Script", isOn: $verbosity)
                    .bold()
                    .padding()
            }
            Spacer()
            if verbosity {
                VStack(alignment: .leading) {
                    Text(currentDiver == firstDiverIndex ? "Starting Round \(currentDive + 1) is" : "Next up is our \(currentDiver + 1)\(currentDiver == 1 ? "nd" : currentDiver == 2 ? "rd" : "th") diver")
                        .font(.title2)
                        .padding()
                    Text(diverList[currentDiver].name)
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    Text("from \(diverList[currentDiver].team ?? "")")
                        .font(.title2)
                        .padding(.horizontal)
                        .padding(.bottom)
                    //text incorectly shows diver number when divers are withdrawn
                    Text("\(firstName(fullName: diverList[currentDiver].name))'s \(currentDive + 1)\(currentDive == 1 ? "nd" : currentDive == 2 ? "rd" : currentDive == 0 ? "st" : "th") dive is a")
                        .font(.title2)
                        .padding(.horizontal)
                        .padding(.bottom)
                    //code
                    Text(diverList[currentDiver].dives[currentDive])
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    //name - position
                    Text("\(diverList[currentDiver].fullDives![currentDive].name) - \(diverList[currentDiver].fullDives![currentDive].position)")
                        .font(.title2)
                        .padding(.horizontal)
                    //dod
                    Text("Degree of Difficulty: \(String(diverList[currentDiver].fullDives![currentDive].degreeOfDiff))")
                        .font(.title2)
                        .padding(.horizontal)
                        .padding(.bottom)
                    Text("<wait for diver to perform the dive>")
                        .font(.callout)
                        .padding(.horizontal)
                        .padding(.bottom)
                    Text("Scores:")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                        .padding(.bottom)
                    Text("<read each judges flashed scorecard>")
                        .font(.callout)
                        .padding(.horizontal)
                        .padding(.bottom)
                    if currentDiver == diverList.count - 1 {
                        Text("This concludes Round \(currentDive + 1)")
                            .font(.title2)
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                }
                .padding(.horizontal)
            }
            else {
                VStack(alignment: .leading) {
                    Text("Round \(currentDive + 1)")
                        .font(.title2)
                        .padding(.horizontal)
                    Text("Diver #\(currentDive + 1)")
                        .font(.title2)
                        .padding(.horizontal)
                        .padding(.bottom)
                    Text(diverList[currentDiver].name)
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    Text("from \(diverList[currentDiver].team ?? "")")
                        .font(.title2)
                        .padding(.horizontal)
                        .padding(.bottom)
                    Text("dive \(currentDive + 1)")
                        .font(.title2)                        .padding(.horizontal)
                    //code
                    Text(diverList[currentDiver].dives[currentDive])
                        .font(.title2)
                        .bold()

                        .padding(.horizontal)
                    //name - position
                    Text("\(diverList[currentDiver].fullDives![currentDive].name) - \(diverList[currentDiver].fullDives![currentDive].position)")
                        .font(.title2)
                        .padding(.horizontal)
                    //dod
                    Text("Degree of Difficulty: \(String(diverList[currentDiver].fullDives![currentDive].degreeOfDiff))")
                        .font(.title2)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                .padding(.horizontal)
            }
            Spacer()
            
            HStack {
                if currentDiver != firstDiverIndex || currentDive != 0 {
                    Button {
                        if currentDiver > firstDiverIndex && currentDive < lowestDiveCount || diverWithFirstMaxDiveIndex != currentDiver && currentDive >= lowestDiveCount {
                            togglepreviousDiver()
                        }
                        else if currentDiver != firstDiverIndex && currentDive < lowestDiveCount || diverWithFirstMaxDiveIndex == currentDiver && currentDive >= lowestDiveCount || currentDive != 0 {
                            togglepreviousRound()
                        }
                        
                    } label: {
                        if currentDiver > firstDiverIndex && currentDive < lowestDiveCount || diverWithFirstMaxDiveIndex != currentDiver && currentDive >= lowestDiveCount {
                            Text("Previous Diver")
                        }
                        else if currentDiver != firstDiverIndex && currentDive < lowestDiveCount || diverWithFirstMaxDiveIndex == currentDiver && currentDive >= lowestDiveCount || currentDive != 0 {
                            Text("Previous Round")
                        }
                    }
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .bold()
                    .frame(width: UIScreen.main.bounds.size.width * 0.45, height: verticalSizeClass == .compact ? 40 : UIScreen.main.bounds.size.height * 0.1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                    )
                }
                Spacer()
                Button {
                    if currentDiver < lastDiverIndex && currentDive < lowestDiveCount || diverWithLastDiveIndex != currentDiver && currentDive >= lowestDiveCount {
                        toggleNextDiver()
                    }
                    else if currentDiver == lastDiverIndex && currentDive < lowestDiveCount || diverWithLastDiveIndex == currentDiver && currentDive >= lowestDiveCount && currentDive >= lowestDiveCount && currentDive < diveCount - 1 {
                        toggleNextRound()
                    }
                    else {
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    if currentDiver < lastDiverIndex && currentDive < lowestDiveCount || diverWithLastDiveIndex != currentDiver && currentDive >= lowestDiveCount  {
                        VStack {
                            Text("Next Diver")
                        }
                    }
                    else if currentDiver == lastDiverIndex && currentDive < lowestDiveCount || diverWithLastDiveIndex == currentDiver && currentDive >= lowestDiveCount && currentDive < diveCount - 1 {
                        VStack {
                            Text("Next Round")
                        }
                    }
                    else {
                        Text("Finish Event")
                    }
                }
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .bold()
                .frame(width: UIScreen.main.bounds.size.width * 0.45, height: verticalSizeClass == .compact ? 40 : UIScreen.main.bounds.size.height * 0.1)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                )
            }
            .padding(.horizontal)
        }
        .task {
            diveCount = 0
            var first = true
            for diver in 0..<diverList.count {
                if diverList[diver].dives.count >= diveCount && diverList[diver].dq != true {
                    diveCount = diverList[diver].dives.count
                    diverWithLastDiveIndex = diver
                }
            }
            for diver in 0..<diverList.count {
                if diverList[diver].dives.count == diveCount && diverList[diver].dq != true {
                    if first {
                        first = false
                        diverWithFirstMaxDiveIndex = diver
                    }
                }
            }
            lowestDiveCount = 11
            for diver in 0..<diverList.count {
                if diverList[diver].dives.count < lowestDiveCount && diverList[diver].dq != true {
                    lowestDiveCount = diverList[diver].dives.count
                }
            }
        }
        .background(diverList[currentDiver].dq == true ? .red : .clear)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing){
                NavigationLink(destination: AnnounceEventProgress(diverList: $diverList, currentDiver: $currentDiver, currentDive: $currentDive, lastDiverIndex: $lastDiverIndex, firstDiverIndex: $firstDiverIndex, diveCount: diveCount)) {
                    Text("Dive Event Progress")
                }
            }
        }
    }
    func firstName(fullName: String) -> String {
        var firstName = ""
        for char in fullName {
            if char != " " {
                firstName.append(char)
            }
            else {
                return firstName
            }
        }
        return firstName
    }
    func toggleNextDiver() {
        var tempCurrentDiver = currentDiver
        repeat {
            tempCurrentDiver = tempCurrentDiver + 1
        } while diverList[tempCurrentDiver].dq == true || diverList[tempCurrentDiver].dives.count <= currentDive
        currentDiver = tempCurrentDiver
    }
    func toggleNextRound() {
        var tempCurrentDiver = firstDiverIndex
        while diverList[tempCurrentDiver].dq == true || diverList[tempCurrentDiver].dives.count - 1 <= currentDive {
            tempCurrentDiver += 1
        }
        currentDive = currentDive + 1
        currentDiver = tempCurrentDiver
    }
    func togglepreviousDiver() {
        var tempCurrentDiver = currentDiver
        repeat {
            tempCurrentDiver = tempCurrentDiver - 1
        } while diverList[tempCurrentDiver].dq == true || diverList[tempCurrentDiver].dives.count <= currentDive
        currentDiver = tempCurrentDiver
    }
    func togglepreviousRound() {
        var tempCurrentDiver = lastDiverIndex
        while diverList[tempCurrentDiver].dq == true || diverList[tempCurrentDiver].dives.count - 1 <= currentDive {
            tempCurrentDiver -= 1
        }
        currentDiver = tempCurrentDiver
        currentDive = currentDive - 1
    }
    func setFirstAndLastDiverIndex() {
        for diver in 0..<diverList.count{
            if diverList[diver].dq != true {
                firstDiverIndex = diver
                break
            }
        }
        for diver in 0..<diverList.count{
            if diverList[diverList.count - diver - 1].dq != true {
                lastDiverIndex = diverList.count - diver - 1
                break
            }
        }
    }
}

#Preview {
    AnnounceDiveView(firstDiverIndex: 0, lastDiverIndex: 2, diverList: .constant([
        diverEntry(dives: ["dive1", "dive2", "dive3", "dive4"], level: -1, name: "diver1", team: "school1", fullDives: [dives(name: "dive1", degreeOfDiff: 1, score: [], position: "position1", roundScore: 0), dives(name: "dive2", degreeOfDiff: 1, score: [], position: "position2", roundScore: 0), dives(name: "dive3", degreeOfDiff: 1, score: [], position: "position3", roundScore: 0), dives(name: "dive4", degreeOfDiff: 1, score: [], position: "position4", roundScore: 0)]),
        diverEntry(dives: ["dive1", "dive2", "dive3"], level: -1, name: "diver2", team: "school1", fullDives: [dives(name: "dive1", degreeOfDiff: 1, score: [], position: "position1", roundScore: 0), dives(name: "dive2", degreeOfDiff: 1, score: [], position: "position2", roundScore: 0), dives(name: "dive3", degreeOfDiff: 1, score: [], position: "position3", roundScore: 0)]),
        diverEntry(dives: ["dive1", "dive2", "dive3", "dive4"], level: -1, name: "diver3", team: "school1", fullDives: [dives(name: "dive1", degreeOfDiff: 1, score: [], position: "position1", roundScore: 0), dives(name: "dive2", degreeOfDiff: 1, score: [], position: "position2", roundScore: 0), dives(name: "dive3", degreeOfDiff: 1, score: [], position: "position3", roundScore: 0), dives(name: "dive4", degreeOfDiff: 1, score: [], position: "position4", roundScore: 0)])]))
        .environmentObject(AnnouncerEventStore())
}
