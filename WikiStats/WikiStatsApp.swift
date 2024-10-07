//
//  WikiStatsApp.swift
//  WikiStats
//
//  Created by Aaron Van Doren on 10/6/24.
//

import SwiftUI

@main
struct WikiStatsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
