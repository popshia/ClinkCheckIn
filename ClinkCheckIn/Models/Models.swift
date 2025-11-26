//
//  Participent.swift
//  ClinkCheckIn
//
//  Created by Noah on 2025/11/25.
//

import Foundation
import SwiftData

@Model
final class Employee {
    
    // MARK: - Properties
    
    /// Unique identifier for the employee.
    @Attribute(.unique)
    var id: String

    /// The name of the employee.
    var name: String
    /// A dictionary storing relatives associated with the employee, where the key is the relative's name and the value is their count.
    var relatives: [String: Int]
    /// A count associated with the employee, potentially representing the total number of people including the employee and their relatives.
    var count: Int
    /// A boolean flag indicating whether the employee has checked in.
    var checkIn: Bool

    // MARK: - Initializer
    
    init(
        id: String,
        name: String,
        relatives: [String: Int],
        count: Int
    ) {
        self.id = id
        self.name = name
        self.relatives = relatives
        self.count = count
        self.checkIn = false
    }
}
