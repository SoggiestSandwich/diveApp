//
//  DiverHomeView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/24/23.
//

import SwiftUI

struct DiverHomeView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var diverStore: DiverStore
    
    @State var username: String
    @State var userSchool: String
    @State var top6DiveScore: Double = 0
    @State var top11DiveScore: Double = 0
    @State var eventList: [events] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    //navigationlink or button?
                    Image(systemName: "gearshape.fill")
                        .interpolation(.none).resizable().frame(width: UIScreen.main.bounds.size.height * 0.03, height: UIScreen.main.bounds.size.height * 0.03)
                    Spacer()
                    Text(username)
                        .font(.title2.bold())
                        .padding(.leading)
                        .padding(.leading)
                        .padding(.leading)
                    Spacer()
                    Button() {
                        
                    } label: {
                        VStack {
                            Image(systemName: "qrcode.viewfinder")
                                .interpolation(.none).resizable().frame(width: UIScreen.main.bounds.size.height * 0.03, height: UIScreen.main.bounds.size.height * 0.03)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Text("Scan Results")
                                .font(.callout.bold())
                                .padding(-10)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                }
                .padding()
                .background(Color(red: 0, green: 0, blue: 0, opacity: 0.1))
                .padding(5)
                HStack {
                    Text("Diver Statistics")
                        .font(.title.bold())
                        .padding(.horizontal)
                    Spacer()
                }
                HStack {
                    Text("Top 6 Dive Score:")
                    Spacer()
                    Text(String(format: "%.2f", top6DiveScore))
                }
                .padding(.horizontal)
                HStack {
                    Text("Top 11 Dive Score:")
                    Spacer()
                    Text(String(format: "%.2f", top11DiveScore))
                }
                .padding(.horizontal)
                NavigationLink(destination: EmptyView()){
                    HStack {
                        Text("Review My Best Dive Scores")
                            .font(.body.bold())
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding()
                    .background(Color(red: 0, green: 0, blue: 0, opacity: 0.1))
                    .padding(5)
                }
                HStack {
                    Text("Dive Entries")
                        .font(.title.bold())
                        .padding(.horizontal)
                    Spacer()
                }
                if diverStore.entryList.isEmpty {
                    Text("No current dive entries")
                }
                List {
                    if !diverStore.entryList.isEmpty {
                        ForEach(Array(zip(diverStore.entryList.indices, diverStore.entryList)), id: \.0) { index, entry in
                            NavigationLink(destination: DiveEntryView(username: username, userSchool: userSchool, entryList: $diverStore.entryList[index])) {
                                if !diverStore.entryList[index].dives.isEmpty && diverStore.entryList[index].diverEntries.level != -1 && diverStore.entryList[index].location != nil {
                                    HStack {
                                        Text(diverStore.entryList[index].date?.formatted(date: .abbreviated, time: .omitted) ?? Date().formatted(date: .abbreviated, time: .omitted))
                                            .frame(width: 60)
                                        Divider()
                                        VStack {
                                            HStack {
                                                Image(systemName: "location.fill")
                                                Text(diverStore.entryList[index].location ?? "")
                                            }
                                            Text("\(diverStore.entryList[index].dives.count) dives chosen")
                                        }
                                        Spacer()
                                        Button {
                                            
                                        } label: {
                                            Text("Scan Results After Event")
                                                .padding(5)
                                                .multilineTextAlignment(.center)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(lineWidth: 2)
                                                )
                                        }
                                    }
                                }
                                else {
                                    Text("Edit Dive Entry")
                                }
                            }
                        }
                        .onDelete(perform: diverStore.deleteDiver)
                    }
                    Button {
                        diverStore.addDiver(divers(dives: [], diverEntries: diverEntry(dives: [], level: -1, name: username)))
                    } label: {
                        Rectangle()
                            .stroke(Color.black, lineWidth: 2)
                            .padding(.horizontal)
                            .padding(.horizontal)
                            .padding(.horizontal)
                            .padding(.horizontal)
                            .overlay(
                                HStack {
                                    Image(systemName: "plus.circle")
                                    Text("Create a Dive Entry")
                                        .font(.body.bold())
                                }
                            )
                    }
                }
                .listStyle(InsetListStyle())
                .scrollContentBackground(.hidden)
                HStack {
                    Text("Past Events")
                        .font(.title.bold())
                        .padding(.horizontal)
                    Spacer()
                }
                List {
                    if eventList.isEmpty {
                        Text("No past events")
                            .font(.body.bold())
                            .listRowBackground(Color(red: 0, green: 0, blue: 0, opacity: 0.1))
                    }
                    else {
                        ForEach(eventList) { event in
                            Text(event.date)
                        }
                        .listRowBackground(Color(red: 0, green: 0, blue: 0, opacity: 0.1))
                    }
                }
                .listStyle(InsetListStyle())
                .scrollContentBackground(.hidden)
            }
        }
    }
}

struct DiverHomeView_Previews: PreviewProvider {
    static var previews: some View {
        DiverHomeView(username: "Kakaw", userSchool: "School")
            .environmentObject(DiverStore())
    }
}
