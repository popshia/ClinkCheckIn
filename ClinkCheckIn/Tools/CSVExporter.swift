//
//  CSVExporter.swift
//  ClinkCheckIn
//
//  Created by Noah on 2026/01/08.
//

import Foundation
import SwiftUI
internal import UniformTypeIdentifiers

/// A utility class for generating CSV data from Employee records.
class CSVExporter {

    /// Generates a CSV string from an array of Employee records.
    /// - Parameter records: The array of records to export.
    /// - Returns: A CSV string with headers and data.
    static func generateCSV(from records: [Employee]) -> String {
        var csvString = "報到狀態,報到序號,員工編號,員工姓名,員工部門,已報到親屬,未報到親屬,備註\n"

        for record in records {
            let row = [
                escape(record.checkInStatus),
                record.checkInID.map { String($0) } ?? "",
                escape(record.id),
                escape(record.name),
                escape(record.department),
                escape(
                    "\(record.relatives.filter { $0.checkIn }.map { $0.name }.joined(separator: ", "))"
                ),
                escape(
                    "\(record.relatives.filter { !$0.checkIn }.map { $0.name }.joined(separator: ", "))"
                ),
                escape(record.note),
            ]
            csvString += row.joined(separator: ",") + "\n"
        }

        return csvString
    }

    /// Escapes a string for CSV format.
    /// - Parameter field: The string to escape.
    /// - Returns: The escaped string.
    private static func escape(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escapedField = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escapedField)\""
        }
        return field
    }
}

/// A FileDocument implementation for CSV files.
struct CSVDocument: FileDocument {
    static var readableContentTypes = [UTType.commaSeparatedText]

    var text: String = ""

    init(initialText: String = "") {
        text = initialText
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8) ?? Data()
        return FileWrapper(regularFileWithContents: data)
    }
}
