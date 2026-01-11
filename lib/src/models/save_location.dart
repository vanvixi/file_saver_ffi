/// Base sealed class for all save locations.
///
/// This class provides a type-safe way to specify where files should be saved
/// on different platforms. Each platform has its own set of supported locations
/// through platform-specific enum implementations.
sealed class SaveLocation {
  const SaveLocation();
}

/// Android-specific save locations.
///
/// These locations map to Android's MediaStore collections and storage directories.
///
/// Platform mappings:
/// - [pictures]: MediaStore.Images.Media (Pictures/ directory)
/// - [movies]: MediaStore.Video.Media (Movies/ directory)
/// - [music]: MediaStore.Audio.Media (Music/ directory)
/// - [downloads]: MediaStore.Downloads (Downloads/ directory)
/// - [dcim]: MediaStore.Images.Media (DCIM/ directory - camera photos)
enum AndroidSaveLocation implements SaveLocation {
  /// Save to Pictures/ directory via MediaStore.Images
  pictures,

  /// Save to Movies/ directory via MediaStore.Video
  movies,

  /// Save to Music/ directory via MediaStore.Audio
  music,

  /// Save to Downloads/ directory via MediaStore.Downloads (default)
  downloads,

  /// Save to DCIM/ directory (camera photos) via MediaStore.Images
  dcim;

  const AndroidSaveLocation();
}

/// iOS-specific save locations.
///
/// These locations map to iOS's Photos Library and FileManager directories.
///
/// Platform mappings:
/// - [photos]: Photos Library (requires Photos permission)
/// - [documents]: Documents/ directory in app's container (default, no permission required)
enum IosSaveLocation implements SaveLocation {
  /// Save to Photos Library
  ///
  /// Requires Photos permission. Files are saved to the user's Photos app
  /// and can optionally be organized into albums using the subDir parameter.
  photos,

  /// Save to app's Documents/ directory (default)
  ///
  /// Files are saved to the app's Documents directory and are visible in
  /// the Files app under "On My iPhone/iPad" → [App Name].
  /// No special permissions required.
  documents;

  const IosSaveLocation();
}
