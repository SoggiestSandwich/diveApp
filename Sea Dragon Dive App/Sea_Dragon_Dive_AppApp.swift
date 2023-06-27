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

    var body: some Scene {
        WindowGroup {
            LoginScreenView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
