//
//  SelectDivesView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/26/23.
//

import SwiftUI

struct SelectDivesView: View {
    @Environment(\.colorScheme) var colorScheme //detects if the device in dark mode
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> //used to make a custom back button
    
    @EnvironmentObject var diverStore: DiverStore //persistant diver data
    
    //tables from the database
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.diveNbr)
    ]) var fetchedDives: FetchedResults<Dive>
    @FetchRequest(entity: Position.entity(), sortDescriptors: []) var fetchedPositions: FetchedResults<Position>
    @FetchRequest(entity: WithPosition.entity(), sortDescriptors: []) var fetchedWithPositions: FetchedResults<WithPosition>
    
    @State var selection: Int = 0 //represents selection between all dives, recent dives and favorites
    @State var expandedGroup: [Bool] = [false, false, false, false, false] //array that tells which dropdown is open
    @State var subExpandedGroup: [Bool] = [false, false, false, false] //arry that tells which dropdown id open within twist dives
    
    @State var entryList: divers //list of all of the divers entries
    @Binding var diveList: [dives] //list of dives in the current entry
    @Binding var favoriteList: [String] //list of all favorited dives
    
    var body: some View {
        VStack {
            //closes the sheet
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Dismiss")
            }
            .padding()
            //selection bar
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
            //shows the list of dives if the selection isn't empty
            if selection == 0 || selection == 2 && !favoriteList.isEmpty || selection == 1 && !noRecentDives(lowRange: 0, highRange: 6000) {
                List {
                    Text("Dive of the Week: \(findDiveOfTheWeek()) Group")
                    //shows forward dives if there are dives under the selection
                    if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 100, highRange: 200) || selection == 1 && !noRecentDives(lowRange: 100, highRange: 200) {
                        //forward dives
                        DisclosureGroup(isExpanded: $expandedGroup[0]) {
                            ForEach(fetchedDives) { fetchedDive in
                                //shows all forward dives if selection = 0, all favorited dives if selection = 2 or all dives from within the last 3 months
                                if selection == 0 && fetchedDive.diveNbr - 100 < 100 || selection == 2 && fetchedDive.diveNbr - 100 < 100 && isFavorited(name: fetchedDive.diveName ?? "") || selection == 1 && isRecent(name: fetchedDive.diveName ?? "") && fetchedDive.diveNbr - 100 < 100 {
                                    VStack(alignment: .leading) {
                                        //dive name and heart
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                            Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                .onTapGesture {
                                                    //adds the selected dive to the favorite dive list or removes it if it is already on the list
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
                                        //positions for each dive
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
                                                                //adds or removes the dive from the list depending on if it is on the list
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
                                        //closes all other disclosure groups
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
                                //shows the number of forward dives in the dive list
                                Text("\(numSelected(minRange: 0, maxRange: 200)) selected")
                                    .font(.caption)
                            }
                        }
                    }
                    //shows back dives if there are dives under the selection
                    if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 200, highRange: 300) || selection == 1 && !noRecentDives(lowRange: 200, highRange: 300) {
                        //back dives
                        DisclosureGroup(isExpanded: $expandedGroup[1]) {
                            ForEach(fetchedDives) { fetchedDive in
                                //shows all back dives if selection = 0, all favorited dives if selection = 2 or all dives from within the last 3 months
                                if selection == 0 && fetchedDive.diveNbr - 100 > 100 && fetchedDive.diveNbr - 100 < 200 || selection == 2 && isFavorited(name: fetchedDive.diveName ?? "") && fetchedDive.diveNbr - 100 > 100 && fetchedDive.diveNbr - 100 < 200 || selection == 1 && isRecent(name: fetchedDive.diveName ?? "") && fetchedDive.diveNbr - 100 > 100 && fetchedDive.diveNbr - 100 < 200  {
                                    VStack(alignment: .leading) {
                                        //dive name and heart
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                            Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                .onTapGesture {
                                                    //adds the selected dive to the favorite dive list or removes it if it is already on the list
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
                                        //positions for each dive
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
                                                                //adds or removes the dive from the list depending on if it is on the list
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
                                        //closes all other disclosure groups
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
                                //shows the number of back dives in the dive list
                                Text("\(numSelected(minRange: 200, maxRange: 300)) selected")
                                    .font(.caption)
                            }
                        }
                    }
                    //shows reverse dives if there are dives under the selection
                    if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 300, highRange: 400) || selection == 1 && !noRecentDives(lowRange: 300, highRange: 400) {
                        //reverse dives
                        DisclosureGroup(isExpanded: $expandedGroup[2]) {
                            ForEach(fetchedDives) { fetchedDive in
                                //shows all reverse dives if selection = 0, all favorited dives if selection = 2 or all dives from within the last 3 months
                                if selection == 0 && fetchedDive.diveNbr - 100 > 200 && fetchedDive.diveNbr - 100 < 300 || selection == 2 && isFavorited(name: fetchedDive.diveName ?? "") && fetchedDive.diveNbr - 100 > 200 && fetchedDive.diveNbr - 100 < 300 || selection == 1 && isRecent(name: fetchedDive.diveName ?? "") && fetchedDive.diveNbr - 100 > 200 && fetchedDive.diveNbr - 100 < 300 {
                                    VStack(alignment: .leading) {
                                        //dive name and heart
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                            Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                .onTapGesture {
                                                    //adds the selected dive to the favorite dive list or removes it if it is already on the list
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
                                        //positions for each dive
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
                                                                //adds or removes the dive from the list depending on if it is on the list
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
                                        //closes all other disclosure groups
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
                                //shows the number of reverse dives in the dive list
                                Text("\(numSelected(minRange: 300, maxRange: 400)) selected")
                                    .font(.caption)
                            }
                        }
                    }
                    //shows inward dives if there are dives under the selection
                    if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 400, highRange: 500) || selection == 1 && !noRecentDives(lowRange: 400, highRange: 500) {
                        //inward dives
                        DisclosureGroup(isExpanded: $expandedGroup[3]) {
                            ForEach(fetchedDives) { fetchedDive in
                                //shows all inward dives if selection = 0, all favorited dives if selection = 2 or all dives from within the last 3 months
                                if selection == 0 && fetchedDive.diveNbr - 100 > 300 && fetchedDive.diveNbr - 100 < 400 || selection == 2 && fetchedDive.diveNbr - 100 > 300 && fetchedDive.diveNbr - 100 < 400 && isFavorited(name: fetchedDive.diveName ?? "") || selection == 1 && isRecent(name: fetchedDive.diveName ?? "") && fetchedDive.diveNbr - 100 > 300 && fetchedDive.diveNbr - 100 < 400 {
                                    VStack(alignment: .leading) {
                                        //dive name and heart
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                            Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                .onTapGesture {
                                                    //adds the selected dive to the favorite dive list or removes it if it is already on the list
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
                                        //positions for each dive
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
                                                            //adds or removes the dive from the list depending on if it is on the list
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
                                        //closes all other disclosure groups
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
                                //shows the number of inward dives in the dive list
                                Text("\(numSelected(minRange: 400, maxRange: 500)) selected")
                                    .font(.caption)
                            }
                        }
                    }
                    //shows twist dives if there are dives under the selection
                    if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 500, highRange: 6000) || selection == 1 && !noRecentDives(lowRange: 500, highRange: 6000) {
                        //twist dive sub groups
                        DisclosureGroup(isExpanded: $expandedGroup[4]) {
                            //forward twist
                            DisclosureGroup(isExpanded: $subExpandedGroup[0]) {
                                //shows all forward twist dives if selection = 0, all favorited dives if selection = 2 or all dives from within the last 3 months
                                if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 1000, highRange: 5200) || selection == 1 && !noRecentDives(lowRange: 1000, highRange: 5200) {
                                    ForEach(fetchedDives) { fetchedDive in
                                        if selection == 0 && fetchedDive.diveNbr - 100 > 400 && fetchedDive.diveNbr < 5200 || selection == 2 && fetchedDive.diveNbr - 100 > 400 && fetchedDive.diveNbr < 5200 && isFavorited(name: fetchedDive.diveName ?? "") || selection == 1 && isRecent(name: fetchedDive.diveName ?? "") && fetchedDive.diveNbr - 100 > 400 && fetchedDive.diveNbr < 5200 {
                                            VStack(alignment: .leading) {
                                                //dive name and heart
                                                HStack {
                                                    Text("\(String(fetchedDive.diveNbr)) \(fetchedDive.diveName ?? "")")
                                                    Spacer()
                                                    Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                        .onTapGesture {
                                                            //adds the selected dive to the favorite dive list or removes it if it is already on the list
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
                                                //positions for each dive
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
                                                                    //adds or removes the dive from the list depending on if it is on the list
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
                                //closes all other disclosure groups
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
                                //shows all back twist dives if selection = 0, all favorited dives if selection = 2 or all dives from within the last 3 months
                                if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 5200, highRange: 5300) || selection == 1 && !noRecentDives(lowRange: 5200, highRange: 5300) {
                                    ForEach(fetchedDives) { fetchedDive in
                                        if selection == 0 && fetchedDive.diveNbr - 100 > 5100 && fetchedDive.diveNbr < 5300 || selection == 2 && fetchedDive.diveNbr - 100 > 5100 && fetchedDive.diveNbr < 5300 && isFavorited(name: fetchedDive.diveName ?? "") {
                                            VStack(alignment: .leading) {
                                                //dive name and heart
                                                HStack {
                                                    Text("\(String(fetchedDive.diveNbr)) \(fetchedDive.diveName ?? "")")
                                                    Spacer()
                                                    Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                        .onTapGesture {
                                                            //adds the selected dive to the favorite dive list or removes it if it is already on the list
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
                                                //positions for each dive
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
                                                                    //adds or removes the dive from the list depending on if it is on the list
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
                                //closes all other disclosure groups
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
                                //shows all reverse twist dives if selection = 0, all favorited dives if selection = 2 or all dives from within the last 3 months
                                if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 5300, highRange: 5400) || selection == 1 && !noRecentDives(lowRange: 5300, highRange: 5400) {
                                    ForEach(fetchedDives) { fetchedDive in
                                        if selection == 0 && fetchedDive.diveNbr - 100 > 5200 && fetchedDive.diveNbr < 5400 || selection == 2 && fetchedDive.diveNbr - 100 > 5200 && fetchedDive.diveNbr < 5400 && isFavorited(name: fetchedDive.diveName ?? "") {
                                            VStack(alignment: .leading) {
                                                //dive name and heart
                                                HStack {
                                                    Text("\(String(fetchedDive.diveNbr)) \(fetchedDive.diveName ?? "")")
                                                    Spacer()
                                                    Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                        .onTapGesture {
                                                            //adds the selected dive to the favorite dive list or removes it if it is already on the list
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
                                                //positions for each dive
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
                                                                    //adds or removes the dive from the list depending on if it is on the list
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
                                //closes all other disclosure groups
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
                                //shows all inward twist dives if selection = 0, all favorited dives if selection = 2 or all dives from within the last 3 months
                                if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 5400, highRange: 5500) || selection == 1 && !noRecentDives(lowRange: 5400, highRange: 5500) {
                                    ForEach(fetchedDives) { fetchedDive in
                                        if selection == 0 && fetchedDive.diveNbr - 100 > 5300 || selection == 2 && fetchedDive.diveNbr - 100 > 5300 && isFavorited(name: fetchedDive.diveName ?? "") {
                                            VStack(alignment: .leading) {
                                                //dive name and heart
                                                HStack {
                                                    Text("\(String(fetchedDive.diveNbr)) \(fetchedDive.diveName ?? "")")
                                                    Spacer()
                                                    Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                        .onTapGesture {
                                                            //adds the selected dive to the favorite dive list or removes it if it is already on the list
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
                                                //positions for each dive
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
                                                                    //adds or removes the dive from the list depending on if it is on the list
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
                                //closes all other disclosure groups
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
                                //shows the number of back dives in the dive list
                                Text("\(numSelected(minRange: 500, maxRange: 6000)) selected")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .listStyle(.inset)
            }
            //empty favorite list
            else if selection == 2 && favoriteList.isEmpty {
                Text("No Favorite Dives Yet!").bold()
                    .padding()
                Text("Tap the \(Image(systemName: "heart")) by a dive in the All Dives list\nto add it here")
                    .multilineTextAlignment(.center)
                //shows all dives
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
            //no recent dives
            else if selection == 1 && noRecentDives(lowRange: 0, highRange: 6000) {
                Text("No Recent Dives Yet!").bold()
                    .padding()
                //shows all dives
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
    
    //finds the average score from dives within the last 3 months
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
    //looks through all other dives of the same category and checks if the entered has a greater average and return true if not it returns false
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
    //returns the number of selected dives within the range
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
    //returns true if the entered dive is on the dive list otherwise returns false
    func isClicked(name: String, position: String) -> Bool {
        for dive in diveList {
            if dive.name == name && dive.position == position {
                return true
            }
        }
        return false
    }
    //removes from divelist the entered dive
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
    //removes dives from divelist that have the same dive name as the entered name
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
    //returns true if the dive entered name is on the favorite list otherwis it returns false
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
    //returns true if none of the dives within the range are favorited otherwise returns false
    func noFavoritedDives(lowRange: Int, highRange: Int) -> Bool {
        for dive in fetchedDives {
            if isFavorited(name: dive.diveName ?? "") && dive.diveNbr > lowRange && dive.diveNbr < highRange {
                return false
            }
        }
        return true
    }
    //returns true if a dive of the entered name appears in the last 3 months otherwise returns false
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
    //returns false if a recent dive within in the range is found otherwise returns true
    func noRecentDives(lowRange: Int, highRange: Int) -> Bool {
        for dive in fetchedDives {
            if isRecent(name: dive.diveName ?? "") && dive.diveNbr > lowRange && dive.diveNbr < highRange {
                return false
            }
        }
        return true
    }
    //returns the dive of the week by going back one day at a time until it his the start of the dive change and returns that name
    func findDiveOfTheWeek() -> String {
        var tempDate = entryList.date ?? Date()
        var dateComponents = DateComponents()
        dateComponents.month = 0
        dateComponents.day = -1
        dateComponents.year = 0
        while tempDate.formatted(date: .numeric, time: .omitted) != "8/14/2023" {
            if tempDate.formatted(date: .numeric, time: .omitted) == "8/14/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "9/18/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/23/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "11/20/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/25/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/29/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "8/19/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "9/23/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "10/28/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "11/25/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "12/30/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "2/3/2025" {
                return "Forward"
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "8/21/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "9/25/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/30/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "11/27/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/1/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "2/5/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "8/26/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "9/30/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "11/4/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "12/2/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "1/6/2025" || tempDate.formatted(date: .numeric, time: .omitted) == "2/10/2025" {
                return "Back"
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "8/28/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/2/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/4/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/8/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "9/2/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "10/7/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "12/9/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "1/13/2025" {
                return "Inward"
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "9/4/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/9/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/11/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/15/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "9/9/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "10/14/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "12/16/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "1/20/2025" {
                return "Twisting"
            }
            else if tempDate.formatted(date: .numeric, time: .omitted) == "9/11/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "10/16/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "12/18/2023" || tempDate.formatted(date: .numeric, time: .omitted) == "1/22/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "9/16/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "10/21/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "12/23/2024" || tempDate.formatted(date: .numeric, time: .omitted) == "1/27/2025" {
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
