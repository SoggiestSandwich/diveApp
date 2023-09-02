//
//  DiversStore.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/28/23.
//

import Foundation

class DiverStore: ObservableObject {
    @Published var entryList: [divers] = []
    @Published var favoriteList: [String] = []
    
    init() {
        if FileManager().diverDocExist(named: diverFileName) {
            loadDiver()
            loadFavorite()
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
    
    func loadFavorite() {
        FileManager().diverReadDocument(docName: favoriteFileName) { (result) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    favoriteList = try decoder.decode([String].self, from: data)
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func saveDivers() {
        saveFavorites()
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
    
    func saveFavorites() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(favoriteList)
            let jsonString = String(decoding: data, as: UTF8.self)
            FileManager().diverSaveDocument(contents: jsonString, docName: favoriteFileName) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
