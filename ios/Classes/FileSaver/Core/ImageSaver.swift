import Foundation
import Photos

class ImageSaver: BaseFileSaver {
    func saveBytes(
        fileData: Data,
        fileType: FileType,
        baseFileName: String,
        subDir: String?,
        conflictResolution: ConflictResolution
    ) throws -> SaveResult {
        try FormatValidator.validateImageFormat(fileType)
        try validateFileData(fileData)

        let hasReadAccess = try requestPhotosPermission()
        let fileName = buildFileName(base: baseFileName, extension: fileType.ext)

        if let result = try handlePhotosConflictResolution(
            fileName: fileName,
            subDir: subDir,
            conflictResolution: conflictResolution,
            hasReadAccess: hasReadAccess
        ) {
            return result
        }

        return try saveToPhotosLibrary(imageData: fileData, fileName: fileName, albumName: hasReadAccess ? subDir : nil)
    }

    private func saveToPhotosLibrary(imageData: Data, fileName: String, albumName: String?) throws -> SaveResult {
        let album = try albumName.map { try findOrCreateAlbum(name: $0) }

        var assetId: String?

        do {
            try PHPhotoLibrary.shared().performChangesAndWait {
                let request = PHAssetCreationRequest.forAsset()
                let options = PHAssetResourceCreationOptions()
                options.originalFilename = fileName
                request.addResource(with: .photo, data: imageData, options: options)

                if let album = album {
                    if let placeholder = request.placeholderForCreatedAsset {
                        let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                        albumChangeRequest?.addAssets([placeholder] as NSArray)
                    }
                }

                assetId = request.placeholderForCreatedAsset?.localIdentifier
            }
        } catch {
            throw FileSaverError.fileIO("Failed to save image: \(error.localizedDescription)")
        }

        guard let assetId = assetId else {
            throw FileSaverError.fileIO("Failed to save image to Photos library")
        }

        return .success(filePath: assetId, fileUri: "ph://\(assetId)")
    }
}
