//
//  Dive+CoreDataProperties.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/30/23.
//
//

import Foundation
import CoreData


extension Dive {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dive> {
        return NSFetchRequest<Dive>(entityName: "Dive")
    }

    @NSManaged public var diveNbr: Int64
    @NSManaged public var diveCategoryId: Int64
    @NSManaged public var subCategoryId: Int64
    @NSManaged public var diveName: String?
    @NSManaged public var category: Category?
    @NSManaged public var subCategory: Category?
    @NSManaged public var withPosition: WithPosition?
    
    public var wrappedDiveName: String {
        diveName ?? "Unknown Dive Name"
    }

}

extension Dive : Identifiable {

}
