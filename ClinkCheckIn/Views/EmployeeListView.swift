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
                Text("總參加人數: \(records.count)")
                    .font(.system(size: 14))
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
            .frame(minWidth: 200)
        }
    }
}
