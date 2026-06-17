import Flutter
import UIKit
import Photos
import Foundation
import CommonCrypto
import SwiftyMimeTypes

private typealias SaveCompletion = (Result<SaveToResult, Error>) -> Void

extension String {
    var md5: String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = self.data(using: .utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress,
                   let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
}

public class FlutterSavetoPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        SaveToHostApiSetup.setUp(
            binaryMessenger: registrar.messenger(),
            api: SaveToImplementation()
        )
    }
}

class SaveToImplementation: NSObject, SaveToHostApi {
    private var fileManager = FileManager.default
    private let fileCopyQueue = DispatchQueue(label: "com.lwjlol.flutter_saveto.file-copy", qos: .utility)

    func save(saveItem: SaveItemMessage, completion: @escaping (Result<SaveToResult, Error>) -> Void) {
        switch saveItem.mediaType {
        case .image:
            saveImageAtFileUrl(saveItem.filePath, completion: completion)
        case .video:
            saveVideo(saveItem.filePath, completion: completion)
        case .audio, .file:
            let sourceURL = URL(fileURLWithPath: saveItem.filePath)
            fileCopyQueue.async {
                self.saveFile(from: sourceURL, saveItem: saveItem, completion: completion)
            }
        }
    }

    private func saveVideo(_ path: String, completion: @escaping SaveCompletion) {
        let fileURL = URL(fileURLWithPath: path)
        guard fileManager.fileExists(atPath: fileURL.path) else {
            complete(completion, isSuccess: false, message: localizedMessage(zh: "视频文件不存在", en: "Video file not found."))
            return
        }

        requestPhotoLibraryAddPermission { [weak self] isGranted, message in
            guard let self = self else { return }
            guard isGranted else {
                self.complete(completion, isSuccess: false, message: message ?? self.noPhotoLibraryAddPermissionMessage())
                return
            }
            self.saveAssetToPhotoLibrary(
                fileURL: fileURL,
                resourceType: .video,
                failureMessage: self.localizedMessage(zh: "视频保存失败", en: "Failed to save video."),
                completion: completion
            )
        }
    }

    private func saveImageAtFileUrl(_ path: String, completion: @escaping SaveCompletion) {
        let fileURL = URL(fileURLWithPath: path)
        guard fileManager.fileExists(atPath: fileURL.path) else {
            complete(completion, isSuccess: false, message: localizedMessage(zh: "图片文件不存在", en: "Image file not found."))
            return
        }

        requestPhotoLibraryAddPermission { [weak self] isGranted, message in
            guard let self = self else { return }
            guard isGranted else {
                self.complete(completion, isSuccess: false, message: message ?? self.noPhotoLibraryAddPermissionMessage())
                return
            }
            self.saveAssetToPhotoLibrary(
                fileURL: fileURL,
                resourceType: .photo,
                failureMessage: self.localizedMessage(zh: "图片保存失败", en: "Failed to save image."),
                completion: completion
            )
        }
    }

