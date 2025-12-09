//
//  RecordDetailView.swift
//  ClinkCheckIn
//
//  Created by Noah on 2025/11/25.
//
//  This file defines the detail view for a single employee record, showing
//  all associated information and allowing for check-in status updates.
//

import SwiftData
import SwiftUI

/// A view that displays the detailed information of a selected employee record.
struct RecordDetailView: View {

    // MARK: - Properties

    /// The employee record being displayed and edited, bound to the view for live updates.
    @Bindable var record: Employee

    // MARK: - View Body

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Divider()
            Text("參加人資訊")
                .font(.title)
                .fontWeight(.semibold)
            DetailRow(label: "員工編號", value: record.id)
            DetailRow(label: "員工名稱", value: record.name)
            DetailRow(label: "總參加人數", value: String(record.count))
            
            // Section for displaying relatives and their check-in status.
            VStack(alignment: .leading, spacing: 4) {
                Text("攜帶親屬")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                if record.relatives.isEmpty {
                    Text("無")
                        .font(.title2)
                } else {
                    // Separate the "本人" (self) relative from others for special handling.
                    let selfRelativeBinding = $record.relatives.filter {
                        $0.name.wrappedValue == "本人"
                    }
                    // Filter and sort the remaining relatives alphabetically.
                    let otherRelativesBindings = $record.relatives.filter {
                        $0.name.wrappedValue != "本人"
                    }
                    .sorted { $0.name.wrappedValue < $1.name.wrappedValue }

                    // Display the "本人" toggle first if they exist in the relatives list.
                    ForEach(selfRelativeBinding) { $selves in
                        Toggle(isOn: $selves.checkIn) {
                            Text($selves.name.wrappedValue)
                                .font(.title2)
                        }
                    }

                    // Display toggles for all other relatives.
                    ForEach(otherRelativesBindings) { $relative in
                        Toggle(isOn: $relative.checkIn) {
                            Text($relative.name.wrappedValue)
                                .font(.title2)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

/// A helper view to display a label-value pair in a standardized format.
struct DetailRow: View {

    // MARK: - Properties

    /// The descriptive label for the data being displayed.
    let label: String
    /// The string value to be displayed.
    let value: String

    // MARK: - View Body

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
