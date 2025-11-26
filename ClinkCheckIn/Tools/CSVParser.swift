//
//  CSVParser.swift
//  ClinkCheckIn
//
//  Created by Noah on 2025/11/25.
//

import Foundation
import SwiftData

class CSVParser {
    
    // MARK: - Functions
    
    /**
     Parses a CSV file and returns its content as an array of string arrays.

     - Parameter url: The URL of the CSV file to parse.
     - Throws: An error if the file cannot be read.
     - Returns: An array of arrays, where each inner array represents a row in the CSV file.
     */
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

    /**
     Imports data from a CSV file into the SwiftData database.

     This function parses a CSV file, then iterates over its rows to create or update `Employee` records.
     It handles duplicates by checking for existing employee IDs and merges relative information.

     - Parameters:
        - url: The URL of the CSV file to import.
        - database: The `ModelContext` for database operations.
     - Throws: An error if the file cannot be parsed or if there's an issue with database operations.
     */
    static func importToDatabase(url: URL, database: ModelContext) throws {
        let data = try parse(url: url)

        // Skip header row if present
        let dataRows = data.dropFirst()

        for row in dataRows {
            guard row.count >= 5 else { continue }

            let id = row[3].trimmingCharacters(in: .whitespaces)
            let name = row[4].trimmingCharacters(in: .whitespaces)
            let relative = row[2].trimmingCharacters(in: .whitespaces)
            let count = Int(row[0].trimmingCharacters(in: .whitespaces)) ?? 1

            // 1. Try to fetch an existing record
            let descriptor = FetchDescriptor<Employee>(
                predicate: #Predicate { $0.id == id }
            )

            let existing = try database.fetch(descriptor).first

            if let employee = existing {
                // Optional: merge relatives
                if !relative.isEmpty {
                    employee.relatives[relative, default: 0] += 1
                }
                employee.count = max(employee.count, count)
            } else {
                // 3. Insert new record
                let initialRelatives = !relative.isEmpty ? [relative: 1] : [:]
                let newRecord = Employee(
                    id: id,
                    name: name,
                    relatives: initialRelatives,
                    count: count
                )
                database.insert(newRecord)
            }
        }
        try database.save()
    }
}
