//
//  AnnounceDiveView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/13/24.
//

import SwiftUI

struct AnnounceDiveView: View {
    @Environment(\.colorScheme) var colorScheme //detects if dark mode
    @Environment(\.verticalSizeClass) var verticalSizeClass //detects if vertical layout
    @Environment(\.presentationMode) var presentationMode //used to create custom back buttons
    
    @EnvironmentObject var announcerEventStore: AnnouncerEventStore //announcer's persistant data
    
    @State var currentDiver: Int = 0 //index of the diver being displayed
    @State var currentDive: Int = 0 //index of the dive being displayed
    @State var withdrawAlert: Bool = false //triggers the withdraw alert
    @State var firstDiverIndex: Int //tracks the first diver of each round
    @State var lastDiverIndex: Int //tracks the last diver each round
    @State var diverWithLastDiveIndex: Int = 0 //tracks the last diver with the most dives
    @State var diverWithFirstMaxDiveIndex: Int = 0 //tracks the first diver with the most dives
    @State var verbosity: Bool = true //determines if the whole script is shown
    @State var diveCount: Int = 0 //the largest amount of dives in the event
    @State var lowestDiveCount: Int = 11 //the smallest amount of dives in the event
    
    @Binding var diverList: [diverEntry] //list of all the divers
    
