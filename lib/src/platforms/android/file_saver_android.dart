import 'dart:async';
import 'dart:typed_data';

import 'package:jni/jni.dart';

import '../../exceptions/file_saver_exceptions.dart';
import '../../models/conflict_resolution.dart';
import '../../models/file_type.dart';
import '../../models/save_location.dart';
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
  Future<Uri> saveBytes({
    required Uint8List fileBytes,
    required String fileName,
    required FileType fileType,
    SaveLocation? saveLocation,
    String? subDir,
    ConflictResolution conflictResolution = ConflictResolution.autoRename,
  }) async {
    _validateInput(fileBytes, fileName);

    try {
      final jByteArray = JByteArray.from(fileBytes);
      final jFileName = fileName.toJString();
      final jExtension = fileType.ext.toJString();
      final jMimeType = fileType.mimeType.toJString();
      final jConflictMode = conflictResolution.index;
      final jSaveLocationIndex = switch (saveLocation) {
        AndroidSaveLocation location => location.index,
        _ => AndroidSaveLocation.downloads.index,
      };
      final jSubDir = subDir?.toJString();

      final kotlinResult = await _fileSaver.saveBytes(
        jByteArray,
        jFileName,
        jExtension,
        jMimeType,
        jSaveLocationIndex,
        jSubDir,
        jConflictMode,
      );

      return _convertToUriOrThrow(kotlinResult);
    } catch (e) {
      throw FileSaverException.fromObj(e);
    }
  }

  Uri _convertToUriOrThrow(bindings.SaveResult kotlinResult) {
    if (!kotlinResult.isSuccess()) {
      final errCodeJStr = kotlinResult.getErrorCode();
      final errMsgJStr = kotlinResult.getErrorMessage();
      final errorCode = errCodeJStr?.toDartString(releaseOriginal: true);
      final errMsg = errMsgJStr?.toDartString(releaseOriginal: true);
      kotlinResult.release();

      throw FileSaverException.fromErrorResult(
        errorCode ?? 'UNKNOWN',
        errMsg ?? 'Unknown error',
      );
    }

    final uriJStr = kotlinResult.getUri();
    final uriString = uriJStr?.toDartString(releaseOriginal: true) ?? '';
    kotlinResult.release();

    return Uri.parse(uriString);
  }

  void _validateInput(Uint8List bytes, String fileName) {
    if (bytes.isEmpty) {
      throw const InvalidFileException('File bytes cannot be empty');
    }
    if (fileName.isEmpty) {
      throw const InvalidFileException('File name cannot be empty');
    }
  }
}
