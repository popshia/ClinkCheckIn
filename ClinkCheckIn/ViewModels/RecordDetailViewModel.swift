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

    var selfRelative: Binding<[Relative]> {
        Binding(
            get: {
                self.record.relatives.filter { $0.name == Relative.selfName }
            },
            set: { _ in } // Changes are handled directly on the objects
        )
    }

    var otherRelatives: Binding<[Relative]> {
        Binding(
            get: {
                self.record.relatives
                    .filter { $0.name != Relative.selfName }
                    .sorted { $0.name < $1.name }
            },
            set: { _ in } // Changes are handled directly on the objects
        )
    }

    /// Returns a binding for a specific relative's check-in status.
    /// - Parameter relative: The relative to get the binding for.
    func binding(for relative: Relative) -> Binding<Bool> {
        Binding(
            get: { relative.checkIn },
            set: { relative.checkIn = $0 }
        )
    }
}
