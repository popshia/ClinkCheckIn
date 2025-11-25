//
//  ContentView.swift
//  ClinkCheckIn
//
//  Created by Noah on 2025/11/25.
//

import SwiftData
import SwiftUI
internal import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var records: [Employee]

    @State private var searchText = ""
    @State private var searchResults: [Employee] = []
    @State private var isImporting = false
    @State private var showingClearConfirmation = false

    var body: some View {
        NavigationSplitView {
            // Sidebar - optional, can show statistics or controls
            VStack(alignment: .leading, spacing: 20) {
                Text("Total Records: \(records.count)")
                    .font(.subheadline)
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(records.sorted { $0.name < $1.name }) {
                            record in
                            Text(record.name)
                                .foregroundStyle(
                                    record.checkIn
                                        ? .green
                                        : .primary
                                )
                                .font(.title3)
                                .padding(.vertical, 2)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)

                Divider()

                Button("Import CSV") {
                    isImporting = true
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(role: .destructive) {
                        showingClearConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    .disabled(records.isEmpty)
                }
            }
            .frame(minWidth: 200)
        } content: {
            // Content - Search interface
            VStack(spacing: 20) {
                Spacer()
                Text("Search Database")
                    .font(.title2)
                    .fontWeight(.semibold)

                HStack {
                    TextField("Enter search term...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 400)

                    Button("Search") {
                        performSearch()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(searchText.isEmpty)
                }

                Spacer()
            }
            .padding()
            .frame(minWidth: 400)

        } detail: {
            // Detail - Search results
            if !searchResults.isEmpty {
                RecordDetailView(record: searchResults[0])
            } else {
                VStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("Enter a search term to find records")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    private func performSearch() {
        searchResults = records.filter { record in
            record.id.contains(searchText)
        }
    }

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
#Preview {
    ContentView()
}
