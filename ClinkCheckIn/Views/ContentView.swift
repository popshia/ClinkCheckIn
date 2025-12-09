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

    // MARK: - State Properties

    /// The text entered by the user in the search bar.
    @State private var searchText = ""
    /// A boolean to control the visibility of the search suggestion dropdown.
    @State private var showSuggestions = false
    /// The index of the currently highlighted suggestion in the search results.
    @State private var highlightedIndex: Int = 0
    /// A focus state to manage whether the search text field is active.
    @FocusState private var isSearchFieldFocused: Bool
    /// The results of the most recent employee search.
    @State private var searchResults: [Employee] = []
    /// A boolean indicating whether the file importer sheet is currently presented.
    @State private var isImporting = false
    /// A boolean indicating whether the confirmation alert for clearing data is presented.
    @State private var showingClearConfirmation = false
    /// The currently selected employee record, which drives the detail view.
    @State private var selectedRecord: Employee?
    /// A history of employees who have been checked in.
    @State private var searchHistory: [Employee] = []

    // MARK: - Computed Properties

    /// A computed property that returns the employee records sorted alphabetically by name.
    private var sortedRecords: [Employee] {
        records.sorted { $0.name < $1.name }
    }

    // MARK: - View Body

    var body: some View {
        NavigationSplitView {
            // MARK: Sidebar (List of all employees)
            VStack(alignment: .leading, spacing: 12) {
                Text("總參加人數: \(records.count)")
                    .font(.system(size: 14))
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(sortedRecords) { record in
                            Button {
                                selectedRecord = record
                                // searchHistory.insert(record, at: 0)
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
            // MARK: Content (Search and Detail View)
            VStack(spacing: 20) {
                Spacer()
                VStack {
                    ZStack(alignment: .top) {
                        // Search text field
                        TextField("輸入員工編號或員工姓名進行查詢", text: $searchText)
                            .font(.system(size: 24))
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 400)
                            .focused($isSearchFieldFocused)
                            .onChange(of: searchText) { _, _ in
                                highlightedIndex = 0 // Reset highlight when text changes
                            }
                            .onSubmit {
                                let suggestions = filteredSuggestions()
                                guard !suggestions.isEmpty else { return }
                                let selected = suggestions[highlightedIndex]
                                selectSuggestion(selected)
                                isSearchFieldFocused = false
                            }
                            // Handle up/down arrow key presses to navigate suggestions
                            .onMoveCommand { direction in
                                let suggestions = filteredSuggestions()
                                guard !suggestions.isEmpty else { return }

                                switch direction {
                                case .down:
                                    highlightedIndex = min(
                                        highlightedIndex + 1, suggestions.count - 1)
                                case .up:
                                    highlightedIndex = max(highlightedIndex - 1, 0)
                                default:
                                    break
                                }
                            }

                        // Search suggestions dropdown
                        if isSearchFieldFocused && !filteredSuggestions().isEmpty {
                            ScrollViewReader { proxy in
                                ScrollView {
                                    VStack(spacing: 0) {
                                        ForEach(
                                            Array(filteredSuggestions().enumerated()),
                                            id: \.element.id
                                        ) { index, record in
                                            Button {
                                                selectSuggestion(record)
                                                isSearchFieldFocused = false
                                            } label: {
                                                suggestionRow(
                                                    record: record,
                                                    isHighlighted: index == highlightedIndex
                                                )
                                            }
                                            .id(index)
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                                // Auto-scroll to the highlighted suggestion
                                .onChange(of: highlightedIndex) { _, newValue in
                                    withAnimation(.easeOut(duration: 0.15)) {
                                        proxy.scrollTo(newValue, anchor: .center)
                                    }
                                }
                                .frame(maxHeight: 240)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(radius: 6)
                                .frame(maxWidth: 400)
                                .offset(y: 52)
                            }
                        }
                    }
                    .padding()
                }

                // Display the detail view for the selected record
                if let record = selectedRecord {
                    RecordDetailView(record: record)
                } else if !searchResults.isEmpty {
                    RecordDetailView(record: searchResults[0])
                }
                Spacer()
            }
            .onDisappear {
                showSuggestions = false
            }
            .padding()
            .frame(minWidth: 400)
        } detail: {
            // MARK: Detail (Check-in History)
            VStack(alignment: .leading) {
                if searchHistory.isEmpty {
                    VStack {
                        Text("無報到紀錄")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollViewReader { proxy in
                        List {
                            ForEach(Array(searchHistory.enumerated()), id: \.element.id) {
                                index, record in
                                Button {
                                    selectedRecord = record
                                } label: {
                                    CheckInListView(
                                        record: record,
                                        isSelected: selectedRecord == record
                                    )
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .id(index) // Assign unique ID for scrolling
                            }
                        }
                        // Scroll to the top when a new item is added to the history
                        .onChange(of: searchHistory.count) { _, _ in
                            if !searchHistory.isEmpty {
                                proxy.scrollTo(0, anchor: .top)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .toolbar {
            // Toolbar items for clearing data and importing a CSV file.
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

    // MARK: - Helper Functions

    /**
     Performs a search based on the `searchText` against employee names and IDs.
    
     This function filters the main `records` array and updates the `searchHistory`
     with the found records, placing the most recent at the top. The first result
     is automatically selected.
     */
    private func performSearch() {
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

    /**
     Filters the available records to generate a list of search suggestions.
     - Returns: An array of `Employee` records that match the current `searchText`.
     */
    private func filteredSuggestions() -> [Employee] {
        guard !searchText.isEmpty else { return [] }
        return records.filter {
            $0.id.localizedCaseInsensitiveContains(searchText)
                || $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    /**
     Handles the selection of an employee from the suggestion list.
    
     This function updates the UI, assigns a sequential `checkInID` if one doesn't exist,
     marks all relatives as checked in, and updates the search history.
     - Parameter record: The `Employee` record that was selected.
     */
    private func selectSuggestion(_ record: Employee) {
        searchText = record.name
        selectedRecord = record
        showSuggestions = false

        // Assign a sequential check-in ID if the employee doesn't have one yet.
        if record.checkInID == nil {
            let maxID = records.compactMap { $0.checkInID }.max() ?? 0
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

    /**
     Builds a single suggestion row view.
     - Parameters:
        - record: The `Employee` record to display in the row.
        - isHighlighted: A boolean indicating if the row is currently highlighted.
     - Returns: A view representing the suggestion row.
     */
    @ViewBuilder
    private func suggestionRow(record: Employee, isHighlighted: Bool) -> some View {
        HStack {
            highlightedText(text: "\(record.id) • \(record.name)")
                .font(.system(size: 18))
            Spacer()
        }
        .padding(8)
        .background(isHighlighted ? Color.accentColor.opacity(0.15) : Color.clear)
    }

    /**
     Generates a `Text` view with the search term highlighted in bold.
     - Parameter text: The string to be displayed.
     - Returns: A `Text` view with the `searchText` portion bolded.
     */
    private func highlightedText(text: String) -> Text {
        guard !searchText.isEmpty,
            let range = text.lowercased().range(of: searchText.lowercased())
        else {
            return Text(text)
        }

        let prefix = String(text[..<range.lowerBound])
        let match = String(text[range])
        let suffix = String(text[range.upperBound...])

        return Text(prefix) + Text(match).bold() + Text(suffix)
    }

    /**
     Handles the result of a file import operation from the `.fileImporter`.
    
     It retrieves the URL of the selected CSV file, ensures secure access to it,
     and triggers the `CSVParser` to import the data into the database.
     - Parameter result: A `Result` containing either an array of URLs or an error.
     */
    private func handleFileImport(result: Result<[URL], Error>) {
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

    /// Clears all employee and related data from the SwiftData database.
    private func clearAllData() {
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
}

// MARK: - Preview

#Preview {
    ContentView()
}
