# GEMINI Project: ClinkCheckIn

## Project Overview

This is a macOS application named **ClinkCheckIn**, designed for managing event check-ins. The application allows users to import a list of employees from a CSV file, view the list of attendees, search for specific individuals, and mark them as checked in.

The project is built using modern Apple technologies:
- **UI Framework:** SwiftUI
- **Data Persistence:** SwiftData
- **Language:** Swift

The application features a three-pane interface using `NavigationSplitView` to provide a list of records, a search area, and a detailed view for each record.

## Building and Running

This is a standard Xcode project. To build and run the application:

1.  Open the `ClinkCheckIn.xcodeproj` file in Xcode.
2.  Select a macOS target (e.g., "My Mac").
3.  Click the "Run" button (or press `Cmd+R`).

There are no special command-line build steps required.

## Development Conventions

### Code Structure
The source code is organized into the following directories:
- `ClinkCheckIn/Models/`: Contains the SwiftData model classes (e.g., `Employee`).
- `ClinkCheckIn/Views/`: Contains the SwiftUI views (e.g., `ContentView`, `RecordDetailView`).
- `ClinkCheckIn/Tools/`: Contains utility classes, such as the `CSVParser`.
- `ClinkCheckIn/Assets.xcassets/`: Stores assets like app icons and colors.

### Data Model
The application uses a single SwiftData model class, `Employee`, which has the following properties:
- `id`: A unique identifier.
- `name`: The employee's name.
- `relatives`: A list of associated relatives.
- `count`: A count associated with the employee.
- `checkIn`: A boolean flag to indicate if the employee has checked in.

### Data Handling
- **Importing:** Data can be imported from a CSV file. The `CSVParser` handles reading the file and populating the SwiftData database. It correctly handles duplicates by updating existing records.
- **Searching:** The main content view provides a search bar to filter the list of employees by ID.
- **Check-In:** The `RecordDetailView` allows toggling the `checkIn` status of an employee, and this change is automatically persisted by SwiftData.
