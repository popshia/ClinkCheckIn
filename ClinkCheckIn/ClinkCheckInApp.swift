//
//  ClinkCheckInApp.swift
//  ClinkCheckIn
//
//  Created by Noah on 2025/11/25.
//
//  This file serves as the main entry point for the ClinkCheckIn application.
//  It sets up the main app structure and scene configuration.
//

import SwiftData
import SwiftUI

/// The main structure that defines the application and its scenes.
@main
struct ClinkCheckInApp: App {
    
    // MARK: - Scene Definition
    
    var body: some Scene {
        // Defines the main window of the application.
        Window("C-LINK Check In", id: "mainWindow") {
            ContentView()
        }
        // Configures the SwiftData model container for the `Employee` entity,
        // making it available to all views within this scene.
        .modelContainer(for: Employee.self)
    }
}
