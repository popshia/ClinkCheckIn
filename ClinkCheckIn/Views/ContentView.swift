//
//  ContentView.swift
//  ClinkCheckIn
//
//  Created by Noah on 2025/11/25.
//

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
    @State private var selectedRecord: Employee?

    private var sortedRecords: [Employee] {
        records.sorted { $0.name < $1.name }
    }

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
                    .buttonStyle(.plain)  // Prevent default bordered style
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

    private func performSearch() {
        selectedRecord = nil
        searchResults = records.filter { record in
            record.id.contains(searchText) || record.name.contains(searchText)
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

struct RecordRowView: View {
    let record: Employee
    let isSelected: Bool

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
