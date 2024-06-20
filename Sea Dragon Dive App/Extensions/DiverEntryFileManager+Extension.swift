//
//  DiverEntryFileManager+Extension.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/16/23.
//

import Foundation

//file name for the diver's entries persistant data
let diverEntryFileName = "diverEntries.json"

//returns the URL for the file
extension FileManager {
    static var diverEntryDocDirURL: URL {
        return Self.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    //saves the contents to the file
    func diverEntrySaveDocument(contents: String, docName: String, completion: (Error?) -> Void) {
        let url = Self.diverEntryDocDirURL.appendingPathComponent(docName) //finds the url for the file
        do {
            try contents.write(to: url, atomically: true, encoding: .utf8) //writes the contents to the file
        } catch {
            completion(error)
        }
    }
    
    //reads from the file
    func diverEntryReadDocument(docName: String, completion: (Result<Data, Error>) -> Void) {
        let url = Self.diverEntryDocDirURL.appendingPathComponent(docName) //finds the url for the file
        do {
            let data = try Data(contentsOf: url) //reads the data from the url
            completion(.success(data))
        } catch {
            completion(.failure(error))
        }
    }
    
    //checks for if the file exists
    func diverEntryDocExist(named docName: String) -> Bool {
        fileExists(atPath: Self.diverEntryDocDirURL.appendingPathComponent(docName).path) //cheks for file with the docName at the url
    }
}
