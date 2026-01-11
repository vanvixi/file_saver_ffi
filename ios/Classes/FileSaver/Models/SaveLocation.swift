import Foundation

/// Represents save locations for files on iOS.
///
/// Maps to Photos Library and FileManager directories.
enum SaveLocation: Int {
    /// Photos Library (requires Photos permission)
    case photos = 0

    /// Documents/ directory in app container (default, no permission required)
    case documents = 1

    /// Converts an integer index to SaveLocation enum.
    ///
    /// - Parameter value: The index from Dart enum (0-1)
    /// - Returns: Corresponding SaveLocation, defaults to .documents if invalid
    static func fromInt(_ value: Int) -> SaveLocation {
        return SaveLocation(rawValue: value) ?? .documents
    }
}
