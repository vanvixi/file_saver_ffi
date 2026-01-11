import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../../exceptions/file_saver_exceptions.dart';
import '../../models/conflict_resolution.dart';
import '../../models/file_type.dart';
import '../../models/save_location.dart';
import '../../platform_interface/file_saver_platform.dart';
import 'bindings.g.dart';

class FileSaverIos extends FileSaverPlatform implements Finalizable {
  FileSaverIos() {
    final dylib = DynamicLibrary.process();
    _bindings = FileSaverFfiBindings(dylib);
    _saverInstance = _bindings.file_saver_init();

    if (_saverInstance.address != 0) {
      _finalizer.attach(this, _saverInstance.cast());
    }
  }

  late final FileSaverFfiBindings _bindings;
  late final Pointer<Void> _saverInstance;

  static final int _disposeAddress =
      DynamicLibrary.process()
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>(
            'file_saver_dispose',
          )
          .address;

  static final Pointer<NativeFinalizerFunction> _nativeFinalizerPtr =
      Pointer.fromAddress(_disposeAddress);

  static final _finalizer = NativeFinalizer(_nativeFinalizerPtr);

  @override
  void dispose() {
    if (_saverInstance.address != 0) {
      _bindings.file_saver_dispose(_saverInstance);
      _finalizer.detach(this);
    }
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

    final completer = Completer<Uri>();

    return using((Arena arena) {
      void onResult(Pointer<FSaveResult> resultPtr) {
        try {
          final result = _convertToUriOrThrow(resultPtr.ref);
          _bindings.file_saver_free_result(resultPtr);
          completer.complete(result);
        } catch (e) {
          _bindings.file_saver_free_result(resultPtr);
          completer.completeError(e);
        }
      }

      final callback =
          NativeCallable<Void Function(Pointer<FSaveResult>)>.listener(
            onResult,
          );

      final dataPointer = arena<Uint8>(fileBytes.length);
      dataPointer.asTypedList(fileBytes.length).setAll(0, fileBytes);

      final fileNameCStr = fileName.toNativeUtf8(allocator: arena);
      final extCStr = fileType.ext.toNativeUtf8(allocator: arena);
      final mimeCStr = fileType.mimeType.toNativeUtf8(allocator: arena);
      final saveLocationIndex = switch (saveLocation) {
        IosSaveLocation location => location.index,
        _ => IosSaveLocation.documents.index,
      };
      final subDirCStr = subDir?.toNativeUtf8(allocator: arena);

      try {
        _bindings.file_saver_save_bytes_async(
          _saverInstance,
          dataPointer,
          fileBytes.length,
          fileNameCStr.cast(),
          extCStr.cast(),
          mimeCStr.cast(),
          saveLocationIndex,
          subDirCStr?.cast() ?? nullptr,
          conflictResolution.index,
          callback.nativeFunction,
        );

        completer.future.whenComplete(() {
          callback.close();
        });

        return completer.future;
      } catch (e) {
        callback.close();
        rethrow;
      }
    });
  }

  Uri _convertToUriOrThrow(FSaveResult cResult) {
    if (!cResult.success) {
      final errorCode = cResult.errorCode.cast<Utf8>().toDartString();
      final errorMsg = cResult.errorMessage.cast<Utf8>().toDartString();
      throw FileSaverException.fromErrorResult(errorCode, errorMsg);
    }

    return Uri.parse(cResult.fileUri.cast<Utf8>().toDartString());
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
