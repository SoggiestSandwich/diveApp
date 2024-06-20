//
//  CoachEntryStore.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/16/23.
//

import Foundation

//class for storing coaches entries into json files as persistant data
class CoachEntryStore: ObservableObject {
    @Published var coachesList: [coachEntry] = [] //list of all coach entries on the device
    
    //initilizer that loads the coaches entries
    init() {
        if FileManager().docExist(named: diverEntryFileName) {
            loadCoachEntry()
        }
    }
    
    //adds a coach entry to the coaches list
    func addCoachEntry(_ coachEntry: coachEntry) {
        coachesList.insert(coachEntry, at: 0)
        saveDiverEntry()
    }
    //deletes a coach entry from the coaches list
    func deleteCoachEntry(at indexSet: IndexSet) {
        coachesList.remove(atOffsets: indexSet)
        saveDiverEntry()
    }
    //loads coaches entries from a json file
    func loadCoachEntry() {
        FileManager().readDocument(docName: diverEntryFileName) { (result) in
            switch result {
            case .success(let data): // if it can read the file it decodes the file into coachesList
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
    //saves the coaches entries into a json file
    func saveDiverEntry() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(coachesList) //encoded json data
            let jsonString = String(decoding: data, as: UTF8.self) //encoded data in string form
            FileManager().saveDocument(contents: jsonString, docName: diverEntryFileName) { (error) in //saves the jsonString to the file or errors
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

