//
//  DiversStore.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/28/23.
//

import Foundation

//class for storing a list of divers and a list of favorited dives in a file for perrsistant data
class DiverStore: ObservableObject {
    @Published var entryList: [divers] = [] //list of all diver events on the device
    @Published var favoriteList: [String] = [] //list of the favorited dives in diver
    
    //initializer that simply loads the data
    init() {
        if FileManager().diverDocExist(named: diverFileName) {
            loadDiver()
            loadFavorite()
        }
    }
    
    //adds a diver to entrylist
    func addDiver(_ diver: divers) {
        entryList.append(diver)
        saveDivers()
    }
    
    //deletes a diver from entrylist
    func deleteDiver(at indexSet: IndexSet) {
        entryList.remove(atOffsets: indexSet)
        saveDivers()
    }
    
    //reads from the JSON file of divers
    func loadDiver() {
        FileManager().diverReadDocument(docName: diverFileName) { (result) in
            switch result {
            case .success(let data): //if the file can be read the file is decoded into diver otherwise an error occurs
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
    
    //reads from the JSON file of favorites
    func loadFavorite() {
        FileManager().diverReadDocument(docName: favoriteFileName) { (result) in
            switch result {
            case .success(let data): //if the file can be read the file is decoded into diver otherwise an error occurs
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
    
    //saves the non-persistant data for divers into the file
    func saveDivers() {
        saveFavorites()//save the favorite dives
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(entryList) //JSON encoded data
            let jsonString = String(decoding: data, as: UTF8.self) //encoded data as a string
            FileManager().diverSaveDocument(contents: jsonString, docName: diverFileName) { (error) in //saves the jsonString into the file
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //saves the non-persistant data for favorites into the file
    func saveFavorites() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(favoriteList) //JSON encoded data
            let jsonString = String(decoding: data, as: UTF8.self) //encoded data as a string
            FileManager().diverSaveDocument(contents: jsonString, docName: favoriteFileName) { (error) in //saves the jsonString into the file
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
