//
//  AnnouncerEventFileManager+Extension.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/13/24.
//

import Foundation

let announcerFileName = "Announcer.json"

extension FileManager {
    static var announcerDocDirURL: URL {
        return Self.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func announcerSaveDocument(contents: String, docName: String, completion: (Error?) -> Void) {
        let url = Self.announcerDocDirURL.appendingPathComponent(docName)
        do {
            try contents.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            completion(error)
        }
    }
    
    func announcerReadDocument(docName: String, completion: (Result<Data, Error>) -> Void) {
        let url = Self.announcerDocDirURL.appendingPathComponent(docName)
        do {
            let data = try Data(contentsOf: url)
            completion(.success(data))
        } catch {
            completion(.failure(error))
        }
    }
    
    func announcerDocExist(named docName: String) -> Bool {
        fileExists(atPath: Self.announcerDocDirURL.appendingPathComponent(docName).path)
    }
}

