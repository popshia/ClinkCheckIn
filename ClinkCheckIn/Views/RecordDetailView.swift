//
//  RecordDetailView.swift
//  ClinkCheckIn
//
//  Created by Noah on 2025/11/25.
//

import SwiftData
import SwiftUI

/// A view that displays the detailed information of a selected employee record.
struct RecordDetailView: View {
    
    // MARK: - Properties
    
    /// The employee record being displayed and edited.
    @Bindable var record: Employee

    // MARK: - Main
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            Text("參加人資訊")
                .font(.title)
                .fontWeight(.semibold)

            Divider()

            DetailRow(label: "員工編號", value: record.id)
            DetailRow(label: "員工名稱", value: record.name)
            DetailRow(label: "總參加人數", value: String(record.count))
            DetailRow(
                label: "攜帶親屬",
                value: record.relatives
                    .filter { $0.key != "本人" }
                    .map { "\($0.key) * \($0.value)" }
                    .joined(separator: ", ")
            )

            Toggle(isOn: $record.checkIn) {
                Text("已報到").font(.title2)
            }

            Spacer()
        }
        .padding()
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

/// A helper view to display a label-value pair in the detail view.
struct DetailRow: View {
    
    // MARK: - Properties
    
    /// The descriptive label for the row.
    let label: String
    /// The value to be displayed in the row.
    let value: String

    // MARK: - Main
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .textSelection(.enabled)
        }
    }
}
