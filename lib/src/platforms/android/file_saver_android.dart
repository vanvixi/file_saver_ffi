import 'dart:async';
import 'dart:typed_data';

import 'package:jni/jni.dart';

import '../../exceptions/file_saver_exceptions.dart';
import '../../models/conflict_resolution.dart';
import '../../models/file_type.dart';
import '../../models/save_result.dart';
import '../../platform_interface/file_saver_platform.dart';
import 'bindings.g.dart' as bindings;

class FileSaverAndroid extends FileSaverPlatform {
  FileSaverAndroid() {
    _fileSaver = bindings.FileSaver(Jni.androidApplicationContext);
  }

  /// Native FileSaver instance
  late final bindings.FileSaver _fileSaver;

  @override
  void dispose() {
    _fileSaver.release();
  }

  @override
  Future<SaveResult> saveBytes({
    required Uint8List fileBytes,
    required String fileName,
    required FileType fileType,
    String? subDir,
    ConflictResolution conflictResolution = ConflictResolution.autoRename,
  }) async {
    _validateInput(fileBytes, fileName);

    try {
      // Convert Dart types to JNI types
      final jByteArray = JByteArray.from(fileBytes);
      final jFileName = fileName.toJString();
      final jExtension = fileType.ext.toJString();
      final jMimeType = fileType.mimeType.toJString();
      final jSubDir = subDir?.toJString();
      final jConflictMode = conflictResolution.index;

      final kotlinResult = await _fileSaver.saveBytes(
        jByteArray,
        jFileName,
        jExtension,
        jMimeType,
        jSubDir,
        jConflictMode,
      );

      // Convert Kotlin SaveResult to Dart SaveResult
      return _convertSaveResult(kotlinResult);
    } catch (e) {
      throw FileSaverException.fromObj(e);
    }
  }

  // ===========================================
  // Helper Methods
  // ===========================================

  /// Converts Kotlin SaveResult to Dart SaveResult
  SaveResult _convertSaveResult(bindings.SaveResult kotlinResult) {
    if (kotlinResult.isSuccess()) {
      final filePathJStr = kotlinResult.getFilePath();
      final uriJStr = kotlinResult.getUri();

      final filePath = filePathJStr?.toDartString(releaseOriginal: true) ?? '';
      final uri = uriJStr?.toDartString(releaseOriginal: true) ?? '';

      // Release Kotlin object
      kotlinResult.release();

      return SaveSuccess(filePath: filePath, uri: uri);
    }

    // Failure case
    final errCodeJStr = kotlinResult.getErrorCode();
    final errMsgJStr = kotlinResult.getErrorMessage();

    final errorCode =
        errCodeJStr?.toDartString(releaseOriginal: true) ?? 'UNKNOWN';
    final errMsg =
        errMsgJStr?.toDartString(releaseOriginal: true) ?? 'Unknown error';

    // Release Kotlin object
    kotlinResult.release();

    return SaveFailure(error: errMsg, errorCode: errorCode);
  }

  // ===========================================
  // Validation Methods
  // ===========================================

  void _validateInput(Uint8List bytes, String fileName) {
    if (bytes.isEmpty) {
      throw const InvalidFileException('File bytes cannot be empty');
    }
    if (fileName.isEmpty) {
      throw const InvalidFileException('File name cannot be empty');
    }
  }
}
