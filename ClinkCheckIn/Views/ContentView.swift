//
//  ContentView.swift
//  ClinkCheckIn
//
//  Created by Noah on 2025/11/25.
//

import SwiftData
import SwiftUI
internal import UniformTypeIdentifiers

/// The main content view of the application, responsible for displaying employee records,
/// handling search functionality, and managing data import/export.
struct ContentView: View {
    
    // MARK: - Properties
    
    /// The model context for SwiftData operations, injected from the environment.
    @Environment(\.modelContext) private var modelContext
    /// A query to fetch all employee records from the database.
    @Query private var records: [Employee]

    /// The text entered by the user in the search bar.
    @State private var searchText = ""
    /// The results of the employee search.
    @State private var searchResults: [Employee] = []
    /// A boolean indicating whether the file importer is currently presented.
    @State private var isImporting = false
    /// A boolean indicating whether the confirmation alert for clearing data is presented.
    @State private var showingClearConfirmation = false
    /// The currently selected employee record in the sidebar.
    @State private var selectedRecord: Employee?

    /// A computed property that returns the employee records sorted by name.
    private var sortedRecords: [Employee] {
        records.sorted { $0.name < $1.name }
    }
    
    // MARK: - Main
    
    var body: some View {
        NavigationSplitView {
            // Sidebar - optional, can show statistics or controls
            VStack(alignment: .leading, spacing: 12) {
                Text("總參加人數: \(records.count)")
                    .font(.system(size: 14))
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(sortedRecords) { record in
                            Button {
                                selectedRecord = record
                            } label: {
                                RecordRowView(
                                    record: record,
                                    isSelected: selectedRecord == record
                                )
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(minWidth: 200)
        } content: {
            // Content - Search interface
            VStack(spacing: 20) {
                Spacer()
                Text("C-LINK 尾牙報到")
                    .font(.system(size: 40))
                    .fontWeight(.semibold)
                VStack {
                    TextField("輸入員工編號或員工姓名進行查詢", text: $searchText)
                        .font(.system(size: 24))
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 400)
                        .padding()

                    Button {
                        performSearch()
                    } label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20))
                            Text("搜尋")
                                .font(.system(size: 20))
                        }
                        .padding(8)
                    }
                    .buttonStyle(.plain) // Prevent default bordered style
                    .glassEffect(
                        .regular.tint(.blue).interactive(),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                    .disabled(searchText.isEmpty)
                }
                Spacer()
            }
            .padding()
            .frame(minWidth: 400)

        } detail: {
            // Detail - Search results
            if let record = selectedRecord {
                RecordDetailView(record: record)
            } else if !searchResults.isEmpty {
                RecordDetailView(record: searchResults[0])
            } else {
                VStack {
                    Text("請先於左方查詢出席資訊")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(role: .destructive) {
                    showingClearConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(records.isEmpty ? .gray : .red)
                }
                .disabled(records.isEmpty)
                .buttonStyle(.automatic)
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    isImporting = true
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                .buttonStyle(.automatic)
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result: result)
        }
        .alert("Clear All Data", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete All", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text(
                "Are you sure you want to delete all \(records.count) records? This action cannot be undone."
            )
        }
    }
    
    // MARK: - Functions

    /**
     Performs a search for employees based on the `searchText`.
     
     This function filters the `records` array to find employees whose ID or name contains the search text.
     The results are stored in the `searchResults` state variable.
     */
    private func performSearch() {
        selectedRecord = nil
        searchResults = records.filter { record in
            record.id.contains(searchText) || record.name.contains(searchText)
        }
    }

    /**
     Handles the result of a file import operation.
     
     This function is called when the user selects a file using the file importer. It attempts to parse the selected CSV file and import its data into the database.
     
     - Parameter result: A `Result` containing either an array of URLs to the selected files or an error.
     */
    private func handleFileImport(result: Result<[URL], Error>) {
        do {
            guard let url = try result.get().first else { return }

            // Security-scoped resource access
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

    /// Clears all employee data from the database.
    private func clearAllData() {
        // Delete all records from the database
        for record in records {
            modelContext.delete(record)
        }

        do {
            try modelContext.save()
            // Clear search results as well
            searchResults = []
            searchText = ""
            print("Successfully cleared all data")
        } catch {
            print("Error clearing data: \(error.localizedDescription)")
        }
    }
}

/// A view that displays a single row for an employee record in the list.
struct RecordRowView: View {
    
    // MARK: - Properties
    
    /// The employee record to display.
    let record: Employee
    /// A boolean indicating whether this record row is currently selected.
    let isSelected: Bool

    // MARK: - Main
    
    var body: some View {
        HStack {
            Text(record.name)
                .foregroundStyle(
                    record.checkIn
                        ? .green
                        : .primary
                )
                .font(.system(size: 20))
                .padding(4)
            Spacer()
        }
        .background(isSelected ? Color.gray.opacity(0.2) : Color.clear)
        .cornerRadius(5)
    }
}

#Preview {
    ContentView()
}
