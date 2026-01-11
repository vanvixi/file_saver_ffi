library;

import 'dart:typed_data';

// Public API - FileSaver class
import 'src/models/conflict_resolution.dart';
import 'src/models/file_type.dart';
import 'src/models/save_location.dart';
import 'src/platform_interface/file_saver_platform.dart';

// Exceptions
export 'src/exceptions/file_saver_exceptions.dart';
// Models
export 'src/models/conflict_resolution.dart';
export 'src/models/file_type.dart';
export 'src/models/save_location.dart';

class FileSaver {
  FileSaver._();

  static final FileSaver instance = FileSaver._();

  FileSaverPlatform get _platform => FileSaverPlatform.instance;

  /// Resources are automatically released on app termination,
  /// but call dispose() for timely cleanup.
  void dispose() {
    _platform.dispose();
  }

  /// Saves file bytes to device storage.
  ///
  /// Parameters:
  /// - [bytes]: The file content to save
  /// - [fileName]: The name of the file without extension
  /// - [fileType]: The file type (determines extension and MIME type)
  /// - [saveLocation]: Where to save the file (platform-specific, optional)
  ///   - If not specified, defaults to:
  ///     - Android: [AndroidSaveLocation.downloads]
  ///     - iOS: [IosSaveLocation.documents] (app's Documents directory)
  /// - [subDir]: Optional subdirectory within the save location
  /// - [conflictResolution]: How to handle filename conflicts
  ///
  /// Returns the [Uri] where the file was saved.
  ///
  /// Throws [FileSaverException] or one of its subtypes on failure:
  /// - [PermissionDeniedException] - Storage permission denied
  /// - [FileExistsException] - File exists with [ConflictResolution.fail] strategy
  /// - [StorageFullException] - Insufficient device storage
  /// - [InvalidFileException] - Invalid file data or filename
  /// - [FileIOException] - File I/O operation failed
  /// - [UnsupportedFormatException] - Format not supported on platform
  /// - [PlatformException] - Generic platform-specific error
  ///
  /// Example:
  /// ```dart
  /// // Default location (downloads on Android, documents on iOS)
  /// final uri = await FileSaver.instance.saveBytes(
  ///   bytes: imageBytes,
  ///   fileName: 'photo',
  ///   fileType: ImageType.jpg,
  /// );
  ///
  /// // Specify location explicitly
  /// final uri = await FileSaver.instance.saveBytes(
  ///   bytes: photoBytes,
  ///   fileName: 'camera_photo',
  ///   fileType: ImageType.jpg,
  ///   saveLocation: Platform.isAndroid
  ///     ? AndroidSaveLocation.dcim
  ///     : IosSaveLocation.photos,
  /// );
  /// ```
  Future<Uri> saveBytes({
    required Uint8List bytes,
    required FileType fileType,
    required String fileName,
    SaveLocation? saveLocation,
    String? subDir,
    ConflictResolution conflictResolution = ConflictResolution.autoRename,
  }) async {
    return _platform.saveBytes(
      fileBytes: bytes,
      fileType: fileType,
      fileName: fileName,
      saveLocation: saveLocation,
      subDir: subDir,
      conflictResolution: conflictResolution,
    );
  }
}
