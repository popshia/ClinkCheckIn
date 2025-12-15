//
//  ContentViewModel.swift
//  ClinkCheckIn
//
//  Created by Noah on 2025/12/10.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class ContentViewModel {

    // MARK: - Properties

    var searchText = ""
    var showSuggestions = false
    var highlightedIndex: Int = 0
    var searchResults: [Employee] = []
    var isImporting = false
    var showingClearConfirmation = false
    var showingResetConfirmation = false
    var selectedRecord: Employee?
    var searchHistory: [Employee] = []
    var isSearchFieldFocused = false

    // MARK: - Actions

    /// Performs a search based on the current search text.
    /// - Parameter records: The array of employee records to search through.
    func performSearch(records: [Employee]) {
        let filteredRecords = records.filter { record in
            record.id.contains(searchText) || record.name.contains(searchText)
        }

        // Add unique found records to search history, putting the most recent at the top.
        for record in filteredRecords {
            if let index = searchHistory.firstIndex(where: { $0.id == record.id }) {
                searchHistory.remove(at: index) // Remove if already exists to re-add at top.
            }
            searchHistory.insert(record, at: 0)
        }

        selectedRecord = filteredRecords.first
    }

    /// Filters suggestions based on the current search text.
    /// - Parameter records: The array of employee records to filter through.
    func filteredSuggestions(from records: [Employee]) -> [Employee] {
        guard !searchText.isEmpty else { return [] }
        return records.filter {
            $0.id.localizedCaseInsensitiveContains(searchText)
                || $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    /// Selects a suggestion from the search results.
    /// - Parameters:
    ///   - record: The employee record to select.
    ///   - allRecords: All employee records in the database.
    func selectSuggestion(_ record: Employee, allRecords: [Employee]) {
        searchText = "\(record.id) \(record.name)"
        selectedRecord = record
        showSuggestions = false

        // Assign a sequential check-in ID if the employee doesn't have one yet.
        if record.checkInID == nil {
            let maxID = allRecords.compactMap { $0.checkInID }.max() ?? 0
            print(maxID)
            record.checkInID = maxID + 1
        }

        // Mark all relatives as checked in for the selected employee.
        for relative in record.relatives {
            relative.checkIn = true
        }

        // Ensure the selected record is at the top of the search history.
        if let index = searchHistory.firstIndex(where: { $0.id == record.id }) {
            searchHistory.remove(at: index)
        }
        searchHistory.insert(record, at: 0)
    }

    /// Handles file import from the user's file system.
    /// - Parameters:
    ///   - result: The result of the file import operation.
    ///   - modelContext: The model context for SwiftData operations.
    func handleFileImport(result: Result<[URL], Error>, modelContext: ModelContext) {
        do {
            guard let url = try result.get().first else { return }

            // Gain secure access to the file chosen by the user.
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to access file")
                return
            }

            defer { url.stopAccessingSecurityScopedResource() }

            try CSVParser.importToDatabase(url: url, database: modelContext)

            print("Successfully imported CSV data")

        } catch {
            print("Error importing CSV: \(error.localizedDescription)")
        }
    }

    /// Clears all data from the database.
    /// - Parameters:
    ///   - records: The array of employee records to clear.
    ///   - modelContext: The model context for SwiftData operations.
    func clearAllData(records: [Employee], modelContext: ModelContext) {
        // Delete all records from the database.
        for record in records {
            modelContext.delete(record)
        }

        do {
            try modelContext.save()
            // Clear local state variables as well.
            searchResults = []
            searchText = ""
            searchHistory = []
            print("Successfully cleared all data")
        } catch {
            print("Error clearing data: \(error.localizedDescription)")
        }
    }

    /// Resets all data from the database.
    /// - Parameters:
    ///   - records: The array of employee records to reset.
    ///   - modelContext: The model context for SwiftData operations.
    func resetAllData(records: [Employee], modelContext: ModelContext) {
        // Delete all records from the database.
        for record in records {
            record.checkInID = nil
            for relative in record.relatives {
                relative.checkIn = false
            }
        }

        do {
            try modelContext.save()
            // Clear local state variables as well.
            searchResults = []
            searchText = ""
            searchHistory = []
            print("Successfully reset all data")
        } catch {
            print("Error resetting data: \(error.localizedDescription)")
        }
    }
}
