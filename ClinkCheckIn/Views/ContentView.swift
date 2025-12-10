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

    // MARK: - State Properties

    /// A focus state to manage whether the search text field is active.
    @FocusState private var isSearchFieldFocused: Bool

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
                                viewModel.selectedRecord = record
                                // searchHistory.insert(record, at: 0)
                            } label: {
                                RecordRowView(
                                    record: record,
                                    isSelected: viewModel.selectedRecord == record
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
                        TextField("輸入員工編號或員工姓名進行查詢", text: $viewModel.searchText)
                            .font(.system(size: 24))
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 400)
                            .focused($isSearchFieldFocused)
                            .onChange(of: viewModel.searchText) { _, _ in
                                viewModel.highlightedIndex = 0 // Reset highlight when text changes
                            }
                            .onSubmit {
                                let suggestions = viewModel.filteredSuggestions(from: records)
                                guard !suggestions.isEmpty else { return }
                                let selected = suggestions[viewModel.highlightedIndex]
                                viewModel.selectSuggestion(selected, allRecords: records)
                                isSearchFieldFocused = false
                            }
                            // Handle up/down arrow key presses to navigate suggestions
                            .onMoveCommand { direction in
                                let suggestions = viewModel.filteredSuggestions(from: records)
                                guard !suggestions.isEmpty else { return }

                                switch direction {
                                case .down:
                                    viewModel.highlightedIndex = min(
                                        viewModel.highlightedIndex + 1, suggestions.count - 1)
                                case .up:
                                    viewModel.highlightedIndex = max(
                                        viewModel.highlightedIndex - 1, 0)
                                default:
                                    break
                                }
                            }

                        // Search suggestions dropdown
                        if isSearchFieldFocused
                            && !viewModel.filteredSuggestions(from: records).isEmpty
                        {
                            ScrollViewReader { proxy in
                                ScrollView {
                                    VStack(spacing: 0) {
                                        ForEach(
                                            Array(
                                                viewModel.filteredSuggestions(from: records)
                                                    .enumerated()),
                                            id: \.element.id
                                        ) { index, record in
                                            Button {
                                                viewModel.selectSuggestion(
                                                    record, allRecords: records)
                                                isSearchFieldFocused = false
                                            } label: {
                                                suggestionRow(
                                                    record: record,
                                                    isHighlighted: index
                                                        == viewModel.highlightedIndex
                                                )
                                            }
                                            .id(index)
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                                // Auto-scroll to the highlighted suggestion
                                .onChange(of: viewModel.highlightedIndex) { _, newValue in
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
                if let record = viewModel.selectedRecord {
                    RecordDetailView(record: record)
                } else if !viewModel.searchResults.isEmpty {
                    RecordDetailView(record: viewModel.searchResults[0])
                }
                Spacer()
            }
            .onDisappear {
                viewModel.showSuggestions = false
            }
            .padding()
            .frame(minWidth: 400)
        } detail: {
            // MARK: Detail (Check-in History)
            VStack(alignment: .leading) {
                if viewModel.searchHistory.isEmpty {
                    VStack {
                        Text("無報到紀錄")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollViewReader { proxy in
                        List {
                            ForEach(Array(viewModel.searchHistory.enumerated()), id: \.element.id) {
                                index, record in
                                Button {
                                    viewModel.selectedRecord = record
                                } label: {
                                    CheckInListView(
                                        record: record,
                                        isSelected: viewModel.selectedRecord == record
                                    )
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .id(index) // Assign unique ID for scrolling
                            }
                        }
                        // Scroll to the top when a new item is added to the history
                        .onChange(of: viewModel.searchHistory.count) { _, _ in
                            if !viewModel.searchHistory.isEmpty {
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

    // MARK: - Helper Functions

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
        guard !viewModel.searchText.isEmpty,
            let range = text.lowercased().range(of: viewModel.searchText.lowercased())
        else {
            return Text(text)
        }

        let prefix = String(text[..<range.lowerBound])
        let match = String(text[range])
        let suffix = String(text[range.upperBound...])

        return Text(prefix) + Text(match).bold() + Text(suffix)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
