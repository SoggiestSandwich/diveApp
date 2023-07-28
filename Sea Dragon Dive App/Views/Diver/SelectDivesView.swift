//
//  SelectDivesView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/26/23.
//

import SwiftUI

struct SelectDivesView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var diverStore: DiverStore
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.diveNbr)
    ]) var fetchedDives: FetchedResults<Dive>
    @FetchRequest(entity: Position.entity(), sortDescriptors: []) var fetchedPositions: FetchedResults<Position>
    @FetchRequest(entity: WithPosition.entity(), sortDescriptors: []) var fetchedWithPositions: FetchedResults<WithPosition>
    
    @State var selection: Int = 0
    @State var expandedGroup: [Bool] = [false, false, false, false, false]
    @State var subExpandedGroup: [Bool] = [false, false, false, false]
    
    @State var entryList: divers
    @Binding var diveList: [dives]
    @Binding var favoriteList: [String]
    
    var body: some View {
        VStack {
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Dismiss")
            }
            .padding()
            HStack {
                Text("All Dives")
                    .font(.caption.bold())
                    .padding(5)
                    .padding(.horizontal)
                    .background(
                        Rectangle()
                            .stroke(lineWidth: 2)
                    )
                    .overlay(
                        Rectangle()
                            .fill(selection == 0 ? .blue : .clear)
                            .opacity(0.5)
                    )
                    .onTapGesture {
                        selection = 0
                    }
                Text("My Recent Dives")
                    .font(.caption.bold())
                    .padding(5)
                    .padding(.horizontal)
                    .background(
                        Rectangle()
                            .stroke(lineWidth: 2)
                    )
                    .overlay(
                        Rectangle()
                            .fill(selection == 1 ? .blue : .clear)
                            .opacity(0.5)
                    )
                    .padding(-8)
                    .onTapGesture {
                        selection = 1
                    }
                Text("Favorites")
                    .font(.caption.bold())
                    .padding(5)
                    .padding(.horizontal)
                    .background(
                        Rectangle()
                            .stroke(lineWidth: 2)
                    )
                    .overlay(
                        Rectangle()
                            .fill(selection == 2 ? .blue : .clear)
                            .opacity(0.5)
                    )
                    .onTapGesture {
                        selection = 2
                    }
            }
            .padding(.vertical)
            if selection == 0 || selection == 2 && !favoriteList.isEmpty || selection == 1 && !noRecentDives(lowRange: 0, highRange: 6000) {
                List {
                    Text("Dive of the Week: \(findDiveOfTheWeek()) Group")
                    if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 100, highRange: 200) || selection == 1 && !noRecentDives(lowRange: 100, highRange: 200) {
                        DisclosureGroup(isExpanded: $expandedGroup[0]) {
                            ForEach(fetchedDives) { fetchedDive in
                                if selection == 0 && fetchedDive.diveNbr - 100 < 100 || selection == 2 && fetchedDive.diveNbr - 100 < 100 && isFavorited(name: fetchedDive.diveName ?? "") || selection == 1 && isRecent(name: fetchedDive.diveName ?? "") {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                            Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                .onTapGesture {
                                                    if !isFavorited(name: fetchedDive.diveName ?? "") {
                                                        favoriteList.append(fetchedDive.diveName ?? "")
                                                        diverStore.saveDivers()
                                                    }
                                                    else {
                                                        var breakLoop = false
                                                        for favorite in 0..<favoriteList.count {
                                                            if !breakLoop {
                                                                if fetchedDive.diveName == favoriteList[favorite] {
                                                                    favoriteList.remove(at: favorite)
                                                                    breakLoop = true
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
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
                                                                    if averageScore(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") != 0 {
                                                                        Text("Avg. Score: \(String(format: "%.2f", averageScore(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")))")
                                                                            .font(.system(size: 8).bold())
                                                                    }
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
                                                                diverStore.saveDivers()
                                                            }
                                                            .padding(5)
                                                            .background(
                                                                Rectangle()
                                                                    .fill(bestScores(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "", lowRange: 100, highRange: 200) ? .yellow : .clear)
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
                    }
                    if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 200, highRange: 300) || selection == 1 && !noRecentDives(lowRange: 200, highRange: 300) {
                        DisclosureGroup(isExpanded: $expandedGroup[1]) {
                            ForEach(fetchedDives) { fetchedDive in
                                if selection == 0 && fetchedDive.diveNbr - 100 > 100 && fetchedDive.diveNbr - 100 < 200 || selection == 2 && isFavorited(name: fetchedDive.diveName ?? "") && fetchedDive.diveNbr - 100 > 100 && fetchedDive.diveNbr - 100 < 200 || selection == 1 && isRecent(name: fetchedDive.diveName ?? "") {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                            Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                .onTapGesture {
                                                    if !isFavorited(name: fetchedDive.diveName ?? "") {
                                                        favoriteList.append(fetchedDive.diveName ?? "")
                                                        diverStore.saveDivers()
                                                    }
                                                    else {
                                                        var breakLoop = false
                                                        for favorite in 0..<favoriteList.count {
                                                            if !breakLoop {
                                                                if fetchedDive.diveName == favoriteList[favorite] {
                                                                    favoriteList.remove(at: favorite)
                                                                    breakLoop = true
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
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
                                                                    if averageScore(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") != 0 {
                                                                        Text("Avg. Score: \(String(format: "%.2f", averageScore(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")))")
                                                                            .font(.system(size: 8).bold())
                                                                    }
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
                                                                diverStore.saveDivers()
                                                            }
                                                            .padding(5)
                                                            .background(
                                                                Rectangle()
                                                                    .fill(bestScores(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "", lowRange: 200, highRange: 300) ? .yellow : .clear)
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
                    }
                    if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 300, highRange: 400) || selection == 1 && !noRecentDives(lowRange: 300, highRange: 400) {
                        DisclosureGroup(isExpanded: $expandedGroup[2]) {
                            ForEach(fetchedDives) { fetchedDive in
                                if selection == 0 && fetchedDive.diveNbr - 100 > 200 && fetchedDive.diveNbr - 100 < 300 || selection == 2 && isFavorited(name: fetchedDive.diveName ?? "") && fetchedDive.diveNbr - 100 > 200 && fetchedDive.diveNbr - 100 < 300 || selection == 1 && isRecent(name: fetchedDive.diveName ?? "") {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                            Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                .onTapGesture {
                                                    if !isFavorited(name: fetchedDive.diveName ?? "") {
                                                        favoriteList.append(fetchedDive.diveName ?? "")
                                                        diverStore.saveDivers()
                                                    }
                                                    else {
                                                        var breakLoop = false
                                                        for favorite in 0..<favoriteList.count {
                                                            if !breakLoop {
                                                                if fetchedDive.diveName == favoriteList[favorite] {
                                                                    favoriteList.remove(at: favorite)
                                                                    breakLoop = true
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
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
                                                                    if averageScore(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") != 0 {
                                                                        Text("Avg. Score: \(String(format: "%.2f", averageScore(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")))")
                                                                            .font(.system(size: 8).bold())
                                                                    }
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
                                                                diverStore.saveDivers()
                                                            }
                                                            .padding(5)
                                                            .background(
                                                                Rectangle()
                                                                    .fill(bestScores(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "", lowRange: 300, highRange: 400) ? .yellow : .clear)
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
                    }
                    if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 400, highRange: 500) || selection == 1 && !noRecentDives(lowRange: 400, highRange: 500) {
                        DisclosureGroup(isExpanded: $expandedGroup[3]) {
                            ForEach(fetchedDives) { fetchedDive in
                                if selection == 0 && fetchedDive.diveNbr - 100 > 300 && fetchedDive.diveNbr - 100 < 400 || selection == 2 && fetchedDive.diveNbr - 100 > 300 && fetchedDive.diveNbr - 100 < 400 && isFavorited(name: fetchedDive.diveName ?? "") || selection == 1 && isRecent(name: fetchedDive.diveName ?? "") {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                            Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                .onTapGesture {
                                                    if !isFavorited(name: fetchedDive.diveName ?? "") {
                                                        favoriteList.append(fetchedDive.diveName ?? "")
                                                        diverStore.saveDivers()
                                                    }
                                                    else {
                                                        var breakLoop = false
                                                        for favorite in 0..<favoriteList.count {
                                                            if !breakLoop {
                                                                if fetchedDive.diveName == favoriteList[favorite] {
                                                                    favoriteList.remove(at: favorite)
                                                                    breakLoop = true
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
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
                                                                    if averageScore(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") != 0 {
                                                                        Text("Avg. Score: \(String(format: "%.2f", averageScore(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")))")
                                                                            .font(.system(size: 8).bold())
                                                                    }
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
                                                                diverStore.saveDivers()
                                                            }
                                                            .padding(5)
                                                            .background(
                                                                Rectangle()
                                                                    .fill(bestScores(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "", lowRange: 400, highRange: 500) ? .yellow : .clear)
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
                    }
                    if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 500, highRange: 6000) || selection == 1 && !noRecentDives(lowRange: 500, highRange: 6000) {
                        DisclosureGroup(isExpanded: $expandedGroup[4]) {
                            DisclosureGroup(isExpanded: $subExpandedGroup[0]) {
                                if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 1000, highRange: 5200) || selection == 1 && !noRecentDives(lowRange: 1000, highRange: 5200) {
                                    ForEach(fetchedDives) { fetchedDive in
                                        if selection == 0 && fetchedDive.diveNbr - 100 > 400 && fetchedDive.diveNbr < 5200 || selection == 2 && fetchedDive.diveNbr - 100 > 400 && fetchedDive.diveNbr < 5200 && isFavorited(name: fetchedDive.diveName ?? "") || selection == 1 && isRecent(name: fetchedDive.diveName ?? "") {
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    Text("\(String(fetchedDive.diveNbr)) \(fetchedDive.diveName ?? "")")
                                                    Spacer()
                                                    Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                        .onTapGesture {
                                                            if !isFavorited(name: fetchedDive.diveName ?? "") {
                                                                favoriteList.append(fetchedDive.diveName ?? "")
                                                                diverStore.saveDivers()
                                                            }
                                                            else {
                                                                var breakLoop = false
                                                                for favorite in 0..<favoriteList.count {
                                                                    if !breakLoop {
                                                                        if fetchedDive.diveName == favoriteList[favorite] {
                                                                            favoriteList.remove(at: favorite)
                                                                            breakLoop = true
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
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
                                                                            if averageScore(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") != 0 {
                                                                                Text("Avg. Score: \(String(format: "%.2f", averageScore(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")))")
                                                                                    .font(.system(size: 8).bold())
                                                                            }
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
                                                                        diverStore.saveDivers()
                                                                    }
                                                                    .padding(5)
                                                                    .background(
                                                                        Rectangle()
                                                                            .fill(bestScores(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "", lowRange: 5000, highRange: 6000) ? .yellow : .clear)
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
                                
                                if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 5200, highRange: 5300) || selection == 1 && !noRecentDives(lowRange: 5200, highRange: 5300) {
                                    ForEach(fetchedDives) { fetchedDive in
                                        if selection == 0 && fetchedDive.diveNbr - 100 > 5100 && fetchedDive.diveNbr < 5300 || selection == 2 && fetchedDive.diveNbr - 100 > 400 && fetchedDive.diveNbr < 5300 && isFavorited(name: fetchedDive.diveName ?? "") {
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    Text("\(String(fetchedDive.diveNbr)) \(fetchedDive.diveName ?? "")")
                                                    Spacer()
                                                    Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                        .onTapGesture {
                                                            if !isFavorited(name: fetchedDive.diveName ?? "") {
                                                                favoriteList.append(fetchedDive.diveName ?? "")
                                                                diverStore.saveDivers()
                                                            }
                                                            else {
                                                                var breakLoop = false
                                                                for favorite in 0..<favoriteList.count {
                                                                    if !breakLoop {
                                                                        if fetchedDive.diveName == favoriteList[favorite] {
                                                                            favoriteList.remove(at: favorite)
                                                                            breakLoop = true
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
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
                                                                            if averageScore(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") != 0 {
                                                                                Text("Avg. Score: \(String(format: "%.2f", averageScore(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")))")
                                                                                    .font(.system(size: 8).bold())
                                                                            }
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
                                                                        diverStore.saveDivers()
                                                                    }
                                                                    .padding(5)
                                                                    .background(
                                                                        Rectangle()
                                                                            .fill(bestScores(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "", lowRange: 5000, highRange: 6000) ? .yellow : .clear)
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
                                
                                if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 5300, highRange: 5400) || selection == 1 && !noRecentDives(lowRange: 5300, highRange: 5400) {
                                    ForEach(fetchedDives) { fetchedDive in
                                        if selection == 0 && fetchedDive.diveNbr - 100 > 5200 && fetchedDive.diveNbr < 5400 || selection == 2 && fetchedDive.diveNbr - 100 > 5200 && fetchedDive.diveNbr < 5400 && isFavorited(name: fetchedDive.diveName ?? "") {
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    Text("\(String(fetchedDive.diveNbr)) \(fetchedDive.diveName ?? "")")
                                                    Spacer()
                                                    Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                        .onTapGesture {
                                                            if !isFavorited(name: fetchedDive.diveName ?? "") {
                                                                favoriteList.append(fetchedDive.diveName ?? "")
                                                                diverStore.saveDivers()
                                                            }
                                                            else {
                                                                var breakLoop = false
                                                                for favorite in 0..<favoriteList.count {
                                                                    if !breakLoop {
                                                                        if fetchedDive.diveName == favoriteList[favorite] {
                                                                            favoriteList.remove(at: favorite)
                                                                            breakLoop = true
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
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
                                                                            if averageScore(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") != 0 {
                                                                                Text("Avg. Score: \(String(format: "%.2f", averageScore(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")))")
                                                                                    .font(.system(size: 8).bold())
                                                                            }
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
                                                                        diverStore.saveDivers()
                                                                    }
                                                                    .padding(5)
                                                                    .background(
                                                                        Rectangle()
                                                                            .fill(bestScores(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "", lowRange: 5000, highRange: 6000) ? .yellow : .clear)
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
                                
                                if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 5400, highRange: 5500) || selection == 1 && !noRecentDives(lowRange: 5400, highRange: 5500) {
                                    ForEach(fetchedDives) { fetchedDive in
                                        if selection == 0 && fetchedDive.diveNbr - 100 > 5300 || selection == 2 && fetchedDive.diveNbr - 100 > 5300 && isFavorited(name: fetchedDive.diveName ?? "") {
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    Text("\(String(fetchedDive.diveNbr)) \(fetchedDive.diveName ?? "")")
                                                    Spacer()
                                                    Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                        .onTapGesture {
                                                            if !isFavorited(name: fetchedDive.diveName ?? "") {
                                                                favoriteList.append(fetchedDive.diveName ?? "")
                                                                diverStore.saveDivers()
                                                            }
                                                            else {
                                                                var breakLoop = false
                                                                for favorite in 0..<favoriteList.count {
                                                                    if !breakLoop {
                                                                        if fetchedDive.diveName == favoriteList[favorite] {
                                                                            favoriteList.remove(at: favorite)
                                                                            breakLoop = true
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
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
                                                                            if averageScore(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") != 0 {
                                                                                Text("Avg. Score: \(String(format: "%.2f", averageScore(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")))")
                                                                                    .font(.system(size: 8).bold())
                                                                            }
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
                                                                        diverStore.saveDivers()
                                                                    }
                                                                    .padding(5)
                                                                    .background(
                                                                        Rectangle()
                                                                            .fill(bestScores(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "", lowRange: 5000, highRange: 6000) ? .yellow : .clear)
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
                }
                .listStyle(.inset)
            }
            else if selection == 2 && favoriteList.isEmpty {
                Text("No Favorite Dives Yet!").bold()
                    .padding()
                Text("Tap the \(Image(systemName: "heart")) by a dive in the All Dives list\nto add it here")
                    .multilineTextAlignment(.center)
                Button {
                    selection = 0
                } label: {
                    Text("All Dives")
                        .padding(5)
                        .background(
                            Rectangle()
                                .stroke(lineWidth: 2)
                        )
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                .padding()
                Spacer()
            }
            else if selection == 1 && noRecentDives(lowRange: 0, highRange: 6000) {
                Text("No Recent Dives Yet!").bold()
                    .padding()
                Button {
                    selection = 0
                } label: {
                    Text("All Dives")
                        .padding(5)
                        .background(
                            Rectangle()
                                .stroke(lineWidth: 2)
                        )
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                .padding()
                Spacer()
            }
        }
        .navigationTitle("Select Dives")
    }
    
    func averageScore(name: String, position: String) -> Double {
        //find average
        var average: Double = 0
        var count: Double = 0
        let calendar = Calendar.current
        let dateRange = calendar.date(byAdding: .weekOfMonth, value: -3, to: Date())!...Date()
        for entry in diverStore.entryList {
            if entry.finished == true && dateRange.contains(entry.date!) {
                for dive in entry.dives {
                    if dive.name == name && dive.position == position {
                        average += dive.roundScore
                        count += 1
                    }
                }
            }
        }
        if count == 0 {
            count = 1
        }
        average /= count
        return average
    }
    
    func bestScores(name: String, position: String, lowRange: Int, highRange: Int) -> Bool {
        if averageScore(name: name, position: position) == 0 {
            return false
        }
    var storedScore: Double = 0
        for dive in fetchedDives {
            for withPosition in fetchedWithPositions {
                if withPosition.diveNbr == dive.diveNbr {
                    for fetchedPosition in fetchedPositions {
                        if  dive.diveNbr > lowRange && dive.diveNbr < highRange && fetchedPosition.positionId == withPosition.positionId {
                            if averageScore(name: dive.diveName ?? "", position: fetchedPosition.positionName ?? "") > averageScore(name: name, position: position) {
                                if averageScore(name: dive.diveName ?? "", position: fetchedPosition.positionName ?? "") > storedScore && storedScore != 0 {
                                    return false
                                }
                                storedScore = averageScore(name: dive.diveName ?? "", position: fetchedPosition.positionName ?? "")
                            }
                        }
                    }
                }
            }
        }
        return true
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
    
    func isFavorited(name: String) -> Bool {
        if !favoriteList.isEmpty {
            for favorite in favoriteList {
                if favorite == name {
                    return true
                }
            }
        }
        return false
    }
    
    func noFavoritedDives(lowRange: Int, highRange: Int) -> Bool {
        for dive in fetchedDives {
            if isFavorited(name: dive.diveName ?? "") && dive.diveNbr > lowRange && dive.diveNbr < highRange {
                return false
            }
        }
        return true
    }
    
    func isRecent(name: String) -> Bool {
        let calendar = Calendar.current
        let dateRange = calendar.date(byAdding: .weekOfMonth, value: -3, to: Date())!...Date()
        for entry in diverStore.entryList {
            for dive in entry.dives {
                if dive.name == name && dateRange.contains(entry.date!) && entry.finished == true {
                    return true
                }
            }
        }
        return false
    }
    func noRecentDives(lowRange: Int, highRange: Int) -> Bool {
        for dive in fetchedDives {
            if isRecent(name: dive.diveName ?? "") && dive.diveNbr > lowRange && dive.diveNbr < highRange {
                return false
            }
        }
        return true
    }
    
    func findDiveOfTheWeek() -> String {
        var tempDate = entryList.date ?? Date()
        var dateComponents = DateComponents()
        dateComponents.month = 0
        dateComponents.day = -1
        dateComponents.year = 0
        while tempDate.formatted(date: .numeric, time: .omitted) != "8/13/2023" {
            if tempDate.formatted(date: .numeric, time: .omitted) == "8/14/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "9/18/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/23/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "11/20/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/25/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/29/2024" {
                return "Forward"
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "8/21/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "9/25/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/30/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "11/27/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/1/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "2/5/2024" {
                return "Back"
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "8/28/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/2/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/4/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/8/2024" {
                return "Inward"
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "9/4/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/9/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/11/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/15/2024" {
                return "Twisting"
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "9/11/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/16/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/18/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/22/2024" {
                return "Reverse"
            }
            tempDate = Calendar.current.date(byAdding: dateComponents, to: tempDate)!
        }
        
        return ""
    }
}

struct SelectDivesView_Previews: PreviewProvider {
    static var previews: some View {
        SelectDivesView(entryList: divers(dives: [], diverEntries: diverEntry(dives: [], level: 0, name: "")), diveList: .constant([dives(name: "", degreeOfDiff: 0, score: [], position: "", roundScore: 0)]), favoriteList: .constant([]))
    }
}
