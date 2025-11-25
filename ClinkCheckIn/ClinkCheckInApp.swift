//
//  ClinkCheckInApp.swift
//  ClinkCheckIn
//
//  Created by Noah on 2025/11/25.
//

import SwiftData
import SwiftUI

@main
struct ClinkCheckInApp: App {
    var body: some Scene {
        Window("C-LINK Check In", id: "mainWindow") {
            ContentView()
        }
        .modelContainer(for: Employee.self)
    }
}
