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

    /// The share content view model.
    var contentViewModel: ContentViewModel

    /// A query to fetch all employee records, used for calculating max ID.
    @Query private var allRecords: [Employee]

    // MARK: - Initializer

    init(record: Employee, contentViewModel: ContentViewModel) {
        self.record = record
        self.contentViewModel = contentViewModel
        _viewModel = State(initialValue: RecordDetailViewModel(record: record))
    }

    // MARK: - View Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("出席資訊")
                .font(.title)
                .fontWeight(.semibold)
            HStack(alignment: .top, spacing: 40) {
                VStack(alignment: .leading, spacing: 8) {
                    DetailRow(label: "員工編號", value: viewModel.record.id)
                    DetailRow(label: "部門", value: viewModel.record.department)
                    DetailRow(label: "名字", value: viewModel.record.name)
                    DetailRow(label: "出席人數", value: String(viewModel.record.count))
                }
                VStack(alignment: .leading, spacing: 8) {
                    let updateStatus = { (status: String) in
                        viewModel.record.checkInStatus = status
                        contentViewModel.searchHistory.removeAll { $0.id == record.id }
                        if status == "未報到" {
                            for relative in viewModel.record.relatives {
                                relative.checkIn = false
                            }
                        } else {
                            if status == "已報到" {
                                for relative in viewModel.record.relatives {
                                    relative.checkIn = true
                                }
                            }
                            // Assign a sequential check-in ID if the employee doesn't have one yet.
                            if record.checkInID == nil {
                                let maxID = allRecords.compactMap { $0.checkInID }.max() ?? 0
                                record.checkInID = maxID + 1
                            }
                            contentViewModel.searchHistory.insert(record, at: 0)
                        }
                    }

                    Text("簽到狀態")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Menu(viewModel.record.checkInStatus) {
                        Button("未報到") {
                            updateStatus("未報到")
                        }
                        Button("部分報到") {
                            updateStatus("部分報到")
                        }
                        Button("已報到") {
                            updateStatus("已報到")
                        }
                    }
                    if viewModel.record.hasPlayingCard == "Y" {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("總經理獎遊戲卡")
                                .font(.title)
                                .foregroundStyle(.green)
                        }
                    }
                }
            }

            Divider()

            // Section for displaying relatives and their check-in status.
            VStack(alignment: .leading, spacing: 4) {
                Text("攜帶親屬")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                let relatives = viewModel.record.relatives
                let selfRelatives = relatives.filter { $0.name == Relative.selfName }
                let otherRelatives = relatives.filter { $0.name != Relative.selfName }.sorted {
                    $0.name < $1.name
                }

                if relatives.isEmpty {
                    Text("無")
                        .font(.title2)
                } else {
                    // Display the "本人" toggle first if they exist in the relatives list.
                    ForEach(selfRelatives) { relative in
                        // Use a binding to the relative object directly
                        @Bindable var relative = relative
                        Toggle(isOn: $relative.checkIn) {
                            Text(relative.name)
                                .font(.title2)
                        }
                        .padding(.vertical, 2)
                    }

                    // Display toggles for all other relatives.
                    ForEach(otherRelatives) { relative in
                        @Bindable var relative = relative
                        Toggle(isOn: $relative.checkIn) {
                            Text(relative.name)
                                .font(.title2)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }

            Divider()

            Text("備註")
                .font(.title3)
                .foregroundStyle(.secondary)
            TextEditor(text: $viewModel.record.note)
                .font(.title2)
                .scrollContentBackground(.hidden) // Hides default TextEditor background
                .padding(8) // Internal padding for text
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.4), lineWidth: 1) // Proper rounded border
                )
                .frame(maxHeight: 40)
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
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
