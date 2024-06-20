//
//  AnnouncerEventStore.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/13/24.
//

import Foundation

//class that stores the announcer's event into persistant data
class AnnouncerEventStore: ObservableObject {
    @Published var event: announcerEvent = announcerEvent(diver: []) //the event the announcer is on
    
    //initializer that loads the announcer's event
    init() {
        if FileManager().announcerDocExist(named: announcerFileName) {
            loadAEvent()
        }
    }
    //loads the announcer's event from the file
    func loadAEvent() {
        FileManager().announcerReadDocument(docName: announcerFileName) { (result) in
            switch result {
            case .success(let data): //if the file is read the file is decoded into an announcer event
                let decoder = JSONDecoder()
                do {
                    event = try decoder.decode(announcerEvent.self, from: data)
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    //saves the announcer's event to the json file
    func saveEvent() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(event) //encoded json data
            let jsonString = String(decoding: data, as: UTF8.self) //encoded data in string form
            FileManager().announcerSaveDocument(contents: jsonString, docName: announcerFileName) { (error) in //saves the json string to the file
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
