//
//  CheckInListView.swift
//  ClinkCheckIn
//
//  Created by Noah on 2025/12/8.
//
//  This file defines the view for a single row in the check-in history list,
//  displaying the employee's check-in ID, name, and their relatives.
//

import SwiftUI

/// A view that displays a single row for an employee in the check-in history list.
struct CheckInListView: View {

    // MARK: - Properties

    /// The employee record to display in this row.
    let record: Employee
    /// A boolean indicating whether this record row is currently selected, to adjust its background.
    let isSelected: Bool

    // MARK: - View Body

    var body: some View {
        VStack(alignment: .leading) {
            // Display the check-in ID and the employee's name prominently.
            Text("\(record.checkInID ?? 0) \(record.name)")
                .font(.system(size: 72).bold())
                .padding()
            HStack {
                // Display the names of all relatives, excluding "本人" (self).
                ForEach(
                    record.relatives.filter { $0.name != Relative.selfName }.sorted {
                        $0.name < $1.name
                    }
                ) { relative in
                    Text(relative.name)
                        .font(.system(size: 48))
                        .padding(4)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Ensure the view takes full available width
        .padding(.vertical, 6)
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
