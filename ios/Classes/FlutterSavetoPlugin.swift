import Flutter
import UIKit
import Photos

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
        
        var destinationURL: URL
        
        if let saveFilePath = saveItem.saveFilePath {
            destinationURL = URL(fileURLWithPath: saveFilePath)
        } else {
            destinationURL = documentsDirectory.appendingPathComponent(sourceURL.lastPathComponent)
        }
        
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
    
    static func getValidDirPath(_ directoryPath: String) -> String {
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

