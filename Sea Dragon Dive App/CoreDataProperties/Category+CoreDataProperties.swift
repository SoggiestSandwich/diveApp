//
//  Category+CoreDataProperties.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/30/23.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var categoryId: Int64
    @NSManaged public var categoryName: String?
    @NSManaged public var catDive: NSSet?
    @NSManaged public var subCatDive: NSSet?
    
    public var wrappedCategoryName: String {
        categoryName ?? "Unknown Category Name"
    }
    
    public var catDiveArray: [Dive] {
        let set = catDive as? Set<Dive> ?? []
        
        return set.sorted {
            $0.diveNbr < $1.diveNbr
        }
    }
    
    public var subCatDiveArray: [Dive] {
        let set = subCatDive as? Set<Dive> ?? []
        
        return set.sorted {
            $0.diveNbr < $1.diveNbr
        }
    }

}

// MARK: Generated accessors for catDive
extension Category {

    @objc(addCatDiveObject:)
    @NSManaged public func addToCatDive(_ value: Dive)

    @objc(removeCatDiveObject:)
    @NSManaged public func removeFromCatDive(_ value: Dive)

    @objc(addCatDive:)
    @NSManaged public func addToCatDive(_ values: NSSet)

    @objc(removeCatDive:)
    @NSManaged public func removeFromCatDive(_ values: NSSet)

}

// MARK: Generated accessors for subCatDive
extension Category {

    @objc(addSubCatDiveObject:)
    @NSManaged public func addToSubCatDive(_ value: Dive)

    @objc(removeSubCatDiveObject:)
    @NSManaged public func removeFromSubCatDive(_ value: Dive)

    @objc(addSubCatDive:)
    @NSManaged public func addToSubCatDive(_ values: NSSet)

    @objc(removeSubCatDive:)
    @NSManaged public func removeFromSubCatDive(_ values: NSSet)

}

extension Category : Identifiable {

}
