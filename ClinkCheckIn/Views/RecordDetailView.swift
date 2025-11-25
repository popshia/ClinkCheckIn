//
//  RecordDetailView.swift
//  ClinkCheckIn
//
//  Created by Noah on 2025/11/25.
//

import SwiftData
import SwiftUI

struct RecordDetailView: View {
    @Bindable var record: Employee

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Record Details")
                .font(.title2)
                .fontWeight(.semibold)

            Divider()

            DetailRow(label: "ID", value: record.id)
            DetailRow(label: "Name", value: record.name)
            DetailRow(label: "Count", value: String(record.count))
            DetailRow(
                label: "Relatives",
                value: record.relatives.filter { $0 != "本人" }.joined(
                    separator: ", "
                )
            )
            
            Toggle(isOn: $record.checkIn) {
                Text("Checked In")
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

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
                .textSelection(.enabled)
        }
    }
}
