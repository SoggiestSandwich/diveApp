//
//  DiveEntryView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/24/23.
//

import SwiftUI

struct DiveEntryView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var diverStore: DiverStore
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.diveNbr)
    ]) var fetchedDives: FetchedResults<Dive>
    @FetchRequest(entity: Position.entity(), sortDescriptors: []) var fetchedPositions: FetchedResults<Position>
    @FetchRequest(entity: WithPosition.entity(), sortDescriptors: []) var fetchedWithPositions: FetchedResults<WithPosition>

    @State var diveList: [dives] = []
    @State var diveCount: Int = 0
    @State var diveSelector = false
    @State var signingSheet: Bool = false
    
    @State var username: String
    @State var userSchool: String
    
    @Binding var entryList: divers
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Date")
                    Spacer()
                    //make date picker
                    DatePicker("", selection: $entryList.date, displayedComponents: [.date])
                }
                .padding(.horizontal)
                .offset(y: UIScreen.main.bounds.height * 0.008)
                Divider()
                    .background(Color.black)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                    )
                HStack {
                    Text("Location")
                    Spacer()
                    TextField("Enter Location", text: $entryList.location)
                        .multilineTextAlignment(.trailing)
                }
                .offset(y: -UIScreen.main.bounds.height * 0.005)
                .padding(.vertical)
                .padding(.horizontal)
            }
            .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 2)
            )
            .padding(5)
            //level picker
            HStack {
                Text("Varsity")
                    .font(.caption.bold())
                    .padding(5)
                    .padding(.horizontal)
                    .overlay(
                        Rectangle()
                            .fill(entryList.level == 0 ? .blue : .clear)
                            .opacity(0.5)
                            .frame(width: UIScreen.main.bounds.width * 0.23, height: UIScreen.main.bounds.height * 0.034)
                            .offset(x: UIScreen.main.bounds.width * 0.01)
                    )
                    .onTapGesture {
                        entryList.level = 0
                        diverStore.saveDivers()
                    }
                Divider()
                    .frame(height: 30)
                    .overlay(
                        Rectangle()
                            .frame(width: 2)
                    )
                Text("Junior Varsity")
                    .font(.caption.bold())
                    .padding(5)
                    .padding(.horizontal)
                    .overlay(
                        Rectangle()
                            .fill(entryList.level == 1 ? .blue : .clear)
                            .opacity(0.5)
                            .frame(width: UIScreen.main.bounds.width * 0.355, height: UIScreen.main.bounds.height * 0.034)
                    )
                    .onTapGesture {
                        entryList.level = 1
                        diverStore.saveDivers()
                    }
                Divider()
                    .frame(height: 30)
                    .overlay(
                        Rectangle()
                            .frame(width: 2)
                    )
                Text("Exhibition")
                    .font(.caption.bold())
                    .padding(5)
                    .padding(.horizontal)
                    .overlay(
                        Rectangle()
                            .fill(entryList.level == 2 ? .blue : .clear)
                            .opacity(0.5)
                            .frame(width: UIScreen.main.bounds.width * 0.274, height: UIScreen.main.bounds.height * 0.034)
                            .offset(x: -UIScreen.main.bounds.width * 0.01)
                    )
                    .onTapGesture {
                        entryList.level = 2
                        diverStore.saveDivers()
                    }
            }
            .overlay(
                    Rectangle()
                        .stroke(Color.black, lineWidth: 2)
            )
            //dives picker
            HStack {
                Text("Six Dives")
                    .font(.caption.bold())
                    .padding(5)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .overlay(
                        Rectangle()
                            .fill(diveCount == 6 ? .blue : .clear)
                            .opacity(0.5)
                            .frame(width: UIScreen.main.bounds.width * 0.35, height: UIScreen.main.bounds.height * 0.034)
                            .offset(x: UIScreen.main.bounds.width * 0.01)
                    )
                    .onTapGesture {
                        diveCount = 6
                        diverStore.saveDivers()
                    }
                Divider()
                    .frame(height: 30)
                    .overlay(
                        Rectangle()
                            .frame(width: 2)
                    )
                Text("Eleven Dives")
                    .font(.caption.bold())
                    .padding(5)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .overlay(
                        Rectangle()
                            .fill(diveCount == 11 ? .blue : .clear)
                            .opacity(0.5)
                            .frame(width: UIScreen.main.bounds.width * 0.395, height: UIScreen.main.bounds.height * 0.034)
                            .offset(x: -UIScreen.main.bounds.width * 0.01)
                    )
                    .onTapGesture {
                        diveCount = 11
                        diverStore.saveDivers()
                    }
            }
            .overlay(
                    Rectangle()
                        .stroke(Color.black, lineWidth: 2)
            )
            //finish entry button
            Button {
                signingSheet = true
                encodeDives()
                diverStore.saveDivers()
            } label: {
                HStack {
                    Image(systemName: "signature")
                    Text("Sign and give to coach")
                        .font(.body.bold())
                }
                .padding()
                .overlay(
                    Rectangle()
                        .stroke(lineWidth: 2)
                )
                .foregroundColor(entryList.location == "" || diveList.count != diveCount || entryList.level > 2 || entryList.level < 0 || diveList.count == 0 ? colorScheme == .dark ? .white : .gray : .black)
                .padding()
            }
            .disabled(entryList.location == "" || diveList.count != diveCount || entryList.level > 2 || entryList.level < 0 || diveList.count == 0)
            //add divers buttons
            HStack {
                Button {
                    diveSelector = true
                    diverStore.saveDivers()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Dives")
                            .font(.body.bold())
                }
                    .padding()
                    .overlay(
                        Rectangle()
                            .stroke(lineWidth: 2)
                    )
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                Button {
                    
                    diverStore.saveDivers()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Auto-Add Best Dives")
                            .font(.body.bold())
                    }
                    .padding()
                    .overlay(
                        Rectangle()
                            .stroke(lineWidth: 2)
                    )
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
            //dives list
            HStack {
                Text("Your Dives")
                    .font(.title.bold())
                Spacer()
            }
            .padding(.horizontal)
            List {
                if !diveList.isEmpty {
                    ForEach(Array(zip(diveList.indices, diveList)), id: \.0) { index, dive in
                        Text("\(index + 1). \(dive.code ?? "") \(dive.name), \(dive.position) (\(String(dive.degreeOfDiff)))")
                    }
                    .onDelete(perform: deleteDive)
                    .onMove { (indexSet, index) in
                        self.diveList.move(fromOffsets: indexSet, toOffset: index)
                    }
                }
                else {
                    Text("No dives added")
                }
            }
            .environment(\.editMode, .constant(.active))
            if !diveList.isEmpty {
                Text("Based on your past scores:\nYour predicted score for this set of dives is (average) points\nThe best set of dives would score a predicted (bestDivesScore) points")
                    .font(.caption)
                Button {
                    while !diveList.isEmpty {
                        diveList.removeFirst()
                        diverStore.saveDivers()
                    }
                } label: {
                    Text("Reset Dives")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    diverStore.saveDivers()
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                }
            }
        }
        .navigationTitle("Dive Entry")
        .sheet(isPresented: $diveSelector) {
            SelectDivesView(entryList: entryList, diveList: $diveList)
        }
        .sheet(isPresented: $signingSheet) {
            SigningView(entry: $entryList)
        }
    }
    func deleteDive(at offsets: IndexSet) {
        diveList.remove(atOffsets: offsets)
    }
    
//    func findAverageScores() -> Double {
//        var average: Double = 0
//        var count: Double = 0
//        for entry in entryList {
//            for entryDive in entry.dives {
//                for dive in diveList {
//                    if entryDive.name == dive.name && entryDive.position == dive.position {
//                        average += entryDive.roundScore
//                        count += 1
//                    }
//                }
//            }
//        }
//        if count == 0 {
//            count = 1
//        }
//        return average / count
//    }
    
    func encodeDives() {
        for dive in diveList {
            entryList.diverEntries.dives.append(dive.code ?? "")
        }
    }
}

struct DiveEntryView_Previews: PreviewProvider {
    static var previews: some View {
        DiveEntryView(username: "Kakaw", userSchool: "", entryList: .constant(divers(dives: [], diverEntries: diverEntry(dives: [], level: 0, name: ""))))
    }
}
