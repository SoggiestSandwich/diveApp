//
//  EventSelectionView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/18/23.
//

import SwiftUI

struct EventSelectionView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> //used to make custom back button
    @Environment(\.colorScheme) var colorScheme //detects if the device is in dark mode
    
    @EnvironmentObject var eventStore: EventStore //persistant scoring event data
    
    @State var judgeCount: Int = 0 //number of judges for an event
    @State var diveCount: Int = 0 //number of dives in an event
    @State var judgeSheet: Bool = false //sheet for selecting the judge count and dive count
    @State var confirmed: Bool = false //used in the sheet to confirm the selected judge and dive count
    @State var currentDiver: Int = -1 //used to go to results view and not effect the results
    @Binding var path: [String] //used to go back to the login view
    
    var body: some View {
        VStack {
            VStack {
                //list of all events on the device showing their date
                List {
                    ForEach(Array(zip(eventStore.eventList.indices, eventStore.eventList)), id: \.0) { index, event in
                        //if the event is finished it goes to the results view
                        if eventStore.eventList[index].finished {
                            NavigationLink(event.date, destination: ResultsView(unsortedDiverList: makeDiversListResults(index: index), event: $eventStore.eventList[index], path: $path, currentDiver: $currentDiver))
                        }
                        //if the event is not finished it goes to the scoring view
                        else {
                            NavigationLink(event.date, destination: AddDiversView(event: $eventStore.eventList[index], path: $path))
                        }
                    }
                    .onDelete(perform: eventStore.deleteEvent)
                }
                .navigationTitle("Event Selection")
            }
            Spacer()
            //opens the judge sheet
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
            .navigationBarBackButtonHidden(true) //removes the default back button
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    //go back to login screen
                    Button {
                        path = []
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .interpolation(.none).resizable().frame(width: UIScreen.main.bounds.size.height * 0.03, height: UIScreen.main.bounds.size.height * 0.03)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                }
            }
            //sheet for selecting judge and dive count
            .sheet(isPresented: $judgeSheet) {
                SelectJudgeCountView(judgeCount: $judgeCount, diveCount: $diveCount, isShowing: $judgeSheet, confirmed: $confirmed)
                    .onDisappear {
                        //when the judge and dive count have been selected and confirm is selected then add a new event with the current date
                        if judgeCount != 0 && diveCount != 0 && confirmed == true{
                            addDate()
                        }
                    }
            }
        }
        .onAppear {
            //sets the path to one item so that vavigation between views doesn't mess with the path
            if path.isEmpty {
                path = [""]
            }
        }
    }
    //adds a new event to the event store with the data from the judge sheet and the current date
    func addDate() {
        var dateString: String = ""
        var revision = 1
        dateString = Date().formatted(date: .numeric, time: .omitted)
        if !eventStore.eventList.isEmpty {
            for event in 0..<eventStore.eventList.count {
                if eventStore.eventList[(eventStore.eventList.count - 1) - event].date == dateString {
                    dateString = Date().formatted(date: .numeric, time: .omitted) + " (\(revision))"
                    revision += 1
                }
            }
        }
        eventStore.addEvent(events(date: dateString, EList: [], JVList: [], VList: [], finished: false, judgeCount: judgeCount, diveCount: diveCount, reviewed: false))
    }
    // makes a list of divers to be sent to the results view
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
        EventSelectionView(path: .constant([]))
            .environmentObject(EventStore())
    }
}
