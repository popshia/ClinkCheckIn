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
        HStack {
            let listText =
                record.isSelfCheckedIn ? "✔︎ \(record.name)" : "\(record.name)"
            Text(listText)
                .font(.system(size: 20))
                .padding(4)
            Spacer()
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
        .background(
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        )
        // Ensure text color is readable on the material background
        .foregroundStyle(isSelected ? .primary : .secondary)
    }
}
