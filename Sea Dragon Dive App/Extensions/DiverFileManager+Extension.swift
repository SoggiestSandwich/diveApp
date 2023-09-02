//
//  DiverFileManager+Extension.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/28/23.
//

import Foundation

let diverFileName = "Divers.json"

extension FileManager {
    static var diverDocDirURL: URL {
        return Self.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func diverSaveDocument(contents: String, docName: String, completion: (Error?) -> Void) {
        let url = Self.diverDocDirURL.appendingPathComponent(docName)
        do {
            try contents.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            completion(error)
        }
    }
    
    func diverReadDocument(docName: String, completion: (Result<Data, Error>) -> Void) {
        let url = Self.diverDocDirURL.appendingPathComponent(docName)
        do {
            let data = try Data(contentsOf: url)
            completion(.success(data))
        } catch {
            completion(.failure(error))
        }
    }
    
    func diverDocExist(named docName: String) -> Bool {
        fileExists(atPath: Self.diverDocDirURL.appendingPathComponent(docName).path)
    }
}
