//
//  SettingsFileManager+Extension.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/4/23.
//

import Foundation

let settingsFileName = "Settings.json"

extension FileManager {
    static var settingsDocDirURL: URL {
        return Self.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func settingsSaveDocument(contents: String, docName: String, completion: (Error?) -> Void) {
        let url = Self.settingsDocDirURL.appendingPathComponent(docName)
        do {
            try contents.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            completion(error)
        }
    }
    
    func settingsReadDocument(docName: String, completion: (Result<Data, Error>) -> Void) {
        let url = Self.settingsDocDirURL.appendingPathComponent(docName)
        do {
            let data = try Data(contentsOf: url)
            completion(.success(data))
        } catch {
            completion(.failure(error))
        }
    }
    
    func settingsDocExist(named docName: String) -> Bool {
        fileExists(atPath: Self.settingsDocDirURL.appendingPathComponent(docName).path)
    }
}

