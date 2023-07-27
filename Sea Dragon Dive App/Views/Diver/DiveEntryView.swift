//
//  DiveEntryView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/24/23.
//

import SwiftUI

struct DiveEntryView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var date: Date = Date()
    @State var location: String = ""
    @State var diveList: [dives] = []
    @State var level: Int = -1
    @State var diveCount: Int = 0
    @State var diveSelector = false
    
    @State var entryIndex: Int
    @State var username: String
    
    @Binding var entryList: [divers]
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Date")
                    Spacer()
                    //make date picker
                    DatePicker("", selection: $date, displayedComponents: [.date])
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
                    TextField("Enter Location", text: $location)
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
                            .fill(level == 0 ? .blue : .clear)
                            .opacity(0.5)
                            .frame(width: UIScreen.main.bounds.width * 0.23, height: UIScreen.main.bounds.height * 0.034)
                            .offset(x: UIScreen.main.bounds.width * 0.01)
                    )
                    .onTapGesture {
                        level = 0
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
                            .fill(level == 1 ? .blue : .clear)
                            .opacity(0.5)
                            .frame(width: UIScreen.main.bounds.width * 0.355, height: UIScreen.main.bounds.height * 0.034)
                    )
                    .onTapGesture {
                        level = 1
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
                            .fill(level == 2 ? .blue : .clear)
                            .opacity(0.5)
                            .frame(width: UIScreen.main.bounds.width * 0.274, height: UIScreen.main.bounds.height * 0.034)
                            .offset(x: -UIScreen.main.bounds.width * 0.01)
                    )
                    .onTapGesture {
                        level = 2
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
                    }
            }
            .overlay(
                    Rectangle()
                        .stroke(Color.black, lineWidth: 2)
            )
            //finish entry button
            Button {
                print(diveList.count)
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
                .foregroundColor(location == "" || diveList.count != diveCount || level > 2 || level < 0 || diveList.count == 0 ? colorScheme == .dark ? .white : .gray : .black)
                .padding()
            }
            .disabled(location == "" || diveList.count != diveCount || level > 2 || level < 0 || diveList.count == 0)
            //add divers buttons
            HStack {
                Button {
                    entryList.append(divers(dives: [], diverEntries: diverEntry(dives: [], level: level, name: username)))
                    diveSelector = true
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
        }
        .navigationTitle("Dive Entry")
        .sheet(isPresented: $diveSelector) {
            SelectDivesView(entryList: entryList, diveList: $diveList)
        }
    }
    func deleteDive(at offsets: IndexSet) {
        diveList.remove(atOffsets: offsets)
    }
}

struct DiveEntryView_Previews: PreviewProvider {
    static var previews: some View {
        DiveEntryView(entryIndex: 0, username: "Kakaw", entryList: .constant([divers(dives: [], diverEntries: diverEntry(dives: [], level: 0, name: ""))]))
    }
}
