//
//  AnnouncerEventFileManager+Extension.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/13/24.
//

import Foundation

//file name for the announcer's persistant data
let announcerFileName = "Announcer.json"

//returns the URL for the file
extension FileManager {
    static var announcerDocDirURL: URL {
        return Self.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    //saves the contents to the file
    func announcerSaveDocument(contents: String, docName: String, completion: (Error?) -> Void) {
        let url = Self.announcerDocDirURL.appendingPathComponent(docName) //finds the url for the file
        do {
            try contents.write(to: url, atomically: true, encoding: .utf8) //writes the contents to the file
        } catch {
            completion(error)
        }
    }
    
    //reads from the file
    func announcerReadDocument(docName: String, completion: (Result<Data, Error>) -> Void) {
        let url = Self.announcerDocDirURL.appendingPathComponent(docName) //finds the url for the file
        do {
            let data = try Data(contentsOf: url) //reads the data from the url
            completion(.success(data))
        } catch {
            completion(.failure(error))
        }
    }
    
    //checks for if the file exists
    func announcerDocExist(named docName: String) -> Bool {
        fileExists(atPath: Self.announcerDocDirURL.appendingPathComponent(docName).path) //cheks for file with the docName at the url
    }
}

