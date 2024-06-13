//
//  DiverDiveSelector.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/25/23.
//

import SwiftUI

struct DiverDiveSelector: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var coachEntryStore: CoachEntryStore
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.diveNbr)
    ]) var fetchedDives: FetchedResults<Dive>
    @FetchRequest(entity: Position.entity(), sortDescriptors: []) var fetchedPositions: FetchedResults<Position>
    @FetchRequest(entity: WithPosition.entity(), sortDescriptors: []) var fetchedWithPositions: FetchedResults<WithPosition>
    
    @State var expandedGroup: [Bool] = [false, false, false, false, false]
    @State var subExpandedGroup: [Bool] = [false, false, false, false]
    
    @State var entryList: diverEntry
    @State var coachEntry: coachEntry
    @Binding var diveList: [dives]
    
    var body: some View {
        VStack {
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Dismiss")
            }
            .padding()
                List {
                    Text("Dive of the Week: \(findDiveOfTheWeek()) Group")
                        DisclosureGroup(isExpanded: $expandedGroup[0]) {
                            ForEach(fetchedDives) { fetchedDive in
                                if fetchedDive.diveNbr - 100 < 100 {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                        }
                                        .padding(.trailing)
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
                        DisclosureGroup(isExpanded: $expandedGroup[1]) {
                            ForEach(fetchedDives) { fetchedDive in
                                if fetchedDive.diveNbr - 100 > 100 && fetchedDive.diveNbr - 100 < 200 {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                        }
                                        .padding(.trailing)
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
                        DisclosureGroup(isExpanded: $expandedGroup[2]) {
                            ForEach(fetchedDives) { fetchedDive in
                                if fetchedDive.diveNbr - 100 > 200 && fetchedDive.diveNbr - 100 < 300 {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                        }
                                        .padding(.trailing)
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
                        DisclosureGroup(isExpanded: $expandedGroup[3]) {
                            ForEach(fetchedDives) { fetchedDive in
                                if fetchedDive.diveNbr - 100 > 300 && fetchedDive.diveNbr - 100 < 400 {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                        }
                                        .padding(.trailing)
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
                        DisclosureGroup(isExpanded: $expandedGroup[4]) {
                            DisclosureGroup(isExpanded: $subExpandedGroup[0]) {
                                    ForEach(fetchedDives) { fetchedDive in
                                        if fetchedDive.diveNbr - 100 > 400 && fetchedDive.diveNbr < 5200 {
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    Text("\(String(fetchedDive.diveNbr)) \(fetchedDive.diveName ?? "")")
                                                    Spacer()
                                                }
                                                .padding(.trailing)
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
                            DisclosureGroup(isExpanded: $subExpandedGroup[1]) {
                                    ForEach(fetchedDives) { fetchedDive in
                                        if fetchedDive.diveNbr - 100 > 5100 && fetchedDive.diveNbr < 5300 {
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    Text("\(String(fetchedDive.diveNbr)) \(fetchedDive.diveName ?? "")")
                                                    Spacer()
                                                }
                                                .padding(.trailing)
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
                            DisclosureGroup(isExpanded: $subExpandedGroup[2]) {
                                    ForEach(fetchedDives) { fetchedDive in
                                        if fetchedDive.diveNbr - 100 > 5200 && fetchedDive.diveNbr < 5400 {
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    Text("\(String(fetchedDive.diveNbr)) \(fetchedDive.diveName ?? "")")
                                                    Spacer()
                                                }
                                                .padding(.trailing)
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
                            DisclosureGroup(isExpanded: $subExpandedGroup[3]) {
                                    ForEach(fetchedDives) { fetchedDive in
                                        if fetchedDive.diveNbr - 100 > 5300 {
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    Text("\(String(fetchedDive.diveNbr)) \(fetchedDive.diveName ?? "")")
                                                    Spacer()
                                                }
                                                .padding(.trailing)
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
    
    func isClicked(name: String, position: String) -> Bool {
        for dive in diveList {
            if dive.name == name && dive.position == position {
                return true
            }
        }
        return false
    }
    
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
    
    func findDiveOfTheWeek() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm/dd/yyyy"
        print(coachEntry.eventDate)
        var tempDate = dateFormatter.date(from: coachEntry.eventDate)
        var dateComponents = DateComponents()
        dateComponents.month = 0
        dateComponents.day = -1
        dateComponents.year = 0
        while tempDate!.formatted(date: .numeric, time: .omitted) != "8/13/2023" {
            //print(tempDate!.formatted(date: .numeric, time: .omitted))
            if tempDate!.formatted(date: .numeric, time: .omitted) == "8/14/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "9/18/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/23/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "11/20/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/25/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/29/2024" {
                return "Forward"
            }
            else if tempDate!.formatted(date: .numeric, time: .omitted) == "8/21/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "9/25/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/30/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "11/27/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/1/2024" || tempDate!.formatted(date: .numeric, time: .omitted) == "2/5/2024" {
                return "Back"
            }
            else if tempDate!.formatted(date: .numeric, time: .omitted) == "8/28/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/2/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/4/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/8/2024" {
                return "Inward"
            }
            else if tempDate!.formatted(date: .numeric, time: .omitted) == "9/4/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/9/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/11/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/15/2024" {
                return "Twisting"
            }
            else if tempDate!.formatted(date: .numeric, time: .omitted) == "9/11/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "10/16/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "12/18/2023" || tempDate!.formatted(date: .numeric, time: .omitted) == "1/22/2024" {
                return "Reverse"
            }
            tempDate = Calendar.current.date(byAdding: dateComponents, to: tempDate!)!
        }
        
        return ""
    }
}

struct DiverDiveSelector_Previews: PreviewProvider {
    static var previews: some View {
        DiverDiveSelector(entryList: diverEntry(dives: [], level: 0, name: ""), coachEntry: coachEntry(diverEntries: [], eventDate: "", team: "", version: 0), diveList: .constant([dives(name: "", degreeOfDiff: 0, score: [], position: "", roundScore: 0)]))
    }
}
