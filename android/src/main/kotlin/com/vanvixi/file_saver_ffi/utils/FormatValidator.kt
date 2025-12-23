package com.vanvixi.file_saver_ffi.utils

import android.media.MediaCodecList
import android.os.Build
import com.vanvixi.file_saver_ffi.exception.UnsupportedFormatException
import com.vanvixi.file_saver_ffi.models.FileType

object FormatValidator {
    /**
     * Validates image format support
     *
     * Always supported formats: PNG, JPEG, GIF, BMP
     * Conditional formats:
     * - HEIC/HEIF: Android 10+ (API 29+) with codec check
     * - WebP: Codec availability check
     *
     * @param extension File extension (with or without dot, case-insensitive)
     * @throws com.vanvixi.file_saver_ffi.exception.UnsupportedFormatException if format is not supported on this device
     *
     */
    fun validateImageFormat(imageType: FileType) {
        val ext = imageType.ext.lowercase()
        // Always supported formats (no codec check needed)
        val alwaysSupported = setOf("png", "jpeg", "gif", "bmp")
        if (ext in alwaysSupported) return

        // HEIC/HEIF - Android 10+ required + codec check
        if (ext == "heic" || ext == "heif") {
            // Check Android version first
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                throw UnsupportedFormatException(
                    format = imageType.ext.uppercase(),
                    message = "HEIC/HEIF format requires Android 10+ (API 29+), " +
                            "current: Android ${Build.VERSION.SDK_INT} (${Build.VERSION.RELEASE})"
                )
            }

            // Check codec availability
            if (!isCodecAvailable("image/heic") && !isCodecAvailable("image/heif")) {
                throw UnsupportedFormatException(
                    format = imageType.ext.uppercase(),
                    message = "HEIC/HEIF codec not available on this device"
                )
            }
            return
        }

        // WebP - Codec check
        if (ext == "webp" && !isCodecAvailable("image/webp")) {
            throw UnsupportedFormatException(
                format = imageType.ext.uppercase(),
                message = "WebP codec not available on this device"
            )
        }

        // Unsupported format
        throw UnsupportedFormatException(
            format = imageType.ext.uppercase(),
            message = "Unsupported image format. Supported: PNG, JPEG, GIF, BMP, WebP, HEIC/HEIF (Android 10+)"
        )
    }


    /**
     * Validates video format support
     *
     * Common formats that are usually supported: MP4, MOV, M4V, 3GP
     * Less common formats may require codec checks: AVI, MKV, WebM, FLV, WMV
     *
     * @param extension File extension (with or without dot, case-insensitive)
     * @throws UnsupportedFormatException if format is not supported on this device
     */
    fun validateVideoFormat(videoType: FileType) {
        val ext = videoType.ext.lowercase()
        // Common formats (usually supported on all Android devices)
        val commonFormats = setOf("mp4", "3gp", "webm")
        if (ext in commonFormats) return

        if (!isCodecAvailable(videoType.mimeType)) {
            throw UnsupportedFormatException(
                format = videoType.ext.uppercase(),
                message = "${videoType.ext} codec not available on this device"
            )
        }

        // Unsupported format
        throw UnsupportedFormatException(
            format = videoType.ext.uppercase(),
            message = "Unsupported video format. Common formats: MP4, WEBM, 3GP"
        )
    }

    /**
     * Validates audio format support
     *
     * Common formats that are usually supported: MP3, AAC, WAV, M4A, OGG, AMR
     * Less common formats may require codec checks: FLAC, OPUS, WMA, AC3, DTS
     *
     * @param extension File extension (with or without dot, case-insensitive)
     * @throws UnsupportedFormatException if format is not supported on this device
     */
    fun validateAudioFormat(audioType: FileType) {
        val ext = audioType.ext.lowercase()
        // Common formats (usually supported on all Android devices)
        val commonFormats = setOf("mp3", "aac", "wav", "amr")
        if (ext in commonFormats) return

        if (!isCodecAvailable(audioType.mimeType)) {
            throw UnsupportedFormatException(
                format = audioType.ext.uppercase(),
                message = "$audioType.ext codec not available on this device"
            )
        }

        // Unsupported format
        throw UnsupportedFormatException(
            format = audioType.ext.uppercase(),
            message = "Unsupported audio format. Common formats: MP3, AAC, WAV, AMR"
        )
    }


    // ===========================================
    // Helper Methods
    // ===========================================

    /**
     * Checks if a codec is available for the given MIME type
     *
     * Uses MediaCodecList.ALL_CODECS to query all available codecs on the device
     *
     * @param mimeType MIME type to check (e.g., "image/heic", "video/mp4")
     * @return true if codec is available, false otherwise
     */
    private fun isCodecAvailable(mimeType: String): Boolean {
        return try {
            val codecList = MediaCodecList(MediaCodecList.ALL_CODECS)
            codecList.codecInfos.any { codecInfo ->
                codecInfo.supportedTypes.any { supportedType ->
                    supportedType.equals(mimeType, ignoreCase = true)
                }
            }
        } catch (_: Exception) {
            // If MediaCodecList fails, assume codec is not available
            false
        }
    }
}


