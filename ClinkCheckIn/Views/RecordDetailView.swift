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

struct DetailRow: View {
    let label: String
    let value: String

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
