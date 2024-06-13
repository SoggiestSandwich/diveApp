//
//  CoachEntryStore.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/16/23.
//

import Foundation

class CoachEntryStore: ObservableObject {
    @Published var coachesList: [coachEntry] = []
    
    init() {
        if FileManager().docExist(named: diverEntryFileName) {
            loadDiverEntry()
        }
    }
    
    func addDiverEntry(_ coachEntry: coachEntry) {
        coachesList.insert(coachEntry, at: 0)
        saveDiverEntry()
    }
    func deleteDiverEntry(at indexSet: IndexSet) {
        coachesList.remove(atOffsets: indexSet)
        saveDiverEntry()
    }
    func loadDiverEntry() {
        FileManager().readDocument(docName: diverEntryFileName) { (result) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    coachesList = try decoder.decode([coachEntry].self, from: data)
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    func saveDiverEntry() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(coachesList)
            let jsonString = String(decoding: data, as: UTF8.self)
            FileManager().saveDocument(contents: jsonString, docName: diverEntryFileName) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

