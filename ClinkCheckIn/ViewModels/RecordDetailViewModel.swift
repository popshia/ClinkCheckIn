//
//  RecordDetailViewModel.swift
//  ClinkCheckIn
//
//  Created by Noah on 2025/12/10.
//

import Foundation
import SwiftUI

@Observable
class RecordDetailViewModel {
    var record: Employee

    /// Initializes the view model with a specific employee record.
    /// - Parameter record: The employee record to display in the detail view.
    init(record: Employee) {
        self.record = record
    }

    /// Returns the relative representing the employee themselves.
    var selfRelative: [Relative] {
        self.record.relatives.filter { $0.name == Relative.selfName }
    }

    /// Returns the list of other relatives, sorted by name.
    var otherRelatives: [Relative] {
        self.record.relatives
            .filter { $0.name != Relative.selfName }
            .sorted { $0.name < $1.name }
    }

    /// Updates the check-in status of the employee and handles side effects.
    /// - Parameters:
    ///   - status: The new check-in status string ("未報到", "部分報到", "已報到").
    ///   - allRecords: All employee records, used to calculate sequential ID if needed.
    ///   - contentViewModel: The main view model, used to update search history.
    func updateCheckInStatus(
        _ status: String, allRecords: [Employee], contentViewModel: ContentViewModel
    ) {
        record.checkInStatus = status

        // Remove from history first to re-add at top if needed
        if let index = contentViewModel.searchHistory.firstIndex(where: { $0.id == record.id }) {
            contentViewModel.searchHistory.remove(at: index)
        }

        if status == "未報到" {
            for relative in record.relatives {
                relative.checkIn = false
            }
        } else {
            if status == "已報到" {
                for relative in record.relatives {
                    relative.checkIn = true
                }
            }
            // Assign a sequential check-in ID if the employee doesn't have one yet.
            if record.checkInID == nil {
                let maxID = allRecords.compactMap { $0.checkInID }.max() ?? 0
                record.checkInID = maxID + 1
            }
            // Add to history at top
            contentViewModel.searchHistory.insert(record, at: 0)
        }
    }
}
