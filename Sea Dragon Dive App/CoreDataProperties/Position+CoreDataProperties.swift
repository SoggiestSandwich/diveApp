//
//  Position+CoreDataProperties.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/30/23.
//
//

import Foundation
import CoreData


extension Position {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Position> {
        return NSFetchRequest<Position>(entityName: "Position")
    }

    @NSManaged public var positionId: Int64
    @NSManaged public var positionName: String?
    @NSManaged public var positionCode: String?
    @NSManaged public var withPosition: WithPosition?
    
    public var wrappedpositionName: String {
        positionName ?? "Unknown Position Name"
    }
    
    public var wrappedPositionCode: String {
        positionCode ?? "Unknown Position Code"
    }

}

extension Position : Identifiable {

}
