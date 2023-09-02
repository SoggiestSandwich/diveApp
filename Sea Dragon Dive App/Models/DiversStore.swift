//
//  DiversStore.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/28/23.
//

import Foundation

class DiverStore: ObservableObject {
    @Published var entryList: [divers] = []
    
    init() {
        if FileManager().diverDocExist(named: diverFileName) {
            loadDiver()
        }
    }
    
    func addDiver(_ diver: divers) {
        entryList.append(diver)
        saveDivers()
    }
    
    func deleteDiver(at indexSet: IndexSet) {
        entryList.remove(atOffsets: indexSet)
        saveDivers()
    }
    
    func loadDiver() {
        FileManager().diverReadDocument(docName: diverFileName) { (result) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    entryList = try decoder.decode([divers].self, from: data)
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func saveDivers() {
        print("Saving divers to file")
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(entryList)
            let jsonString = String(decoding: data, as: UTF8.self)
            FileManager().diverSaveDocument(contents: jsonString, docName: diverFileName) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
