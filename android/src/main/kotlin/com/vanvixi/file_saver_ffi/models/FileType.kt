package com.vanvixi.file_saver_ffi.models


data class FileType(
    val ext: String,
    val mimeType: String
) {
    enum class Category {
        IMAGE,
        VIDEO,
        AUDIO,
        CUSTOM
    }

    val category: Category
        get() = when {
            mimeType.startsWith("image/") -> Category.IMAGE
            mimeType.startsWith("video/") -> Category.VIDEO
            mimeType.startsWith("audio/") -> Category.AUDIO
            else -> Category.CUSTOM
        }

    val isImage: Boolean
        get() = category == Category.IMAGE


    val isVideo: Boolean
        get() = category == Category.VIDEO


    val isAudio: Boolean
        get() = category == Category.AUDIO
}


//val FileType.isImage: Boolean
//    get() = this is ImageType || mimeType.startsWith("image/")
//
//val FileType.isVideo: Boolean
//    get() = this is VideoType || mimeType.startsWith("video/")
//
//val FileType.isAudio: Boolean
//    get() = this is AudioType || mimeType.startsWith("audio/")

//enum class ImageType(
//    override val ext: String,
//    override val mimeType: String
//) : FileType {
//
//    PNG("png", "image/png"),
//    JPG("jpg", "image/jpeg"),
//    JPEG("jpeg", "image/jpeg"),
//    GIF("gif", "image/gif"),
//    WEBP("webp", "image/webp"),
//    BMP("bmp", "image/bmp"),
//    HEIC("heic", "image/heic"),
//    HEIF("heif", "image/heif"),
//    TIFF("tiff", "image/tiff"),
//    TIF("tif", "image/tiff"),
//    ICO("ico", "image/x-icon"),
//    DNG("dng", "image/x-adobe-dng");
//}
//
//enum class VideoType(
//    override val ext: String,
//    override val mimeType: String
//) : FileType {
//
//    MP4("mp4", "video/mp4"),
//    THREE_GP("3gp", "video/3gpp"),
//    WEBM("webm", "video/webm"),
//    M4V("m4v", "video/x-m4v"),
//    MKV("mkv", "video/x-matroska"),
//    MOV("mov", "video/quicktime"),
//    AVI("avi", "video/x-msvideo"),
//    FLV("flv", "video/x-flv"),
//    WMV("wmv", "video/x-ms-wmv"),
//    HEVC("hevc", "video/hevc"),
//    VP9("vp9", "video/x-vnd.on2.vp9"),
//    AV1("av1", "video/av01");
//}
//
//enum class AudioType(
//    override val ext: String,
//    override val mimeType: String
//) : FileType {
//
//    MP3("mp3", "audio/mpeg"),
//    AAC("aac", "audio/aac"),
//    WAV("wav", "audio/wav"),
//    AMR("amr", "audio/amr"),
//    THREE_GP("3gp", "audio/3gpp"),
//    M4A("m4a", "audio/mp4"),
//    OGG("ogg", "audio/ogg"),
//    FLAC("flac", "audio/flac"),
//    OPUS("opus", "audio/opus"),
//    AIFF("aiff", "audio/aiff"),
//    CAF("caf", "audio/x-caf");
//}
//
//data class CustomFileType(
//    override val ext: String,
//    override val mimeType: String
//) : FileType


