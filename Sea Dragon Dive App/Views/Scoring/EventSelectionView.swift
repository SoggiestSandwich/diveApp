//
//  EventSelectionView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/18/23.
//

import SwiftUI

struct EventSelectionView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var eventStore: EventStore
    
    @State var judgeCount: Int = 0
    @State var judgeSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(Array(zip(eventStore.eventList.indices, eventStore.eventList)), id: \.0) { index, event in
                        if eventStore.eventList[index].finished {
                            NavigationLink(event.date, destination: ResultsView(unsortedDiverList: makeDiversListResults(index: index), eventList: eventStore.eventList[index]))
                        }
                        else {
                            NavigationLink(event.date, destination: AddDiversView(eventList: $eventStore.eventList[index]))
                        }
                    }
                    .onDelete(perform: eventStore.deleteEvent)
                }
                .navigationTitle("Event Selection")
            }
            Spacer()
            Button("New Dive Event") {
                judgeSheet = true
            }
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .bold()
                .padding(15)
                .padding(.horizontal)
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                )
        }
        .sheet(isPresented: $judgeSheet) {
            SelectJudgeCountView(judgeCount: $judgeCount, isShowing: $judgeSheet)
                .onDisappear {
                    if judgeCount != 0 {
                        addDate()
                    }
                }
        }
    }
    func addDate() {
        var dateString: String = ""
        var revision = 1
        dateString = Date().formatted(date: .numeric, time: .omitted)
        if !eventStore.eventList.isEmpty {
            for event in eventStore.eventList {
                if event.date == dateString {
                    dateString = Date().formatted(date: .numeric, time: .omitted) + " (\(revision))"
                    revision += 1
                }
            }
        }
        eventStore.addEvent(events(date: dateString, EList: [], JVList: [], VList: [], finished: false, judgeCount: judgeCount))
    }
    
    func makeDiversListResults(index: Int) -> [divers] {
        var diverList: [divers] = []
        for diver in eventStore.eventList[index].EList {
            diverList.append(diver)
        }
        for diver in eventStore.eventList[index].JVList {
            diverList.append(diver)
        }
        for diver in eventStore.eventList[index].VList {
            diverList.append(diver)
        }
        return diverList
    }
}

struct EventSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        EventSelectionView()
            .environmentObject(EventStore())
    }
}
