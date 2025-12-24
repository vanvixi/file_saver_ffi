import Foundation
import AVFoundation
import ImageIO
import MobileCoreServices

enum FormatValidator {

    // Cache the list of UTIs that ImageIO supports writing
    private static var supportedImageUTIs: [String] = {
        return CGImageDestinationCopyTypeIdentifiers() as? [String] ?? []
    }()

    static func validateImageFormat(_ fileType: FileType) throws {
        let ext = fileType.ext.lowercased()

        let alwaysSupported = ["png", "jpg", "jpeg", "gif"]
        if alwaysSupported.contains(ext) { return }

        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeRetainedValue() else {
            throw FileSaverError.unsupportedFormat(ext.uppercased(), details: "Could not determine UTI for extension")
        }

        let utiString = uti as String
        if !supportedImageUTIs.contains(utiString) {
            throw FileSaverError.unsupportedFormat(ext.uppercased(), details: "Device cannot encode this image format")
        }
    }

    static func validateVideoFormat(_ fileType: FileType) throws {
        let ext = fileType.ext.lowercased()

        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeRetainedValue() else {
            throw FileSaverError.unsupportedFormat(ext.uppercased(), details: "Invalid video extension")
        }

        let utiString = uti as String

        // Check out AVAssetWriter's support for this Container
        // Note: iOS 13 uses an indirect check via AVAssetWriter(url:fileType:)
        // or more simply, check the validity of UTIs in the AVFoundation system
        let avType = AVFileType(utiString)

        // Check if the system can generate an output for this file type
        if !isAVFileTypeSupported(avType) {
            throw FileSaverError.unsupportedFormat(ext.uppercased(), details: "Device cannot encode this video container")
        }
    }

    static func validateAudioFormat(_ fileType: FileType) throws {
        // Audio on iOS is also classified as an AVFileType
        try validateVideoFormat(fileType)
    }

    // AVFileType Checker Plug-in for iOS 13+
    private static func isAVFileTypeSupported(_ type: AVFileType) -> Bool {
        // The safest way on iOS 13 to check support is to try it
        // or check out AVAssetWriter's list of supported UTIs
        let testWriter = try? AVAssetWriter(outputURL: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test"), fileType: type)
        return testWriter != nil
    }
}