//
//  EventStore.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/18/23.
//

import Foundation

//class for storing events in the persistant data of a json file
class EventStore: ObservableObject {
    @Published var eventList: [events] = [] //list of all events on the device
    
    //initializer that loads the events from the file
    init() {
        if FileManager().docExist(named: fileName) {
            loadEvent()
        }
    }
    
    //adds an event
    func addEvent(_ event: events) {
        eventList.insert(event, at: 0)
        saveEvent()
    }
    //deletes an evetn
    func deleteEvent(at indexSet: IndexSet) {
        eventList.remove(atOffsets: indexSet)
        saveEvent()
    }
    //loads an events from the json file
    func loadEvent() {
        FileManager().readDocument(docName: fileName) { (result) in
            switch result {
            case .success(let data): // if it can read from the file it decodes the file into eventList
                let decoder = JSONDecoder()
                do {
                    eventList = try decoder.decode([events].self, from: data)
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    // saves the event list into a json file
    func saveEvent() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(eventList)  //encoded json data
            let jsonString = String(decoding: data, as: UTF8.self) //encoded data in string form
            FileManager().saveDocument(contents: jsonString, docName: fileName) { (error) in //saves the json string to the file
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
