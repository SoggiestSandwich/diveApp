//
//  WithPosition+CoreDataProperties.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/30/23.
//
//

import Foundation
import CoreData


extension WithPosition {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WithPosition> {
        return NSFetchRequest<WithPosition>(entityName: "WithPosition")
    }

    @NSManaged public var diveNbr: Int64
    @NSManaged public var positionId: Int64
    @NSManaged public var degreeOfDifficulty: Float
    @NSManaged public var dive: NSSet?
    @NSManaged public var position: NSSet?
    
    public var diveArray: [Dive] {
        let set = dive as? Set<Dive> ?? []
        
        return set.sorted {
            $0.diveNbr < $1.diveNbr
        }
    }
    
    public var positionArray: [Position] {
        let set = position as? Set<Position> ?? []
        
        return set.sorted {
            $0.positionId < $1.positionId
        }
    }

}

// MARK: Generated accessors for dive
extension WithPosition {

    @objc(addDiveObject:)
    @NSManaged public func addToDive(_ value: Dive)

    @objc(removeDiveObject:)
    @NSManaged public func removeFromDive(_ value: Dive)

    @objc(addDive:)
    @NSManaged public func addToDive(_ values: NSSet)

    @objc(removeDive:)
    @NSManaged public func removeFromDive(_ values: NSSet)

}

// MARK: Generated accessors for position
extension WithPosition {

    @objc(addPositionObject:)
    @NSManaged public func addToPosition(_ value: Position)

    @objc(removePositionObject:)
    @NSManaged public func removeFromPosition(_ value: Position)

    @objc(addPosition:)
    @NSManaged public func addToPosition(_ values: NSSet)

    @objc(removePosition:)
    @NSManaged public func removeFromPosition(_ values: NSSet)

}

extension WithPosition : Identifiable {

}
