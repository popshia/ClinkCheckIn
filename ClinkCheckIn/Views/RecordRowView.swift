//
//  RecordRowView.swift
//  ClinkCheckIn
//
//  Created by Noah on 2025/12/8.
//
//  This file defines the view for a single row in the main employee list.
//  It displays the employee's name and changes color based on check-in status.
//

import SwiftUI

/// A view that displays a single row for an employee record in the list.
struct RecordRowView: View {

    // MARK: - Properties

    /// The employee record to display in this row.
    let record: Employee
    /// A boolean indicating whether this record row is currently selected, to adjust its background.
    let isSelected: Bool

    // MARK: - View Body

    var body: some View {
        let content = HStack {
            let listText =
                switch record.checkInStatus {
                case "已報到": "✅ \(record.name)"
                case "部分報到": "⚠️ \(record.name)"
                default: "\(record.name)"
                }
            Text(listText)
                .font(.system(size: 20))
                .padding(4)
            Spacer()
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 8)

        if isSelected {
            content
                .glassEffect(.regular)
                .foregroundStyle(.primary)
        } else {
            content
                .foregroundStyle(.secondary)
        }
    }
}
