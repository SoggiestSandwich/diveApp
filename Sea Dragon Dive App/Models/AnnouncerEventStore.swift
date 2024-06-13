//
//  AnnouncerEventStore.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/13/24.
//

import Foundation

class AnnouncerEventStore: ObservableObject {
    @Published var event: announcerEvent = announcerEvent(diver: [])
    
    init() {
        if FileManager().announcerDocExist(named: announcerFileName) {
            loadAEvent()
        }
    }
    func loadAEvent() {
        FileManager().announcerReadDocument(docName: announcerFileName) { (result) in
            switch result {
            case .success(let data):
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
    func saveEvent() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(event)
            let jsonString = String(decoding: data, as: UTF8.self)
            FileManager().announcerSaveDocument(contents: jsonString, docName: announcerFileName) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
