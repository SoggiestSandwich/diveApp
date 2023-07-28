//
//  EventStore.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/18/23.
//

import Foundation

class EventStore: ObservableObject {
    @Published var eventList: [events] = []
    
    init() {
        if FileManager().docExist(named: fileName) {
            loadEvent()
        }
    }
    
    func addEvent(_ event: events) {
        eventList.append(event)
        saveEvent()
    }
    func deleteEvent(at indexSet: IndexSet) {
        eventList.remove(atOffsets: indexSet)
        saveEvent()
    }
    func loadEvent() {
        FileManager().readDocument(docName: fileName) { (result) in
            switch result {
            case .success(let data):
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
    func saveEvent() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(eventList)
            let jsonString = String(decoding: data, as: UTF8.self)
            FileManager().saveDocument(contents: jsonString, docName: fileName) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
