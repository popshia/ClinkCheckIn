//
//  CSVParserTests.swift
//  ClinkCheckIn
//
//  Created by Noah on 2025/12/11.
//

import Foundation
import SwiftData
import Testing

@testable import ClinkCheckIn

struct CSVParserTests {

    /// Test that the CSV parser correctly reads a file and splits it into rows and columns.
    @Test func testParseCSV() async throws {
        // 1. Create a dummy CSV string
        // Format: Count, Date, Relative, ID, Name
        let csvContent = """
            1,2023-11-25,Sister,1001,John Doe
            2,2023-11-26,Brother,1002,Jane Smith
            """

        // 2. Write it to a temporary file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(
            "test_parse.csv")
        try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)

        // Cleanup after test
        defer { try? FileManager.default.removeItem(at: tempURL) }

        // 3. Call the parser
        let result = try await CSVParser.parse(url: tempURL)

        // 4. Verify expectations
        #expect(result.count == 2)
        #expect(result[0][3] == "1001", "First ID should be 1001")
        #expect(result[1][4] == "Jane Smith", "Second name should be Jane Smith")
    }

    /// Test that data is correctly imported into the SwiftData database.
    @Test func testImportToDatabase() async throws {
        // 1. Setup an in-memory ModelContainer for testing (prevents writing to disk)
        let schema = Schema([Employee.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = await container.mainContext

        // 2. Create a dummy CSV file
        // Row format based on CSVParser: row[0]=Count, row[2]=Relative, row[3]=ID, row[4]=Name
        let csvContent = """
            Count,Date,Relative,ID,Name
            3,2023-11-25,Spouse,E999,Alice Wonderland
            """
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(
            "test_import.csv")
        try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        // 3. Perform the import
        try await CSVParser.importToDatabase(url: tempURL, database: context)

        // 4. Fetch and Verify
        let descriptor = FetchDescriptor<Employee>(predicate: #Predicate { $0.id == "E999" })
        let employees = try context.fetch(descriptor)

        #expect(employees.count == 1, "Should have created exactly one employee")

        if let employee = employees.first {
            #expect(employee.name == "Alice Wonderland")
            #expect(employee.count == 3)
            #expect(employee.relatives.count == 1)
            #expect(employee.relatives.first?.name == "Spouse")
        }
    }
}
