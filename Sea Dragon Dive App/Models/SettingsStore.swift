//
//  SettingsStore.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/4/23.
//

import Foundation

//class for saving the settings to persistant data
class SettingsStore: ObservableObject {
    @Published var settingsList: settings = settings(role: 0, name: "", school: "") //the setting that have been chosen
    
    //initializer that loads from the file
    init() {
        if FileManager().settingsDocExist(named: settingsFileName) {
            loadSetting()
        }
    }
    
    //loads the settings from the file
    func loadSetting() {
        FileManager().readDocument(docName: settingsFileName) { (result) in
            switch result {
            case .success(let data): //if it can read from the file it decodes it into settings otherwise it fails
                let decoder = JSONDecoder()
                do {
                    settingsList = try decoder.decode(settings.self, from: data)
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    //saves the settings into the json file
    func saveSetting() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(settingsList)   //encoded json data
            let jsonString = String(decoding: data, as: UTF8.self) //encoded data in string form
            FileManager().saveDocument(contents: jsonString, docName: settingsFileName) { (error) in //saves the json string to the file
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

