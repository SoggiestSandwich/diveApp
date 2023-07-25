//
//  DiveEntryView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/24/23.
//

import SwiftUI

struct DiveEntryView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var date: String = ""
    @State var location: String = ""
    @State var diveList: [dives] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Date")
                    Spacer()
                    //make date picker
                    Text(date)
                }
                .padding(.horizontal)
                .padding()
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
            }
            .overlay(
                    Rectangle()
                        .stroke(Color.black, lineWidth: 2)
            )
            //finish entry button
            Button {
                
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
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding()
            }
            //add divers buttons
            HStack {
                Button {
                    
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
                ForEach(diveList, id: \.hashValue) { dive in
                    Text("\(dive.code ?? "") \(dive.name), \(dive.position) (\(String(dive.degreeOfDiff)))")
                }
            }
        }
        .navigationTitle("Dive Entry")
    }
}

struct DiveEntryView_Previews: PreviewProvider {
    static var previews: some View {
        DiveEntryView()
    }
}