    private func saveAssetToPhotoLibrary(fileURL: URL, resourceType: PHAssetResourceType, failureMessage: String, completion: @escaping SaveCompletion) {
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: resourceType, fileURL: fileURL, options: nil)
        }, completionHandler: { [weak self] success, error in
            guard let self = self else { return }
            if success {
                self.complete(completion, isSuccess: true)
            } else {
                self.complete(completion, isSuccess: false, message: error?.localizedDescription ?? failureMessage)
            }
        })
    }

    private func requestPhotoLibraryAddPermission(_ completion: @escaping (Bool, String?) -> Void) {
        guard hasPhotoLibraryAddUsageDescription() else {
            completion(false, localizedMessage(
                zh: "请在 iOS 宿主 App 的 Info.plist 添加 NSPhotoLibraryAddUsageDescription，用于说明保存图片到相册的原因。",
                en: "Add NSPhotoLibraryAddUsageDescription to the iOS host app Info.plist to explain why images are saved to Photos."
            ))
            return
        }

        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
            switch status {
            case .authorized, .limited:
                completion(true, nil)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                    switch status {
                    case .authorized, .limited:
                        completion(true, nil)
                    case .denied, .restricted:
                        completion(false, self.photoLibraryPermissionMessage(for: status))
                    case .notDetermined:
                        completion(false, self.noPhotoLibraryAddPermissionMessage())
                    @unknown default:
                        completion(false, self.unavailablePhotoLibraryAddPermissionMessage())
                    }
                }
            case .denied, .restricted:
                completion(false, photoLibraryPermissionMessage(for: status))
            @unknown default:
                completion(false, unavailablePhotoLibraryAddPermissionMessage())
            }
            return
        }

        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .notDetermined:
            completion(true, nil)
        case .denied, .restricted:
            completion(false, photoLibraryPermissionMessage(for: status))
        @unknown default:
            completion(false, unavailablePhotoLibraryAddPermissionMessage())
        }
    }

    private func hasPhotoLibraryAddUsageDescription() -> Bool {
        guard let message = Bundle.main.object(forInfoDictionaryKey: "NSPhotoLibraryAddUsageDescription") as? String else {
            return false
        }
        return !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func photoLibraryPermissionMessage(for status: PHAuthorizationStatus) -> String {
        switch status {
        case .denied:
            return localizedMessage(
                zh: "没有保存到相册的权限，请在系统设置中允许照片添加权限。",
                en: "No permission to save to Photos. Allow add-only Photos access in Settings."
            )
        case .restricted:
            return localizedMessage(
                zh: "当前设备限制了相册访问，无法保存图片。",
                en: "Photos access is restricted on this device. Unable to save the image."
            )
        default:
            return noPhotoLibraryAddPermissionMessage()
        }
    }

    private func noPhotoLibraryAddPermissionMessage() -> String {
        localizedMessage(zh: "没有保存到相册的权限", en: "No permission to save to Photos.")
    }

    private func unavailablePhotoLibraryAddPermissionMessage() -> String {
        localizedMessage(zh: "无法获取保存到相册的权限", en: "Unable to get permission to save to Photos.")
    }

    private func localizedMessage(zh: String, en: String) -> String {
        let preferredLanguage = Locale.preferredLanguages.first?.lowercased() ?? ""
        return preferredLanguage.hasPrefix("zh") ? zh : en
    }

    private func complete(_ completion: @escaping SaveCompletion, isSuccess: Bool, message: String = "") {
        let result = SaveToResult(success: isSuccess, message: message)
        if Thread.isMainThread {
            completion(.success(result))
        } else {
            DispatchQueue.main.async {
                completion(.success(result))
            }
        }
    }

    private func saveFile(from sourceURL: URL, saveItem: SaveItemMessage, completion: @escaping SaveCompletion) {
        do {
            guard isRegularFile(sourceURL) else {
                throw makeError(localizedMessage(zh: "源文件不存在", en: "Source file not found."))
            }

            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileExtension = resolveFileExtension(for: saveItem)
            let relativePath = try getValidDirPath(saveItem.saveDirectoryPath)
            let targetDirectory = relativePath.isEmpty
                ? documentsDirectory
                : documentsDirectory.appendingPathComponent(relativePath, isDirectory: true)
            try ensurePath(targetDirectory, isInside: documentsDirectory)
            try fileManager.createDirectory(at: targetDirectory, withIntermediateDirectories: true, attributes: nil)

            let fileName = try resolveFileName(for: saveItem, fileExtension: fileExtension)
            let destinationURL = targetDirectory.appendingPathComponent(fileName, isDirectory: false)
            try ensurePath(destinationURL, isInside: documentsDirectory)
            try copyFile(from: sourceURL, to: destinationURL)

            complete(completion, isSuccess: true)
        } catch {
            complete(completion, isSuccess: false, message: error.localizedDescription)
        }
    }

    private func isRegularFile(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return exists && !isDirectory.boolValue
    }

    private func resolveFileExtension(for saveItem: SaveItemMessage) -> String {
        if let mimeType = saveItem.mimeType, !mimeType.isEmpty,
           let extensionFromMime = MimeTypes.filenameExtensions(forType: mimeType).first,
           !extensionFromMime.isEmpty {
            return extensionFromMime
        }

        switch saveItem.mediaType {
        case .audio:
            return "aac"
        case .file:
            return "bin"
        case .image:
            return "png"
        case .video:
            return "mp4"
        }
    }

    private func resolveFileName(for saveItem: SaveItemMessage, fileExtension: String) throws -> String {
        if let fileName = saveItem.name, !fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            try validateFileName(fileName)
            return fileName
        }

        return fileExtension.isEmpty ? saveItem.filePath.md5 : "\(saveItem.filePath.md5).\(fileExtension)"
    }

    private func validateFileName(_ fileName: String) throws {
        if fileName == "." || fileName == ".." || fileName.contains("/") || fileName.contains("\\") || fileName.contains("\0") {
            throw makeError(localizedMessage(zh: "文件名不合法", en: "Invalid file name."))
        }
    }

    private func getValidDirPath(_ directoryPath: String) throws -> String {
        var path = directoryPath.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\\", with: "/")
        while path.hasPrefix("/") {
            path = String(path.dropFirst())
        }
        while path.hasSuffix("/") {
            path = String(path.dropLast())
        }

        guard !path.isEmpty else {
            return ""
        }

        let segments = path.split(separator: "/", omittingEmptySubsequences: false)
        for segment in segments {
            if segment.isEmpty || segment == "." || segment == ".." || segment.contains("\0") {
                throw makeError(localizedMessage(zh: "保存目录不合法", en: "Invalid save directory path."))
            }
        }

        return segments.joined(separator: "/")
    }

    private func ensurePath(_ childURL: URL, isInside parentURL: URL) throws {
        let parentPath = parentURL.resolvingSymlinksInPath().standardizedFileURL.path
        let childPath = childURL.resolvingSymlinksInPath().standardizedFileURL.path
        guard childPath == parentPath || childPath.hasPrefix(parentPath + "/") else {
            throw makeError(localizedMessage(zh: "目标路径不合法", en: "Invalid destination path."))
        }
    }

    private func copyFile(from sourceURL: URL, to destinationURL: URL) throws {
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }

        guard let inputStream = InputStream(url: sourceURL),
              let outputStream = OutputStream(url: destinationURL, append: false) else {
            throw makeError(localizedMessage(zh: "无法打开文件流", en: "Unable to open file stream."))
        }

        inputStream.open()
        outputStream.open()
        defer {
            inputStream.close()
            outputStream.close()
        }

        var buffer = [UInt8](repeating: 0, count: 1024 * 1024)
        while true {
            let bytesRead = inputStream.read(&buffer, maxLength: buffer.count)
            if bytesRead < 0 {
                throw inputStream.streamError ?? makeError(localizedMessage(zh: "读取文件失败", en: "Failed to read file."))
            }
            if bytesRead == 0 {
                break
            }

            var bytesWritten = 0
            while bytesWritten < bytesRead {
                let result = buffer.withUnsafeBufferPointer { pointer -> Int in
                    guard let baseAddress = pointer.baseAddress else {
                        return -1
                    }
                    return outputStream.write(baseAddress.advanced(by: bytesWritten), maxLength: bytesRead - bytesWritten)
                }
                if result <= 0 {
                    throw outputStream.streamError ?? makeError(localizedMessage(zh: "写入文件失败", en: "Failed to write file."))
                }
                bytesWritten += result
            }
        }
    }

    private func makeError(_ message: String) -> NSError {
        NSError(domain: "FlutterSaveto", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
