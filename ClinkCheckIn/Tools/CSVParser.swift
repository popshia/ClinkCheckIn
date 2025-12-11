//
//  CSVParser.swift
//  ClinkCheckIn
//
//  Created by Noah on 2025/11/25.
//
//  This file provides a utility for parsing CSV files and importing the data
//  into the SwiftData database for the ClinkCheckIn application.
//

import Foundation
import SwiftData

/// A utility class for handling CSV data parsing and importing.
class CSVParser {

    // MARK: - Static Functions

    /// Parses a CSV file from a given URL into a two-dimensional array of strings.
    /// - Parameter url: The URL of the CSV file to parse.
    /// - Throws: An error if the file content cannot be read.
    /// - Returns: An array of arrays, where each inner array represents a row in the CSV file.
    static func parse(url: URL) throws -> [[String]] {
        let content = try String(contentsOf: url, encoding: .utf8)
        let rows = content.components(separatedBy: .newlines)

        var result: [[String]] = []
        for row in rows where !row.isEmpty {
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }

        return result
    }

    /// Imports employee data from a CSV file into the SwiftData database.
    /// This function parses a CSV file and iterates over its rows to create new `Employee` records
    /// or update existing ones. It handles duplicates by checking for existing employee IDs and
    /// appends new relatives to existing records.
    /// - Parameters:
    ///    - url: The URL of the CSV file to import.
    ///    - database: The `ModelContext` used for database operations.
    /// - Throws: An error if the file cannot be parsed or if there's an issue with database operations.
    static func importToDatabase(url: URL, database: ModelContext) throws {
        let data = try parse(url: url)

        // Skip header row if present, as it contains titles not data.
        let dataRows = data.dropFirst()

        for row in dataRows {
            guard row.count >= 5 else { continue }

            let id = row[3].trimmingCharacters(in: .whitespaces)
            let name = row[4].trimmingCharacters(in: .whitespaces)
            let relative = row[2].trimmingCharacters(in: .whitespaces)
            let count = Int(row[0].trimmingCharacters(in: .whitespaces)) ?? 1

            // Create a fetch descriptor to find an existing employee with the same ID.
            let descriptor = FetchDescriptor<Employee>(
                predicate: #Predicate { $0.id == id }
            )

            let existing = try database.fetch(descriptor).first

            if let employee = existing {
                // If the employee already exists, merge new relative information.
                if !relative.isEmpty {
                    let newRelative = Relative(name: relative)
                    employee.relatives.append(newRelative)
                }
                // Ensure the count reflects the maximum specified value.
                employee.count = max(employee.count, count)
            } else {
                // If the employee does not exist, create a new record.
                var initialRelatives: [Relative] = []
                if !relative.isEmpty {
                    initialRelatives.append(Relative(name: relative))
                }
                let newRecord = Employee(
                    id: id,
                    name: name,
                    relatives: initialRelatives,
                    count: count
                )
                database.insert(newRecord)
            }
        }
        // Save all changes to the database context.
        try database.save()
    }
}
