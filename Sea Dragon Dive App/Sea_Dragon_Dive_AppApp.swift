//
//  Sea_Dragon_Dive_AppApp.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/15/23.
//

import SwiftUI

@main
struct Sea_Dragon_Dive_AppApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        let preloadedDataKey = "didPreloadData"
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: preloadedDataKey) == false {
            guard let urlPath = Bundle.main.url(forResource: "DiveData", withExtension: "plist") else {
                return
            }
            
            let backgroundContext = persistenceController.container.newBackgroundContext()
            
            backgroundContext.perform {
                
                if let arrayContents = NSArray(contentsOf: urlPath) as? [[String : Any]] {
                    do {
                        for num in 0..<arrayContents.count {
                            //preload Position table
                            if num == 0 {
                                let positionIds = arrayContents[num]["positionId"] as! [Int64]
                                let positionNames = arrayContents[num]["positionName"] as! [String]
                                let positionCodes = arrayContents[num]["positionCode"] as! [String]
                                
                                for num in 0..<positionIds.count {
                                    let positionObject = Position(context: backgroundContext)
                                    positionObject.positionId = positionIds[num]
                                    positionObject.positionName = positionNames[num]
                                    positionObject.positionCode = positionCodes[num]
                                }
                            }
                            //preload WithPosition table
                            else if num == 1 {
                                let diveNbrs = arrayContents[num]["diveNbr"] as! [Int64]
                                let positionIds = arrayContents[num]["positionId"] as! [Int64]
                                let degreeOfDifficulties = arrayContents[num]["degreeOfDifficulty"] as! [Double]
                                
                                for num in 0..<diveNbrs.count {
                                    let withPositionObject = WithPosition(context: backgroundContext)
                                    withPositionObject.diveNbr = diveNbrs[num]
                                    withPositionObject.positionId = positionIds[num]
                                    withPositionObject.degreeOfDifficulty = degreeOfDifficulties[num]
                                }
                            }
                            //preload Dive table
                            else if num == 2 {
                                let diveNbrs = arrayContents[num]["diveNbr"] as! [Int64]
                                let diveCategoryIds = arrayContents[num]["diveCategoryId"] as! [Int64]
                                let subCategoryIds = arrayContents[num]["subCategoryId"] as! [Int64]
                                let diveNames = arrayContents[num]["diveName"] as! [String]
                                
                                for num in 0..<diveNbrs.count {
                                    let diveObject = Dive(context: backgroundContext)
                                    diveObject.diveNbr = diveNbrs[num]
                                    diveObject.diveCategoryId = diveCategoryIds[num]
                                    diveObject.subCategoryId = subCategoryIds[num]
                                    diveObject.diveName = diveNames[num]
                                }
                            }
                            //preload Category Table
                            else if num == 3 {
                                let categoryIds = arrayContents[num]["categoryId"] as! [Int64]
                                let categoryNames = arrayContents[num]["categoryName"] as! [String]
                                
                                for num in 0..<categoryIds.count {
                                    let categoryObject = Category(context: backgroundContext)
                                    categoryObject.categoryId = categoryIds[num]
                                    categoryObject.categoryName = categoryNames[num]
                                }
                            }
                        }
                        try backgroundContext.save()
                        
                        userDefaults.set(true, forKey: preloadedDataKey)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            LoginScreenView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}


