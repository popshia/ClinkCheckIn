//
//  MainContentAreaView.swift
//  ClinkCheckIn
//
//  Created by Google DeepMind on 2025/12/11.
//

import SwiftData
import SwiftUI

struct MainContentAreaView: View {
    @Bindable var viewModel: ContentViewModel
    let records: [Employee]

    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        GlassEffectContainer {
            VStack(spacing: 40) {
                Spacer()
                VStack {
                    ZStack(alignment: .top) {
                        // Search text field
                        TextField("輸入員工編號或員工姓名進行查詢", text: $viewModel.searchText)
                            .font(.system(size: 24))
                            .textFieldStyle(.plain)
                            .padding(12)
                            .glassEffect(.regular)
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
                                .glassEffect(.regular, in: .rect(cornerRadius: 16))
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
        }
    }

    // MARK: - Helper Functions

    /// Builds a single suggestion row view.
    @ViewBuilder
    private func suggestionRow(record: Employee, isHighlighted: Bool) -> some View {
        HStack {
            highlightedText(text: "\(record.id) • \(record.name)")
                .font(.system(size: 18))
            Spacer()
        }
        .padding(8)
        .background(isHighlighted ? Color.accentColor.opacity(0.15) : Color.clear)
        .clipShape(.rect(cornerRadius: 16))
    }

    /// Generates a `Text` view with the search term highlighted in bold.
    private func highlightedText(text: String) -> Text {
        guard !viewModel.searchText.isEmpty,
            let range = text.lowercased().range(of: viewModel.searchText.lowercased())
        else {
            return Text(text)
        }

        let prefix = String(text[..<range.lowerBound])
        let match = String(text[range])
        let suffix = String(text[range.upperBound...])

        return Text("\(prefix)\(Text(match).bold())\(suffix)")
    }
}
