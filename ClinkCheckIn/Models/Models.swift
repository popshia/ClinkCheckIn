//
//  Models.swift
//  ClinkCheckIn
//
//  Created by Noah on 2025/11/25.
//
//  This file defines the SwiftData models for the ClinkCheckIn application,
//  including the `Employee` and `Relative` entities.
//

import Foundation
import SwiftData

/// Represents a relative associated with an employee.
@Model
final class Relative {

    // MARK: - Properties

    /// The name of the relative.
    var name: String
    /// A boolean flag indicating whether the relative has checked in.
    var checkIn: Bool

    // MARK: - Initializer

    /**
     Initializes a new relative record.
     - Parameters:
        - name: The name of the relative.
        - checkIn: A boolean flag indicating whether the relative has checked in. Defaults to false.
     */
    init(name: String, checkIn: Bool = false) {
        self.name = name
        self.checkIn = checkIn
    }
}

extension Relative {
    static let selfName = "本人"
}

/// Represents an employee record in the check-in system.
@Model
final class Employee {

    // MARK: - Properties

    /// Unique identifier for the employee, typically an employee ID number.
    @Attribute(.unique)
    var id: String
    /// The name of the employee.
    var name: String
    /// A list of relatives associated with the employee.
    @Relationship(deleteRule: .cascade)
    var relatives: [Relative]
    /// A count associated with the employee, potentially representing the total number of people including the employee and their relatives.
    var count: Int
    /// A sequential ID assigned when the employee is checked in, starting from 1.
    var checkInID: Int?

    // MARK: - Initializer

    /**
     Initializes a new employee record.
     - Parameters:
        - id: The unique identifier for the employee.
        - name: The name of the employee.
        - relatives: A list of relatives associated with the employee. Defaults to an empty array.
        - count: A count associated with the employee.
     */
    init(
        id: String,
        name: String,
        relatives: [Relative] = [],
        count: Int
    ) {
        self.id = id
        self.name = name
        self.relatives = relatives
        self.count = count
    }

    /// Checks if the "本人" (self) relative is checked in.
    var isSelfCheckedIn: Bool {
        relatives.filter { $0.name == Relative.selfName }.allSatisfy { $0.checkIn == true }
    }
    
}
