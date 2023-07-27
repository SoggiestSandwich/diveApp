//
//  SelectDivesView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/26/23.
//

import SwiftUI

struct SelectDivesView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.diveNbr)
    ]) var fetchedDives: FetchedResults<Dive>
    @FetchRequest(entity: Position.entity(), sortDescriptors: []) var fetchedPositions: FetchedResults<Position>
    @FetchRequest(entity: WithPosition.entity(), sortDescriptors: []) var fetchedWithPositions: FetchedResults<WithPosition>
    
    @State var selection: Int = 0
    @State var expandedGroup: [Bool] = [false, false, false, false, false]
    @State var favoriteList: [String] = []
    
    @State var entryList: [divers]
    @Binding var diveList: [dives]
    
    var body: some View {
        NavigationStack {
            HStack {
                Text("All Dives")
                    .font(.caption.bold())
                    .padding(5)
                    .padding(.horizontal)
                    .overlay(
                        Rectangle()
                            .fill(selection == 0 ? .blue : .clear)
                            .opacity(0.5)
                            .frame(width: UIScreen.main.bounds.width * 0.26, height: UIScreen.main.bounds.height * 0.034)
                            .offset(x: UIScreen.main.bounds.width * 0.01)
                    )
                    .onTapGesture {
                        selection = 0
                    }
                Divider()
                    .frame(height: 30)
                    .overlay(
                        Rectangle()
                            .frame(width: 2)
                    )
                Text("My Recent Dives")
                    .font(.caption.bold())
                    .padding(5)
                    .padding(.horizontal)
                    .overlay(
                        Rectangle()
                            .fill(selection == 1 ? .blue : .clear)
                            .opacity(0.5)
                            .frame(width: UIScreen.main.bounds.width * 0.394, height: UIScreen.main.bounds.height * 0.034)
                    )
                    .onTapGesture {
                        selection = 1
                    }
                Divider()
                    .frame(height: 30)
                    .overlay(
                        Rectangle()
                            .frame(width: 2)
                    )
                Text("Favorites")
                    .font(.caption.bold())
                    .padding(5)
                    .padding(.horizontal)
                    .overlay(
                        Rectangle()
                            .fill(selection == 2 ? .blue : .clear)
                            .opacity(0.5)
                            .frame(width: UIScreen.main.bounds.width * 0.26, height: UIScreen.main.bounds.height * 0.034)
                            .offset(x: -UIScreen.main.bounds.width * 0.01)
                    )
                    .onTapGesture {
                        selection = 2
                    }
            }
            .overlay(
                Rectangle()
                    .stroke(Color.black, lineWidth: 2)
            )
            .padding(.vertical)
            if selection == 0 || selection == 2 && !favoriteList.isEmpty {
                List {
                    if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 100, highRange: 200) {
                        DisclosureGroup(isExpanded: $expandedGroup[0]) {
                            ForEach(fetchedDives) { fetchedDive in
                                if selection == 0 && fetchedDive.diveNbr - 100 < 100 || selection == 2 && fetchedDive.diveNbr - 100 < 100 && isFavorited(name: fetchedDive.diveName ?? "") {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                            Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                .onTapGesture {
                                                    if !isFavorited(name: fetchedDive.diveName ?? "") {
                                                        favoriteList.append(fetchedDive.diveName ?? "")
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
                                                                    .onTapGesture {
                                                                        if !isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") {
                                                                            
                                                                            removeDivesWithSameName(name: fetchedDive.diveName ?? "")
                                                                            
                                                                            diveList.append(dives(name: fetchedDive.diveName ?? "", degreeOfDiff: fetchedWithPosition.degreeOfDifficulty, score: [], position: fetchedPosition.positionName ?? "", roundScore: 0))
                                                                        }
                                                                        else {
                                                                            removeSelectedDive(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")
                                                                        }
                                                                    }
                                                                VStack {
                                                                    Text("\(fetchedPosition.positionName == "Straight" ? "Str" : fetchedPosition.positionName ?? "") (\(String(fetchedWithPosition.degreeOfDifficulty)))")
                                                                        .font(.caption.bold())
                                                                    Text("Avg. Score: \(String(averageScore()))")
                                                                        .font(.system(size: 8).bold())
                                                                }
                                                            }
                                                        }
                                                    }
                                                    .padding(5)
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
                        } label: {
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
                        }
                    }
                    if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 200, highRange: 300) {
                        DisclosureGroup(isExpanded: $expandedGroup[1]) {
                            ForEach(fetchedDives) { fetchedDive in
                                if selection == 0 && fetchedDive.diveNbr - 100 > 100 && fetchedDive.diveNbr - 100 < 200 || selection == 2 && isFavorited(name: fetchedDive.diveName ?? "") && fetchedDive.diveNbr - 100 > 100 && fetchedDive.diveNbr - 100 < 200  {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                            Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                .onTapGesture {
                                                    if !isFavorited(name: fetchedDive.diveName ?? "") {
                                                        favoriteList.append(fetchedDive.diveName ?? "")
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
                                                                    .onTapGesture {
                                                                        if !isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") {
                                                                            
                                                                            removeDivesWithSameName(name: fetchedDive.diveName ?? "")
                                                                            
                                                                            diveList.append(dives(name: fetchedDive.diveName ?? "", degreeOfDiff: fetchedWithPosition.degreeOfDifficulty, score: [], position: fetchedPosition.positionName ?? "", roundScore: 0))
                                                                        }
                                                                        else {
                                                                            removeSelectedDive(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")
                                                                        }
                                                                    }
                                                                VStack {
                                                                    Text("\(fetchedPosition.positionName == "Straight" ? "Str" : fetchedPosition.positionName ?? "") (\(String(fetchedWithPosition.degreeOfDifficulty)))")
                                                                        .font(.caption.bold())
                                                                    Text("Avg. Score: \(String(averageScore()))")
                                                                        .font(.system(size: 8).bold())
                                                                }
                                                            }
                                                        }
                                                    }
                                                    .padding(5)
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
                        } label: {
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
                        }
                    }
                    if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 300, highRange: 400) {
                        DisclosureGroup(isExpanded: $expandedGroup[2]) {
                            ForEach(fetchedDives) { fetchedDive in
                                if selection == 0 && fetchedDive.diveNbr - 100 > 200 && fetchedDive.diveNbr - 100 < 300 || selection == 2 && isFavorited(name: fetchedDive.diveName ?? "") && fetchedDive.diveNbr - 100 > 200 && fetchedDive.diveNbr - 100 < 300 {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                            Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                .onTapGesture {
                                                    if !isFavorited(name: fetchedDive.diveName ?? "") {
                                                        favoriteList.append(fetchedDive.diveName ?? "")
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
                                                                    .onTapGesture {
                                                                        if !isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") {
                                                                            
                                                                            removeDivesWithSameName(name: fetchedDive.diveName ?? "")
                                                                            
                                                                            diveList.append(dives(name: fetchedDive.diveName ?? "", degreeOfDiff: fetchedWithPosition.degreeOfDifficulty, score: [], position: fetchedPosition.positionName ?? "", roundScore: 0))
                                                                        }
                                                                        else {
                                                                            removeSelectedDive(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")
                                                                        }
                                                                    }
                                                                VStack {
                                                                    Text("\(fetchedPosition.positionName == "Straight" ? "Str" : fetchedPosition.positionName ?? "") (\(String(fetchedWithPosition.degreeOfDifficulty)))")
                                                                        .font(.caption.bold())
                                                                    Text("Avg. Score: \(String(averageScore()))")
                                                                        .font(.system(size: 8).bold())
                                                                }
                                                            }
                                                        }
                                                    }
                                                    .padding(5)
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
                        } label: {
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
                        }
                    }
                    if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 400, highRange: 500) {
                        DisclosureGroup(isExpanded: $expandedGroup[3]) {
                            ForEach(fetchedDives) { fetchedDive in
                                if selection == 0 && fetchedDive.diveNbr - 100 > 300 && fetchedDive.diveNbr - 100 < 400 || selection == 2 && fetchedDive.diveNbr - 100 > 300 && fetchedDive.diveNbr - 100 < 400 && isFavorited(name: fetchedDive.diveName ?? "") {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(fetchedDive.diveNbr) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                            Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                .onTapGesture {
                                                    if !isFavorited(name: fetchedDive.diveName ?? "") {
                                                        favoriteList.append(fetchedDive.diveName ?? "")
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
                                                                    .onTapGesture {
                                                                        if !isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") {
                                                                            
                                                                            removeDivesWithSameName(name: fetchedDive.diveName ?? "")
                                                                            
                                                                            diveList.append(dives(name: fetchedDive.diveName ?? "", degreeOfDiff: fetchedWithPosition.degreeOfDifficulty, score: [], position: fetchedPosition.positionName ?? "", roundScore: 0))
                                                                        }
                                                                        else {
                                                                            removeSelectedDive(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")
                                                                        }
                                                                    }
                                                                VStack {
                                                                    Text("\(fetchedPosition.positionName == "Straight" ? "Str" : fetchedPosition.positionName ?? "") (\(String(fetchedWithPosition.degreeOfDifficulty)))")
                                                                        .font(.caption.bold())
                                                                    Text("Avg. Score: \(String(averageScore()))")
                                                                        .font(.system(size: 8).bold())
                                                                }
                                                            }
                                                        }
                                                    }
                                                    .padding(5)
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
                        } label: {
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
                        }
                    }
                    if selection == 0 || selection == 2 && !noFavoritedDives(lowRange: 500, highRange: 6000) {
                        DisclosureGroup(isExpanded: $expandedGroup[4]) {
                            ForEach(fetchedDives) { fetchedDive in
                                if selection == 0 && fetchedDive.diveNbr - 100 > 400 || selection == 2 && fetchedDive.diveNbr - 100 > 400 && isFavorited(name: fetchedDive.diveName ?? "") {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(String(fetchedDive.diveNbr)) \(fetchedDive.diveName ?? "")")
                                            Spacer()
                                            Image(systemName: isFavorited(name: fetchedDive.diveName ?? "") ? "heart.fill" : "heart")
                                                .onTapGesture {
                                                    if !isFavorited(name: fetchedDive.diveName ?? "") {
                                                        favoriteList.append(fetchedDive.diveName ?? "")
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
                                                                    .onTapGesture {
                                                                        if !isClicked(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "") {
                                                                            
                                                                            removeDivesWithSameName(name: fetchedDive.diveName ?? "")
                                                                            
                                                                            diveList.append(dives(name: fetchedDive.diveName ?? "", degreeOfDiff: fetchedWithPosition.degreeOfDifficulty, score: [], position: fetchedPosition.positionName ?? "", roundScore: 0))
                                                                        }
                                                                        else {
                                                                            removeSelectedDive(name: fetchedDive.diveName ?? "", position: fetchedPosition.positionName ?? "")
                                                                        }
                                                                    }
                                                                VStack {
                                                                    Text("\(fetchedPosition.positionName == "Straight" ? "Str" : fetchedPosition.positionName ?? "") (\(String(fetchedWithPosition.degreeOfDifficulty)))")
                                                                        .font(.caption.bold())
                                                                    Text("Avg. Score: \(String(averageScore()))")
                                                                        .font(.system(size: 8).bold())
                                                                }
                                                            }
                                                        }
                                                    }
                                                    .padding(5)
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
                        } label: {
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
        }
        .navigationTitle("Select Dives")
    }
    func averageScore() -> Double {
        //find average
        var average: Double = 0
        for entry in entryList {
            average += entry.diverEntries.totalScore ?? 0
        }
        average /= Double(entryList.count)
        return average
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
        for favorite in favoriteList {
            if favorite == name {
                return true
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
}

struct SelectDivesView_Previews: PreviewProvider {
    static var previews: some View {
        SelectDivesView(entryList: [divers(dives: [], diverEntries: diverEntry(dives: [], level: 0, name: ""))], diveList: .constant([dives(name: "", degreeOfDiff: 0, score: [], position: "", roundScore: 0)]))
    }
}
