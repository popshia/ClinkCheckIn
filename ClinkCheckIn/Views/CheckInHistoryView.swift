//
//  CheckInHistoryView.swift
//  ClinkCheckIn
//
//  Created by Google DeepMind on 2025/12/11.
//

import SwiftData
import SwiftUI

struct CheckInHistoryView: View {
    @Bindable var viewModel: ContentViewModel

    var body: some View {
        GlassEffectContainer {
            VStack(alignment: .leading) {
                if viewModel.searchHistory.isEmpty {
                    VStack {
                        Group {
                            Image(systemName: "clock.badge.questionmark.fill")
                                .padding(.bottom, 8)
                            Text("尚無報到紀錄")
                        }
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
                        .scrollContentBackground(.hidden)
                        .background(.clear)
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
    }
}
