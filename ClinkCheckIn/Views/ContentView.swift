//
//  ContentView.swift
//  ClinkCheckIn
//
//  Created by Noah on 2025/11/25.
//
//  This file defines the main user interface for the ClinkCheckIn application.
//  It features a three-pane layout using NavigationSplitView to display a list
//  of all employees, a central search and detail area, and a check-in history.
//

import SwiftData
import SwiftUI
internal import UniformTypeIdentifiers

/// The main view of the application, responsible for displaying employee records,
/// handling search, and managing data import/export.
struct ContentView: View {

    // MARK: - Core Data Properties

    /// The model context for SwiftData operations, injected from the environment.
    @Environment(\.modelContext) private var modelContext
    /// A query to fetch all employee records from the database, kept up-to-date automatically.
    @Query private var records: [Employee]

    // MARK: - ViewModel

    @State private var viewModel = ContentViewModel()

    // MARK: - Computed Properties

    /// A computed property that returns the employee records sorted alphabetically by name.
    private var sortedRecords: [Employee] {
        records.sorted { $0.name < $1.name }
    }

    // MARK: - View Body

    var body: some View {
        NavigationSplitView {
            // MARK: Sidebar (List of all employees)
            EmployeeListView(records: sortedRecords, viewModel: viewModel)
        } content: {
            // MARK: Content (Search and Detail View)
            MainContentAreaView(viewModel: viewModel, records: records)
        } detail: {
            // MARK: Detail (Check-in History)
            CheckInHistoryView(viewModel: viewModel)
        }
        .toolbar {
            // Toolbar items for clearing data and importing a CSV file.
            ToolbarItem(placement: .automatic) {
                Button(role: .destructive) {
                    viewModel.showingClearConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(records.isEmpty ? .gray : .red)
                }
                .disabled(records.isEmpty)
                .buttonStyle(.automatic)
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    viewModel.isImporting = true
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                .buttonStyle(.automatic)
            }
        }
        .fileImporter(
            isPresented: $viewModel.isImporting,
            allowedContentTypes: [.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            viewModel.handleFileImport(result: result, modelContext: modelContext)
        }
        .alert("Clear All Data", isPresented: $viewModel.showingClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete All", role: .destructive) {
                viewModel.clearAllData(records: records, modelContext: modelContext)
            }
        } message: {
            Text(
                "Are you sure you want to delete all \(records.count) records? This action cannot be undone."
            )
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
