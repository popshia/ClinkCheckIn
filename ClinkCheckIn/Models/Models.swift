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
    @Attribute(.unique)
    var id: String

    var name: String
    var relatives: [String]
    var count: Int
    var checkIn: Bool

    init(
        id: String,
        name: String,
        attendAlone: String,
        relatives: [String],
        count: Int
    ) {
        self.id = id
        self.name = name
        self.relatives = relatives
        self.count = 0
        self.checkIn = false
    }
}
