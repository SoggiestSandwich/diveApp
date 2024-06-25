//
//  DiverDiveSelector.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/25/23.
//

import SwiftUI

struct DiverDiveSelector: View {
    @Environment(\.colorScheme) var colorScheme //detects if the device is in dark mode
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> //used for custom back button
    
    @EnvironmentObject var coachEntryStore: CoachEntryStore //persistant coach entry data
    
    //tables from the database
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.diveNbr)
    ]) var fetchedDives: FetchedResults<Dive>
    @FetchRequest(entity: Position.entity(), sortDescriptors: []) var fetchedPositions: FetchedResults<Position>
    @FetchRequest(entity: WithPosition.entity(), sortDescriptors: []) var fetchedWithPositions: FetchedResults<WithPosition>
    
    @State var expandedGroup: [Bool] = [false, false, false, false, false] //array that shows which dsclosure groups are open
    @State var subExpandedGroup: [Bool] = [false, false, false, false] //array that shows which sub disclosure groups are open
    
    @State var entryList: diverEntry //the diver dives are being added to
    @State var coachEntry: coachEntry //the coach entry that has the diver entry being added to
    @State var eventDate: String //date of the event
    @Binding var diveList: [dives] //list of the diver's dives
    
    var body: some View {
        VStack {
            //closes the sheet
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Dismiss")
            }
            .padding()
            //list of the dive of the week then every possible dive
                List {
                    Text("Dive of the Week: \(findDiveOfTheWeek()) Group")
                    //forward dives
                        DisclosureGroup(isExpanded: $expandedGroup[0]) {
                            ForEach(fetchedDives) { fetchedDive in
                                if fetchedDive.diveNbr - 100 < 100 {
                                    VStack(alignment: .leading) {
                                        //dive number and name
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                        }
                                        .padding(.trailing)
                                        //each position for the dive
                                        HStack {
                                            ForEach(fetchedWithPositions) {fetchedWithPosition in
                                                if fetchedWithPosition.diveNbr == fetchedDive.diveNbr {
                                                    ForEach(fetchedPositions) { fetchedPosition in
                                                        if fetchedPosition.positionId == fetchedWithPosition.positionId {
                                                            HStack {
                                                                Image(systemName: isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") ? "checkmark.circle.fill" : "plus.circle")
                                                                VStack {
                                                                    Text("\(fetchedPosition.positionName == "Straight" ? "Str" : fetchedPosition.positionName ?? "") (\(String(fetchedWithPosition.degreeOfDifficulty)))")
                                                                        .font(.caption.bold())
                                                                }
                                                            }
                                                            .onTapGesture {
                                                                //if it hasn't been clicked it removes other dives in the list with the same name add adds it to the dive list otherwise it removes it from the dive list
                                                                if !isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") {
                                                                    
                                                                    removeDivesWithSameName(name: fetchedDive.diveName ?? "")
                                                                    
                                                                    let code = String(fetchedDive.diveNbr) + (fetchedPosition.positionCode ?? "")
                                                                    
                                                                    diveList.append(dives(name: fetchedDive.diveName ?? "", degreeOfDiff: fetchedWithPosition.degreeOfDifficulty, score: [], position: fetchedPosition.positionName ?? "", roundScore: 0, scored: false, code: code))
                                                                }
                                                                else {
                                                                    removeSelectedDive(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")
                                                                }
                                                                //CoachEntryStore.saveDivers()
                                                            }
                                                            .padding(5)
                                                            .background(
                                                                Rectangle()
                                                                    .fill(.clear)
                                                                    .opacity(0.6)
                                                                    //.stroke(lineWidth: 2)
                                                            )
                                                            .overlay(
                                                                Rectangle()
                                                                    .stroke(lineWidth: 2)
                                                            )
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text("Forward Dives")
                                    .onTapGesture {
                                        if expandedGroup[0] == false {
                                            for group in 0..<expandedGroup.count {
                                                expandedGroup[group] = false
                                            }
                                            expandedGroup[0] = true
                                        }
                                        else {
                                            expandedGroup[0] = false
                                        }
                                    }
                                Spacer()
                                Text("\(numSelected(minRange: 0, maxRange: 200)) selected")
                                    .font(.caption)
                            }
                        }
                    //back dives
                        DisclosureGroup(isExpanded: $expandedGroup[1]) {
                            ForEach(fetchedDives) { fetchedDive in
                                if fetchedDive.diveNbr - 100 > 100 && fetchedDive.diveNbr - 100 < 200 {
                                    VStack(alignment: .leading) {
                                        //dive number and name
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                        }
                                        .padding(.trailing)
                                        //each position for the dive
                                        HStack {
                                            ForEach(fetchedWithPositions) {fetchedWithPosition in
                                                if fetchedWithPosition.diveNbr == fetchedDive.diveNbr {
                                                    ForEach(fetchedPositions) { fetchedPosition in
                                                        if fetchedPosition.positionId == fetchedWithPosition.positionId {
                                                            HStack {
                                                                Image(systemName: isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") ? "checkmark.circle.fill" : "plus.circle")
                                                                VStack {
                                                                    Text("\(fetchedPosition.positionName == "Straight" ? "Str" : fetchedPosition.positionName ?? "") (\(String(fetchedWithPosition.degreeOfDifficulty)))")
                                                                        .font(.caption.bold())
                                                                }
                                                            }
                                                            .onTapGesture {
                                                                //if it hasn't been clicked it removes other dives in the list with the same name add adds it to the dive list otherwise it removes it from the dive list
                                                                if !isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") {
                                                                    
                                                                    removeDivesWithSameName(name: fetchedDive.diveName ?? "")
                                                                    
                                                                    let code = String(fetchedDive.diveNbr) + (fetchedPosition.positionCode ?? "")
                                                                    
                                                                    diveList.append(dives(name: fetchedDive.diveName ?? "", degreeOfDiff: fetchedWithPosition.degreeOfDifficulty, score: [], position: fetchedPosition.positionName ?? "", roundScore: 0, scored: false, code: code))
                                                                }
                                                                else {
                                                                    removeSelectedDive(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")
                                                                }
                                                            }
                                                            .padding(5)
                                                            .background(
                                                                Rectangle()
                                                                    .fill(.clear)
                                                                    .opacity(0.6)
                                                            )
                                                            .overlay(
                                                                Rectangle()
                                                                    .stroke(lineWidth: 2)
                                                            )
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text("Back Dives")
                                    .onTapGesture {
                                        if expandedGroup[1] == false {
                                            for group in 0..<expandedGroup.count {
                                                expandedGroup[group] = false
                                            }
                                            expandedGroup[1] = true
                                        }
                                        else {
                                            expandedGroup[1] = false
                                        }
                                    }
                                Spacer()
                                Text("\(numSelected(minRange: 200, maxRange: 300)) selected")
                                    .font(.caption)
                            }
                        }
                    //reverse dives
                        DisclosureGroup(isExpanded: $expandedGroup[2]) {
                            ForEach(fetchedDives) { fetchedDive in
                                if fetchedDive.diveNbr - 100 > 200 && fetchedDive.diveNbr - 100 < 300 {
                                    VStack(alignment: .leading) {
                                        //dive number and name
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                        }
                                        .padding(.trailing)
                                        //each position for the dive
                                        HStack {
                                            ForEach(fetchedWithPositions) {fetchedWithPosition in
                                                if fetchedWithPosition.diveNbr == fetchedDive.diveNbr {
                                                    ForEach(fetchedPositions) { fetchedPosition in
                                                        if fetchedPosition.positionId == fetchedWithPosition.positionId {
                                                            HStack {
                                                                Image(systemName: isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") ? "checkmark.circle.fill" : "plus.circle")
                                                                VStack {
                                                                    Text("\(fetchedPosition.positionName == "Straight" ? "Str" : fetchedPosition.positionName ?? "") (\(String(fetchedWithPosition.degreeOfDifficulty)))")
                                                                        .font(.caption.bold())
                                                                }
                                                            }
                                                            .onTapGesture {
                                                                //if it hasn't been clicked it removes other dives in the list with the same name add adds it to the dive list otherwise it removes it from the dive list
                                                                if !isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") {
                                                                    
                                                                    removeDivesWithSameName(name: fetchedDive.diveName ?? "")
                                                                    
                                                                    let code = String(fetchedDive.diveNbr) + (fetchedPosition.positionCode ?? "")
                                                                    
                                                                    diveList.append(dives(name: fetchedDive.diveName ?? "", degreeOfDiff: fetchedWithPosition.degreeOfDifficulty, score: [], position: fetchedPosition.positionName ?? "", roundScore: 0, scored: false, code: code))
                                                                }
                                                                else {
                                                                    removeSelectedDive(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")
                                                                }
                                                                //CoachEntryStore.saveDivers()
                                                            }
                                                            .padding(5)
                                                            .background(
                                                                Rectangle()
                                                                    .fill(.clear)
                                                                    .opacity(0.6)
                                                                    //.stroke(lineWidth: 2)
                                                            )
                                                            .overlay(
                                                                Rectangle()
                                                                    .stroke(lineWidth: 2)
                                                            )
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text("Reverse Dives")
                                    .onTapGesture {
                                        if expandedGroup[2] == false {
                                            for group in 0..<expandedGroup.count {
                                                expandedGroup[group] = false
                                            }
                                            expandedGroup[2] = true
                                        }
                                        else {
                                            expandedGroup[2] = false
                                        }
                                    }
                                Spacer()
                                Text("\(numSelected(minRange: 300, maxRange: 400)) selected")
                                    .font(.caption)
                            }
                        }
                    //inward dives
                        DisclosureGroup(isExpanded: $expandedGroup[3]) {
                            ForEach(fetchedDives) { fetchedDive in
                                if fetchedDive.diveNbr - 100 > 300 && fetchedDive.diveNbr - 100 < 400 {
                                    VStack(alignment: .leading) {
                                        //dive number and name
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                        }
                                        .padding(.trailing)
                                        //each position for the dive
                                        HStack {
                                            ForEach(fetchedWithPositions) {fetchedWithPosition in
                                                if fetchedWithPosition.diveNbr == fetchedDive.diveNbr {
                                                    ForEach(fetchedPositions) { fetchedPosition in
                                                        if fetchedPosition.positionId == fetchedWithPosition.positionId {
                                                            HStack {
                                                                Image(systemName: isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") ? "checkmark.circle.fill" : "plus.circle")
                                                                VStack {
                                                                    Text("\(fetchedPosition.positionName == "Straight" ? "Str" : fetchedPosition.positionName ?? "") (\(String(fetchedWithPosition.degreeOfDifficulty)))")
                                                                        .font(.caption.bold())
                                                                }
                                                            }
                                                            .onTapGesture {
                                                                //if it hasn't been clicked it removes other dives in the list with the same name add adds it to the dive list otherwise it removes it from the dive list
                                                                if !isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") {
                                                                    
                                                                    removeDivesWithSameName(name: fetchedDive.diveName ?? "")
                                                                    
                                                                    let code = String(fetchedDive.diveNbr) + (fetchedPosition.positionCode ?? "")
                                                                    
                                                                    diveList.append(dives(name: fetchedDive.diveName ?? "", degreeOfDiff: fetchedWithPosition.degreeOfDifficulty, score: [], position: fetchedPosition.positionName ?? "", roundScore: 0, scored: false, code: code))
                                                                }
                                                                else {
                                                                    removeSelectedDive(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")
                                                                }
                                                                //CoachEntryStore.saveDivers()
                                                            }
                                                            .padding(5)
                                                            .background(
                                                                Rectangle()
                                                                    .fill(.clear)
                                                                    .opacity(0.6)
                                                                    //.stroke(lineWidth: 2)
                                                            )
                                                            .overlay(
                                                                Rectangle()
                                                                    .stroke(lineWidth: 2)
                                                            )
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text("Inward Dives")
                                    .onTapGesture {
                                        if expandedGroup[3] == false {
                                            for group in 0..<expandedGroup.count {
                                                expandedGroup[group] = false
                                            }
                                            expandedGroup[3] = true
                                        }
                                        else {
                                            expandedGroup[3] = false
                                        }
                                    }
                                
                                Spacer()
                                Text("\(numSelected(minRange: 400, maxRange: 500)) selected")
                                    .font(.caption)
                            }
                        }
                    //twist dives
                        DisclosureGroup(isExpanded: $expandedGroup[4]) {
                            //forward twist
                            DisclosureGroup(isExpanded: $subExpandedGroup[0]) {
                                    ForEach(fetchedDives) { fetchedDive in
                                        if fetchedDive.diveNbr - 100 > 400 && fetchedDive.diveNbr < 5200 {
                                            VStack(alignment: .leading) {
                                                //dive number and name
                                                HStack {
                                                    Text("\(String(fetchedDive.diveNbr)) \(fetchedDive.diveName ?? "")")
                                                    Spacer()
                                                }
                                                .padding(.trailing)
                                                //each position for the dive
                                                HStack {
                                                    ForEach(fetchedWithPositions) {fetchedWithPosition in
                                                        if fetchedWithPosition.diveNbr == fetchedDive.diveNbr {
                                                            ForEach(fetchedPositions) { fetchedPosition in
                                                                if fetchedPosition.positionId == fetchedWithPosition.positionId {
                                                                    HStack {
                                                                        Image(systemName: isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") ? "checkmark.circle.fill" : "plus.circle")
                                                                        VStack {
                                                                            Text("\(fetchedPosition.positionName == "Straight" ? "Str" : fetchedPosition.positionName ?? "") (\(String(fetchedWithPosition.degreeOfDifficulty)))")
                                                                                .font(.caption.bold())
                                                                        }
                                                                    }
                                                                    .onTapGesture {
                                                                        //if it hasn't been clicked it removes other dives in the list with the same name add adds it to the dive list otherwise it removes it from the dive list
                                                                        if !isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") {
                                                                            
                                                                            removeDivesWithSameName(name: fetchedDive.diveName ?? "")
                                                                            
                                                                            let code = String(fetchedDive.diveNbr) + (fetchedPosition.positionCode ?? "")
                                                                            
                                                                            diveList.append(dives(name: fetchedDive.diveName ?? "", degreeOfDiff: fetchedWithPosition.degreeOfDifficulty, score: [], position: fetchedPosition.positionName ?? "", roundScore: 0, scored: false, code: code))
                                                                        }
                                                                        else {
                                                                            removeSelectedDive(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")
                                                                        }
                                                                        //CoachEntryStore.saveDivers()
                                                                    }
                                                                    .padding(5)
                                                                    .background(
                                                                        Rectangle()
                                                                            .fill(.clear)
                                                                            .opacity(0.6)
                                                                            //.stroke(lineWidth: 2)
                                                                    )
                                                                    .overlay(
                                                                        Rectangle()
                                                                            .stroke(lineWidth: 2)
                                                                    )
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                            } label: {
                                Text("Forward Dives")
                            }
                            .onTapGesture {
                                if subExpandedGroup[0] == false {
                                    for group in 0..<subExpandedGroup.count {
                                        subExpandedGroup[group] = false
                                    }
                                    subExpandedGroup[0] = true
                                }
                                else {
                                    subExpandedGroup[0] = false
                                }
                            }
                            //back twist
                            DisclosureGroup(isExpanded: $subExpandedGroup[1]) {
                                    ForEach(fetchedDives) { fetchedDive in
                                        if fetchedDive.diveNbr - 100 > 5100 && fetchedDive.diveNbr < 5300 {
                                            VStack(alignment: .leading) {
                                                //dive number and name
                                                HStack {
                                                    Text("\(String(fetchedDive.diveNbr)) \(fetchedDive.diveName ?? "")")
                                                    Spacer()
                                                }
                                                .padding(.trailing)
                                                //each position for the dive
                                                HStack {
                                                    ForEach(fetchedWithPositions) {fetchedWithPosition in
                                                        if fetchedWithPosition.diveNbr == fetchedDive.diveNbr {
                                                            ForEach(fetchedPositions) { fetchedPosition in
                                                                if fetchedPosition.positionId == fetchedWithPosition.positionId {
                                                                    HStack {
                                                                        Image(systemName: isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") ? "checkmark.circle.fill" : "plus.circle")
                                                                        VStack {
                                                                            Text("\(fetchedPosition.positionName == "Straight" ? "Str" : fetchedPosition.positionName ?? "") (\(String(fetchedWithPosition.degreeOfDifficulty)))")
                                                                                .font(.caption.bold())
                                                                        }
                                                                    }
                                                                    .onTapGesture {
                                                                        //if it hasn't been clicked it removes other dives in the list with the same name add adds it to the dive list otherwise it removes it from the dive list
                                                                        if !isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") {
                                                                            
                                                                            removeDivesWithSameName(name: fetchedDive.diveName ?? "")
                                                                            
                                                                            let code = String(fetchedDive.diveNbr) + (fetchedPosition.positionCode ?? "")
                                                                            
                                                                            diveList.append(dives(name: fetchedDive.diveName ?? "", degreeOfDiff: fetchedWithPosition.degreeOfDifficulty, score: [], position: fetchedPosition.positionName ?? "", roundScore: 0, scored: false, code: code))
                                                                        }
                                                                        else {
                                                                            removeSelectedDive(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")
                                                                        }
                                                                        //CoachEntryStore.saveDivers()
                                                                    }
                                                                    .padding(5)
                                                                    .background(
                                                                        Rectangle()
                                                                            .fill(.clear)
                                                                            .opacity(0.6)
                                                                            //.stroke(lineWidth: 2)
                                                                    )
                                                                    .overlay(
                                                                        Rectangle()
                                                                            .stroke(lineWidth: 2)
                                                                    )
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                            } label: {
                                Text("Back Dives")
                            }
                            .onTapGesture {
                                if subExpandedGroup[1] == false {
                                    for group in 0..<subExpandedGroup.count {
                                        subExpandedGroup[group] = false
                                    }
                                    subExpandedGroup[1] = true
                                }
                                else {
                                    subExpandedGroup[1] = false
                                }
                            }
                            //reverse twist
                            DisclosureGroup(isExpanded: $subExpandedGroup[2]) {
                                    ForEach(fetchedDives) { fetchedDive in
                                        if fetchedDive.diveNbr - 100 > 5200 && fetchedDive.diveNbr < 5400 {
                                            VStack(alignment: .leading) {
                                                //dive number and name
                                                HStack {
                                                    Text("\(String(fetchedDive.diveNbr)) \(fetchedDive.diveName ?? "")")
                                                    Spacer()
                                                }
                                                .padding(.trailing)
                                                //each position for the dive
                                                HStack {
                                                    ForEach(fetchedWithPositions) {fetchedWithPosition in
                                                        if fetchedWithPosition.diveNbr == fetchedDive.diveNbr {
                                                            ForEach(fetchedPositions) { fetchedPosition in
                                                                if fetchedPosition.positionId == fetchedWithPosition.positionId {
                                                                    HStack {
                                                                        Image(systemName: isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") ? "checkmark.circle.fill" : "plus.circle")
                                                                        VStack {
                                                                            Text("\(fetchedPosition.positionName == "Straight" ? "Str" : fetchedPosition.positionName ?? "") (\(String(fetchedWithPosition.degreeOfDifficulty)))")
                                                                                .font(.caption.bold())
                                                                        }
                                                                    }
                                                                    .onTapGesture {
                                                                        //if it hasn't been clicked it removes other dives in the list with the same name add adds it to the dive list otherwise it removes it from the dive list
                                                                        if !isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") {
                                                                            
                                                                            removeDivesWithSameName(name: fetchedDive.diveName ?? "")
                                                                            
                                                                            let code = String(fetchedDive.diveNbr) + (fetchedPosition.positionCode ?? "")
                                                                            
                                                                            diveList.append(dives(name: fetchedDive.diveName ?? "", degreeOfDiff: fetchedWithPosition.degreeOfDifficulty, score: [], position: fetchedPosition.positionName ?? "", roundScore: 0, scored: false, code: code))
                                                                        }
                                                                        else {
                                                                            removeSelectedDive(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")
                                                                        }
                                                                        //CoachEntryStore.saveDivers()
                                                                    }
                                                                    .padding(5)
                                                                    .background(
                                                                        Rectangle()
                                                                            .fill(.clear)
                                                                            .opacity(0.6)
                                                                            //.stroke(lineWidth: 2)
                                                                    )
                                                                    .overlay(
                                                                        Rectangle()
                                                                            .stroke(lineWidth: 2)
                                                                    )
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                            } label: {
                                Text("Reverse Dives")
                            }
                            .onTapGesture {
                                if subExpandedGroup[2] == false {
                                    for group in 0..<subExpandedGroup.count {
                                        subExpandedGroup[group] = false
                                    }
                                    subExpandedGroup[2] = true
                                }
                                else {
                                    subExpandedGroup[2] = false
                                }
                            }
                            //inward twist
                            DisclosureGroup(isExpanded: $subExpandedGroup[3]) {
                                    ForEach(fetchedDives) { fetchedDive in
                                        if fetchedDive.diveNbr - 100 > 5300 {
                                            VStack(alignment: .leading) {
                                                //dive number and name
                                                HStack {
                                                    Text("\(String(fetchedDive.diveNbr)) \(fetchedDive.diveName ?? "")")
                                                    Spacer()
                                                }
                                                .padding(.trailing)
                                                //each position for the dive
                                                HStack {
                                                    ForEach(fetchedWithPositions) {fetchedWithPosition in
                                                        if fetchedWithPosition.diveNbr == fetchedDive.diveNbr {
                                                            ForEach(fetchedPositions) { fetchedPosition in
                                                                if fetchedPosition.positionId == fetchedWithPosition.positionId {
                                                                    HStack {
                                                                        Image(systemName: isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") ? "checkmark.circle.fill" : "plus.circle")
                                                                        VStack {
                                                                            Text("\(fetchedPosition.positionName == "Straight" ? "Str" : fetchedPosition.positionName ?? "") (\(String(fetchedWithPosition.degreeOfDifficulty)))")
                                                                                .font(.caption.bold())
                                                                        }
                                                                    }
                                                                    .onTapGesture {
                                                                        //if it hasn't been clicked it removes other dives in the list with the same name add adds it to the dive list otherwise it removes it from the dive list
                                                                        if !isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") {
                                                                            
                                                                            removeDivesWithSameName(name: fetchedDive.diveName ?? "")
                                                                            
                                                                            let code = String(fetchedDive.diveNbr) + (fetchedPosition.positionCode ?? "")
                                                                            
                                                                            diveList.append(dives(name: fetchedDive.diveName ?? "", degreeOfDiff: fetchedWithPosition.degreeOfDifficulty, score: [], position: fetchedPosition.positionName ?? "", roundScore: 0, scored: false, code: code))
                                                                        }
                                                                        else {
                                                                            removeSelectedDive(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")
                                                                        }
                                                                        //CoachEntryStore.saveDivers()
                                                                    }
                                                                    .padding(5)
                                                                    .background(
                                                                        Rectangle()
                                                                            .fill(.clear)
                                                                            .opacity(0.6)
                                                                            //.stroke(lineWidth: 2)
                                                                    )
                                                                    .overlay(
                                                                        Rectangle()
                                                                            .stroke(lineWidth: 2)
                                                                    )
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                            } label: {
                                Text("Inward Dives")
                            }
                            .onTapGesture {
                                if subExpandedGroup[3] == false {
                                    for group in 0..<subExpandedGroup.count {
                                        subExpandedGroup[group] = false
                                    }
                                    subExpandedGroup[3] = true
                                }
                                else {
                                    subExpandedGroup[3] = false
                                }
                            }
                        } label: {
                            HStack {
                                Text("Twist Dives")
                                    .onTapGesture {
                                        if expandedGroup[4] == false {
                                            for group in 0..<expandedGroup.count {
                                                expandedGroup[group] = false
                                            }
                                            expandedGroup[4] = true
                                        }
                                        else {
                                            expandedGroup[4] = false
                                        }
                                    }
                                Spacer()
                                Text("\(numSelected(minRange: 500, maxRange: 6000)) selected")
                                    .font(.caption)
                            }
                        }
                }
                .listStyle(.inset)
        }
        .navigationTitle("Select Dives")
        .task {
            setDiveCodes()
        }
    }
    //uses the dive code to add the full dive to the divelist
    func setDiveCodes() {
        for dive in 0..<diveList.count {
                for fetchedDive in fetchedDives {
                    if diveList[dive].name == fetchedDive.diveName {
                        for fetchedPosition in fetchedPositions {
                            if diveList[dive].position == fetchedPosition.positionName {
                                diveList[dive].code = String(fetchedDive.diveNbr) + (fetchedPosition.positionCode ?? "")
                            }
                        }
                    }
                }
            }

    }
    //returns the number of dives selected with numbers within the range
    func numSelected(minRange: Int, maxRange: Int) -> Int {
        var count = 0
        for dive in diveList {
            var code = dive.code ?? " "
            code.removeLast()
            let intCode: Int = Int(code) ?? 0
            if intCode > minRange && intCode < maxRange {
                count += 1
            }
        }
        return count
    }
    //returns true if a dive in the divelist matches the entered dive otherwise returns false
    func isClicked(name: String, position: String) -> Bool {
        for dive in diveList {
            if dive.name == name && dive.position == position {
                return true
            }
        }
        return false
    }
    //removes the dive with entered name and position
    func removeSelectedDive(name: String, position: String) {
        var breakLoop = false
        for dive in 0..<diveList.count {
            if !breakLoop {
                if diveList[dive].name == name && diveList[dive].position == position {
                    diveList.remove(at: dive)
                    breakLoop = true
                }
            }
        }
    }
    //removes all dives from dive list with the same name as the entered name
    func removeDivesWithSameName(name: String) {
        var breakLoop = false
        for dive in 0..<diveList.count {
            if !breakLoop {
                if diveList[dive].name == name {
                    breakLoop = true
                    diveList.remove(at: dive)
                }
            }
        }
    }
    //finds the dive of the week by going back one day at a time till the start of a dive of the week and returns that dives naem
    func findDiveOfTheWeek() -> String {
        print(eventDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        var tempDate = dateFormatter.date(from: eventDate)
        print(tempDate!.formatted(date: .numeric, time: .omitted))
        var dateComponents = DateComponents()
        dateComponents.month = 0
        dateComponents.day = -1
        dateComponents.year = 0
        while tempDate!.formatted(date: .numeric, time: .omitted) != "8/14/2023" {
            if tempDate!.formatted(date: .numeric, time: .omitted) == "8/14/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "9/18/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/23/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "11/20/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/25/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/29/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "8/19/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "9/23/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/28/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "11/25/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/30/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "2/3/2025" {
                return "Forward"
            }
            else if tempDate!.formatted(date: .numeric, time: .omitted) == "8/21/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "9/25/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/30/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "11/27/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/1/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "2/5/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "8/26/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "9/30/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "11/4/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/2/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/6/2025" || tempDate!.formatted(date: .numeric, time: .omitted) == "2/10/2025" {
                return "Back"
            }
            else if tempDate!.formatted(date: .numeric, time: .omitted) == "8/28/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/2/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/4/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/8/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "9/2/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/7/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/9/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/13/2025" {
                return "Inward"
            }
            else if tempDate!.formatted(date: .numeric, time: .omitted) == "9/4/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/9/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/11/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/15/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "9/9/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/14/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/16/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/20/2025" {
                return "Twisting"
            }
            else if tempDate!.formatted(date: .numeric, time: .omitted) == "9/11/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/16/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/18/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/22/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "9/16/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/21/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/23/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/27/2025" {
                return "Reverse"
            }
            tempDate = Calendar.current.date(byAdding: dateComponents, to: tempDate!)!
        }
        
        return ""
    }
}

struct DiverDiveSelector_Previews: PreviewProvider {
    static var previews: some View {
        DiverDiveSelector(entryList: diverEntry(dives: [], level: 0, name: ""), coachEntry: coachEntry(diverEntries: [], eventDate: "", team: "", version: 0), eventDate: "1/1/2000", diveList: .constant([dives(name: "", degreeOfDiff: 0, score: [], position: "", roundScore: 0)]))
    }
}
