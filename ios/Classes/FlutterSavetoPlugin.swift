import Flutter
import UIKit
import Photos
import Foundation
import CommonCrypto
import SwiftyMimeTypes
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
    var result: SaveToResult?
    private var tempURL: URL?
    private var fileManager = FileManager.default
    
    func save(saveItem: SaveItemMessage) throws -> SaveToResult {
        result = nil // 初始化 result 属性
        
        switch saveItem.mediaType {
        case .image:
            saveImageAtFileUrl(saveItem.filePath, isReturnImagePath: false)
        case .video:
            saveVideo(saveItem.filePath, isReturnImagePath: false)
        case .audio, .file:
            saveFile(from: URL(fileURLWithPath: saveItem.filePath), saveItem: saveItem)
        }
        
        // 等待保存结果返回
        while result == nil {
            RunLoop.current.run(mode: .default, before: Date.distantFuture)
        }
        
        return result ?? SaveToResult(success: false, message: "")
    }
    
    func saveVideo(_ path: String, isReturnImagePath: Bool) {
        if !isReturnImagePath {
            UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(didFinishSavingVideo(videoPath:error:contextInfo:)), nil)
            saveResult(isSuccess: true, error: "")
            return
        }

        var videoIds: [String] = []

        PHPhotoLibrary.shared().performChanges({
            let req = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: path))
            if let videoId = req?.placeholderForCreatedAsset?.localIdentifier {
                videoIds.append(videoId)
            }
        }, completionHandler: { [unowned self] (success, error) in
            DispatchQueue.main.async {
                if success, videoIds.count > 0 {
                    let assetResult = PHAsset.fetchAssets(withLocalIdentifiers: videoIds, options: nil)
                    if assetResult.count > 0 {
                        let videoAsset = assetResult[0]
                        PHImageManager().requestAVAsset(forVideo: videoAsset, options: nil) { (avurlAsset, _, _) in
                            if let urlStr = (avurlAsset as? AVURLAsset)?.url.absoluteString {
                                self.saveResult(isSuccess: true, filePath: urlStr)
                            }
                        }
                    }
                } else {
                    self.saveResult(isSuccess: false, error: "")
                }
            }
        })
    }

    func saveImage(_ image: UIImage, isReturnImagePath: Bool) {
        if (!isReturnImagePath) {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(didFinishSavingImage(image:error:contextInfo:)), nil)
            saveResult(isSuccess: true, error: "")
            return
        }

        var imageIds: [String] = []

        PHPhotoLibrary.shared().performChanges({
            let req = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if let imageId = req.placeholderForCreatedAsset?.localIdentifier {
                imageIds.append(imageId)
            }
        }, completionHandler: { [unowned self] (success, error) in
            DispatchQueue.main.async {
                if (success && imageIds.count > 0) {
                    let assetResult = PHAsset.fetchAssets(withLocalIdentifiers: imageIds, options: nil)
                    if assetResult.count > 0 {
                        let imageAsset = assetResult[0]
                        let options = PHContentEditingInputRequestOptions()
                        options.canHandleAdjustmentData = { _ in true }
                        imageAsset.requestContentEditingInput(with: options) { [unowned self] (contentEditingInput, _) in
                            if let urlStr = contentEditingInput?.fullSizeImageURL?.absoluteString {
                                self.saveResult(isSuccess: true, filePath: urlStr)
                            }
                        }
                    }
                } else {
                    self.saveResult(isSuccess: false, error: "")
                }
            }
        })
    }

    func saveImageAtFileUrl(_ url: String, isReturnImagePath: Bool) {
        guard let image = UIImage(contentsOfFile: url) else {
            saveResult(isSuccess: false, error: "error load：\(url)")
            return
        }

        if (!isReturnImagePath) {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(didFinishSavingImage(image:error:contextInfo:)), nil)
            saveResult(isSuccess: true, error: "")
            return
        }

        var imageIds: [String] = []

        PHPhotoLibrary.shared().performChanges({
            let req = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if let imageId = req.placeholderForCreatedAsset?.localIdentifier {
                imageIds.append(imageId)
            }
        }, completionHandler: { [unowned self] (success, error) in
            DispatchQueue.main.async {
                if (success && imageIds.count > 0) {
                    let assetResult = PHAsset.fetchAssets(withLocalIdentifiers: imageIds, options: nil)
                    if assetResult.count > 0 {
                        let imageAsset = assetResult[0]
                        let options = PHContentEditingInputRequestOptions()
                        options.canHandleAdjustmentData = { _ in true }
                        imageAsset.requestContentEditingInput(with: options) { [unowned self] (contentEditingInput, _) in
                            if let urlStr = contentEditingInput?.fullSizeImageURL?.absoluteString {
                                self.saveResult(isSuccess: true, filePath: urlStr)
                            }
                        }
                    }
                } else {
                    self.saveResult(isSuccess: false, error: "check permission")
                }
            }
        })
    }

    @objc func didFinishSavingImage(image: UIImage, error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        saveResult(isSuccess: error == nil, error: error?.localizedDescription)
    }

    @objc func didFinishSavingVideo(videoPath: String, error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        saveResult(isSuccess: error == nil, error: error?.localizedDescription)
    }

    func saveResult(isSuccess: Bool, error: String? = nil, filePath: String? = nil) {
        result = SaveToResult(success: isSuccess, message: error ?? "")
    }

    func saveFile(from sourceURL: URL, saveItem: SaveItemMessage) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!



//        if let saveFilePath = saveItem.saveFilePath {
//            destinationURL = URL(fileURLWithPath: saveFilePath)
//        } else {
//
//        }
        var fileExtension = "";
        switch(saveItem.mediaType){
            case MediaType.audio:
            fileExtension = "aac";
                break;
            case MediaType.file:
            fileExtension = "bin";
                break;
            case MediaType.image:
            fileExtension = "png";
                break;
            case MediaType.video:
            fileExtension = "mp4";
                break;
        }
        
        if(saveItem.mimeType != nil && saveItem.mimeType?.isEmpty == false){
            let ext = MimeTypes.filenameExtensions(forType: saveItem.mimeType!).first;
            if(ext != nil){
                fileExtension  =  ext!;
            }
        }
        
        
         let relativePath = getValidDirPath(saveItem.saveDirectoryPath)
         // 创建目标文件夹
         let targetDirectory = documentsDirectory.appendingPathComponent(relativePath)
         do {
             try fileManager.createDirectory(at: targetDirectory, withIntermediateDirectories: true, attributes: nil)
         } catch {
             print("Error creating directory:", error.localizedDescription)
             self.saveResult(isSuccess: false, error: error.localizedDescription)
             return
         }
    
        // 目标文件URL
        let destinationURL = targetDirectory.appendingPathComponent(saveItem.filePath.md5 + "." + fileExtension)
        
        
        do {
            let data = try Data(contentsOf: sourceURL)
            try data.write(to: destinationURL)
            print("File saved successfully at \(destinationURL)")
            
            self.saveResult(isSuccess: true)
            
        } catch {
            print("Error saving file:", error.localizedDescription)
            self.saveResult(isSuccess: false, error: error.localizedDescription)
        }
    }
    
    func getValidDirPath(_ directoryPath: String) -> String {
        var path = directoryPath
        if path.hasPrefix("/") {
            path = String(path.dropFirst())
        }
        if path.hasSuffix("/") {
            path = String(path.dropLast())
        }
        return path
    }
}