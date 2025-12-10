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
/// A view that displays the detailed information of a selected employee record.
struct RecordDetailView: View {

    // MARK: - Properties

    /// The employee record passed into the view.
    let record: Employee

    /// The view model that manages the logic for this view.
    @State private var viewModel: RecordDetailViewModel

    // MARK: - Initializer

    init(record: Employee) {
        self.record = record
        _viewModel = State(initialValue: RecordDetailViewModel(record: record))
    }

    // MARK: - View Body

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Divider()
            Text("參加人資訊")
                .font(.title)
                .fontWeight(.semibold)
            DetailRow(label: "員工編號", value: viewModel.record.id)
            DetailRow(label: "員工名稱", value: viewModel.record.name)
            DetailRow(label: "總參加人數", value: String(viewModel.record.count))

            // Section for displaying relatives and their check-in status.
            VStack(alignment: .leading, spacing: 4) {
                Text("攜帶親屬")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                if viewModel.record.relatives.isEmpty {
                    Text("無")
                        .font(.title2)
                } else {
                    // Display the "本人" toggle first if they exist in the relatives list.
                    ForEach(viewModel.selfRelative) { $selves in
                        Toggle(isOn: $selves.checkIn) {
                            Text($selves.name.wrappedValue)
                                .font(.title2)
                        }
                    }

                    // Display toggles for all other relatives.
                    ForEach(viewModel.otherRelatives) { $relative in
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
        // Ensure viewModel updates if the input record changes (e.g. selection changes)
        .onChange(of: record) { _, newRecord in
            viewModel.record = newRecord
        }
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
