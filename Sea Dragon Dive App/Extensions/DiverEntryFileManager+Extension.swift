//
//  DiverEntryFileManager+Extension.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/16/23.
//

import Foundation

let diverEntryFileName = "diverEntries.json"

extension FileManager {
    static var diverEntryDocDirURL: URL {
        return Self.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func diverEntrySaveDocument(contents: String, docName: String, completion: (Error?) -> Void) {
        let url = Self.diverEntryDocDirURL.appendingPathComponent(docName)
        do {
            try contents.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            completion(error)
        }
    }
    
    func diverEntryReadDocument(docName: String, completion: (Result<Data, Error>) -> Void) {
        let url = Self.diverEntryDocDirURL.appendingPathComponent(docName)
        do {
            let data = try Data(contentsOf: url)
            completion(.success(data))
        } catch {
            completion(.failure(error))
        }
    }
    
    func diverEntryDocExist(named docName: String) -> Bool {
        fileExists(atPath: Self.diverEntryDocDirURL.appendingPathComponent(docName).path)
    }
}
