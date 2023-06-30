//
//  DataBaseFiller.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/30/23.
//

import CoreData
import SwiftUI

struct DataBaseFiller: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [])  var categories: FetchedResults<Category>
    @FetchRequest(sortDescriptors: [])  var withPositions: FetchedResults<WithPosition>
    
    var body: some View {
        VStack {
            List {
                ForEach(categories, id: \.self) { category in
                    Section(category.wrappedCategoryName) {
                        ForEach(category.catDiveArray, id: \.self) { dive in
                            Text(dive.wrappedDiveName)
                        }
                    }
                }
                ForEach(withPositions, id: \.self) { withPosition in
                    Section(String(withPosition.degreeOfDifficulty)) {
                        ForEach(withPosition.positionArray, id: \.self) { pos in
                            Text(pos.wrappedpositionName)
                        }
                    }
                }
            }
            
            Button("Add Data") {
                let positionC = Position(context: moc)
                positionC.positionId = 0
                positionC.positionName = "Tuck"
                positionC.positionCode = "C"
                positionC.withPosition = WithPosition(context: moc)
                
                let dive101 = Dive(context: moc)
                dive101.diveNbr = 101
                dive101.diveCategoryId = 0
                
                dive101.category = Category(context: moc)
                dive101.category?.categoryId = dive101.diveCategoryId
                dive101.category?.categoryName = "Forward"
                
                dive101.subCategory = nil
                
                dive101.diveName = "Dive"
                
                positionC.withPosition = WithPosition(context: moc)
                positionC.withPosition?.diveNbr = dive101.diveNbr
                positionC.withPosition?.positionId = positionC.positionId
                positionC.withPosition?.degreeOfDifficulty = 1.2
                
                dive101.withPosition = WithPosition(context: moc)
                dive101.withPosition?.diveNbr = dive101.diveNbr
                dive101.withPosition?.positionId = positionC.positionId
                dive101.withPosition?.degreeOfDifficulty = 1.2
                
                //try? moc.save()
                
            }
        }
    }
}

struct DataBaseFiller_Previews: PreviewProvider {
    static var previews: some View {
        DataBaseFiller()
    }
}
