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
// TODO: add export csv file.

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

    // MARK: - View Body

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationSplitView {
            // MARK: Sidebar (List of all employees)
            EmployeeListView(
                records: viewModel.filteredAndSortedRecords(from: records),
                viewModel: viewModel
            )
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
                    viewModel.showingResetConfirmation = true
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(records.isEmpty)
                .buttonStyle(.automatic)
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    viewModel.importFromBundleResource(modelContext: modelContext)
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                .buttonStyle(.automatic)
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    viewModel.isExporting = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .buttonStyle(.automatic)
            }
        }
        .fileExporter(
            isPresented: $viewModel.isExporting,
            document: CSVDocument(initialText: CSVExporter.generateCSV(from: records)),
            contentType: .commaSeparatedText,
            defaultFilename: "尾牙報到紀錄.csv"
        ) { result in
            if case .failure(let error) = result {
                print("Export failed: \(error.localizedDescription)")
            } else {
                print("Export successful")
            }
        }
        .alert("Reset Check In Status", isPresented: $viewModel.showingResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                viewModel.resetAllData(records: records, modelContext: modelContext)
            }
        } message: {
            Text(
                "Are you sure you want to reset all check-in statuses? This action cannot be undone."
            )
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
