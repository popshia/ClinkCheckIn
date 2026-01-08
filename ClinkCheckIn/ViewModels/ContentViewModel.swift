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

    // MARK: - Enums

    enum CheckInFilter: String, CaseIterable, Identifiable {
        case all = "所有"
        case notCheckedIn = "未報到" // Updated to match user preference
        case partiallyCheckedIn = "部分報到"
        case checkedIn = "已報到"

        var id: String { rawValue }
    }

    // MARK: - Properties

    var searchText = ""
    var showSuggestions = false
    var highlightedIndex: Int = 0
    var searchResults: [Employee] = []
    var isExporting = false // For CSV Export
    var showingClearConfirmation = false
    var showingResetConfirmation = false
    var selectedRecord: Employee?
    var searchHistory: [Employee] = []
    var isSearchFieldFocused = false
    var filterStatus: CheckInFilter = .all

    // MARK: - Actions

    /// Performs a search based on the current search text.
    /// - Parameter records: The array of employee records to search through.
    func performSearch(records: [Employee]) {
        let filteredRecords = records.filter { record in
            record.id.localizedCaseInsensitiveContains(searchText)
                || record.name.localizedCaseInsensitiveContains(searchText)
                || record.department.localizedCaseInsensitiveContains(searchText)
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
                || $0.department.localizedCaseInsensitiveContains(searchText)
        }
    }

    /// Filters and sorts employee records based on the current filter status.
    /// - Parameter records: The array of employee records to process.
    /// - Returns: An array of filtered and sorted employee records.
    func filteredAndSortedRecords(from records: [Employee]) -> [Employee] {
        let filteredRecords: [Employee]
        switch filterStatus {
        case .all:
            filteredRecords = records
        default:
            filteredRecords = records.filter {
                $0.checkInStatus == filterStatus.rawValue
            }
        }
        return filteredRecords.sorted { $0.name < $1.name }
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
            record.checkInID = maxID + 1
        }

        // Mark all relatives as checked in for the selected employee.
        for relative in record.relatives {
            relative.checkIn = true
        }
    }

    /// Imports the specific CSV file from the application bundle.
    /// - Parameter modelContext: The model context for SwiftData operations.
    func importFromBundleResource(modelContext: ModelContext) {
        guard let url = Bundle.main.url(forResource: "參與", withExtension: "csv") else {
            print("Failed to find '參與.csv' in bundle")
            return
        }

        do {
            try CSVParser.importToDatabase(url: url, database: modelContext)
            // Refresh logic if needed, though Query should handle it.
            print("Successfully imported bundle CSV data")
        } catch {
            print("Error importing bundle CSV: \(error.localizedDescription)")
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
            record.checkInStatus = "未報到"
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
