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
    
    @State var username: String
    @State var top6DiveScore: Double = 0
    @State var top11DiveScore: Double = 0
    @State var entryList: [divers] = []
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
                if entryList.isEmpty {
                    Text("No current dive entries")
                }
                List {
                    ForEach(Array(zip(entryList.indices, entryList)), id: \.0) { index, entry in
                        NavigationLink(destination: DiveEntryView(entryIndex: index, username: username, entryList: $entryList)) {
                                Text(entry.diverEntries.name)
                        }
                    }
                    NavigationLink(destination: DiveEntryView(entryIndex: entryList.count, username: username, entryList: $entryList)) {}
                        .opacity(0)
                        .padding(10)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                                .padding(.horizontal)
                                .padding(.horizontal)
                                .padding(.horizontal)
                                .padding(.horizontal)
                        )
                        .overlay(
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Create a Dive Entry")
                                    .font(.body.bold())
                            }
                        )
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
        DiverHomeView(username: "Kakaw")
    }
}
