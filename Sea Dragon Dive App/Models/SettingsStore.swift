//
//  SettingsStore.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/4/23.
//

import Foundation

class SettingsStore: ObservableObject {
    @Published var settingsList: settings = settings(role: 0, name: "", school: "")
    
    init() {
        if FileManager().settingsDocExist(named: settingsFileName) {
            loadSetting()
        }
    }
    
    func loadSetting() {
        FileManager().readDocument(docName: settingsFileName) { (result) in
            switch result {
            case .success(let data):
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
    func saveSetting() {
        print("saving settings")
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(settingsList)
            let jsonString = String(decoding: data, as: UTF8.self)
            FileManager().saveDocument(contents: jsonString, docName: settingsFileName) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

