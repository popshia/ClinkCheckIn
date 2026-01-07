//
//  EmployeeListView.swift
//  ClinkCheckIn
//
//  Created by Google DeepMind on 2025/12/11.
//

import SwiftData
import SwiftUI

struct EmployeeListView: View {
    let records: [Employee]
    @Bindable var viewModel: ContentViewModel

    var body: some View {
        GlassEffectContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(
                        viewModel.filterStatus == .all
                            ? "已報到: \(records.filter { $0.checkInStatus == "已報到" || $0.checkInStatus == "部分報到" }.count) / \(records.count)"
                            : "\(viewModel.filterStatus.rawValue): \(records.count)"
                    )
                    .font(.system(size: 14))
                    Spacer()
                    Menu {
                        ForEach(ContentViewModel.CheckInFilter.allCases) { filter in
                            Button(filter.rawValue) {
                                viewModel.filterStatus = filter
                            }
                        }
                    } label: {
                        Image(
                            systemName: viewModel.filterStatus == .all
                                ? "line.3.horizontal.decrease.circle"
                                : "line.3.horizontal.decrease.circle.fill"
                        )
                        .foregroundStyle(
                            viewModel.filterStatus == .all ? Color.secondary : Color.blue)
                    }
                    .menuStyle(.button)
                    .buttonStyle(.plain)
                }
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(records) { record in
                            Button {
                                viewModel.selectedRecord = record
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
            .frame(minWidth: 100)
        }
    }
}