    //main view
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    withdrawAlert = true //triggers the withdrawn alert
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
                        //sets the diver as dq'ed
                        diverList[currentDiver].dq = true
                        //if on the last diver moves to the next round
                        if currentDiver != lastDiverIndex {
                            toggleNextDiver()
                        }
                        //else go to the next round
                        else {
                            toggleNextRound()
                        }
                        //ensure the first and last diver remain the same or readjust skipping dq'ed dives
                        setFirstAndLastDiverIndex()
                        //checks the greatest dive count and lowest skipping the dq'ed divers and changes them if it has changed
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
                        //lowest
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
                Toggle("Verbose Script", isOn: $verbosity) //verbosity switch/toggle
                    .bold()
                    .padding()
            }
            Spacer()
            if verbosity {
                //verbose script
                VStack(alignment: .leading) {
                    //script start
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
                        //shows when on the last diver of a round
                        Text("This concludes Round \(currentDive + 1)")
                            .font(.title2)
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                }
                .padding(.horizontal)
            }
            //non-verbose script
            else {
                VStack(alignment: .leading) {
                    //script start
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
                    //previous diver/round button that does not appear if on the first diver and first dive
                    Button {
                        //previous diver
                        if currentDiver > firstDiverIndex && currentDive < lowestDiveCount || diverWithFirstMaxDiveIndex != currentDiver && currentDive >= lowestDiveCount {
                            togglepreviousDiver()
                        }
                        //previous round
                        else if currentDiver != firstDiverIndex && currentDive < lowestDiveCount || diverWithFirstMaxDiveIndex == currentDiver && currentDive >= lowestDiveCount || currentDive != 0 {
                            togglepreviousRound()
                        }
                        
                    } label: {
                        //previous diver
                        if currentDiver > firstDiverIndex && currentDive < lowestDiveCount || diverWithFirstMaxDiveIndex != currentDiver && currentDive >= lowestDiveCount {
                            Text("Previous Diver")
                        }
                        //previous round
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
                //next diver/round and finish event button
                Button {
                    //next diver
                    if currentDiver < lastDiverIndex && currentDive < lowestDiveCount || diverWithLastDiveIndex != currentDiver && currentDive >= lowestDiveCount {
                        toggleNextDiver()
                    }
                    //next round
                    else if currentDiver == lastDiverIndex && currentDive < lowestDiveCount || diverWithLastDiveIndex == currentDiver && currentDive >= lowestDiveCount && currentDive >= lowestDiveCount && currentDive < diveCount - 1 {
                        toggleNextRound()
                    }
                    //finish event
                    else {
                        presentationMode.wrappedValue.dismiss() //back to last view
                    }
                } label: {
                    //next diver
                    if currentDiver < lastDiverIndex && currentDive < lowestDiveCount || diverWithLastDiveIndex != currentDiver && currentDive >= lowestDiveCount  {
                        VStack {
                            Text("Next Diver")
                        }
                    }
                    //next round
                    else if currentDiver == lastDiverIndex && currentDive < lowestDiveCount || diverWithLastDiveIndex == currentDiver && currentDive >= lowestDiveCount && currentDive < diveCount - 1 {
                        VStack {
                            Text("Next Round")
                        }
                    }
                    //finish event
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
            //when entering the view determine the greatest and lowest dive counts
            diveCount = 0
            var first = true
            for diver in 0..<diverList.count {
                if diverList[diver].dives.count >= diveCount && diverList[diver].dq != true {
                    diveCount = diverList[diver].dives.count
                    diverWithLastDiveIndex = diver
                }
            }
            //index of the first diver with the greatest amount of dives
            for diver in 0..<diverList.count {
                if diverList[diver].dives.count == diveCount && diverList[diver].dq != true {
                    if first {
                        first = false
                        diverWithFirstMaxDiveIndex = diver
                    }
                }
            }
            //lowest
            lowestDiveCount = 11
            for diver in 0..<diverList.count {
                if diverList[diver].dives.count < lowestDiveCount && diverList[diver].dq != true {
                    lowestDiveCount = diverList[diver].dives.count
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                //custom back button
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
                //sends you to AnnounceEventProgress view
                NavigationLink(destination: AnnounceEventProgress(diversList: $diverList, currentDiver: $currentDiver, currentDive: $currentDive, lastDiverIndex: $lastDiverIndex, firstDiverIndex: $firstDiverIndex, diveCount: diveCount)) {
                    Text("Dive Event Progress")
                }
            }
        }
    }
    //removes the last names by only reading until the first space
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
    //increments the current diver by 1 and continues until it is on a legal diver
    func toggleNextDiver() {
        var tempCurrentDiver = currentDiver
        repeat {
            tempCurrentDiver = tempCurrentDiver + 1
        } while diverList[tempCurrentDiver].dq == true || diverList[tempCurrentDiver].dives.count <= currentDive
        currentDiver = tempCurrentDiver
    }
    //sets the current diver to the firstDiverIndex then increments until it is on a legal diver and increases the current dive by one
    func toggleNextRound() {
        var tempCurrentDiver = firstDiverIndex
        while diverList[tempCurrentDiver].dq == true || diverList[tempCurrentDiver].dives.count - 1 <= currentDive {
            tempCurrentDiver += 1
        }
        currentDive = currentDive + 1
        currentDiver = tempCurrentDiver
    }
    //decrements the current diver by 1 and continues until it is on a legal diver
    func togglepreviousDiver() {
        var tempCurrentDiver = currentDiver
        repeat {
            tempCurrentDiver = tempCurrentDiver - 1
        } while diverList[tempCurrentDiver].dq == true || diverList[tempCurrentDiver].dives.count <= currentDive
        currentDiver = tempCurrentDiver
    }
    //sets the current diver to the lastDiverIndex then decrements until it is on a legal diver and decreases the current dive by one
    func togglepreviousRound() {
        var tempCurrentDiver = lastDiverIndex
        while diverList[tempCurrentDiver].dq == true || diverList[tempCurrentDiver].dives.count - 1 <= currentDive {
            tempCurrentDiver -= 1
        }
        currentDiver = tempCurrentDiver
        currentDive = currentDive - 1
    }
    //finds the first and last legal diver of each round
    func setFirstAndLastDiverIndex() {
        //first
        for diver in 0..<diverList.count{
            if diverList[diver].dq != true {
                firstDiverIndex = diver
                break
            }
        }
        //last
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
        diverEntry(dives: ["dive1", "dive2", "dive3"], level: -1, name: "diver1", team: "school1", fullDives: [dives(name: "dive1", degreeOfDiff: 1, score: [], position: "position1", roundScore: 0), dives(name: "dive2", degreeOfDiff: 1, score: [], position: "position2", roundScore: 0), dives(name: "dive3", degreeOfDiff: 1, score: [], position: "position3", roundScore: 0)]),
        diverEntry(dives: ["dive1", "dive2", "dive3"], level: -1, name: "diver2", team: "school1", fullDives: [dives(name: "dive1", degreeOfDiff: 1, score: [], position: "position1", roundScore: 0), dives(name: "dive2", degreeOfDiff: 1, score: [], position: "position2", roundScore: 0), dives(name: "dive3", degreeOfDiff: 1, score: [], position: "position3", roundScore: 0)]),
        diverEntry(dives: ["dive1", "dive2", "dive3", "dive4"], level: -1, name: "diver3", team: "school1", fullDives: [dives(name: "dive1", degreeOfDiff: 1, score: [], position: "position1", roundScore: 0), dives(name: "dive2", degreeOfDiff: 1, score: [], position: "position2", roundScore: 0), dives(name: "dive3", degreeOfDiff: 1, score: [], position: "position3", roundScore: 0), dives(name: "dive4", degreeOfDiff: 1, score: [], position: "position4", roundScore: 0)])]))
        .environmentObject(AnnouncerEventStore())
}
