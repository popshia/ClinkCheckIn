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
            Text(record.name)
                .foregroundStyle(
                    // The text color turns green if the "本人" (self) relative is checked in.
                    (record.relatives.first(where: { $0.name == "本人" })?.checkIn == true)
                        ? .green
                        : .primary
                )
                .font(.system(size: 20))
                .padding(4)
            Spacer()
        }
        .background(isSelected ? Color.gray.opacity(0.2) : Color.clear)
        .cornerRadius(5)
    }
}
