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
    var resultCallback: ((Result<SaveToResult, Error>) -> Void)?
    private var tempURL: URL?
    private var fileManager = FileManager.default
    
    func save(saveItem: SaveItemMessage, completion: @escaping (Result<SaveToResult, Error>) -> Void) {
        resultCallback = completion;
        switch saveItem.mediaType {
        case .image:
            saveImageAtFileUrl(saveItem.filePath)
        case .video:
            saveVideo(saveItem.filePath)
        case .audio, .file:
            saveFile(from: URL(fileURLWithPath: saveItem.filePath), saveItem: saveItem);
        }
    
    }
    
    func saveVideo(_ path: String) {
        UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(didFinishSavingVideo(videoPath:error:contextInfo:)), nil)
        saveResult(isSuccess: true, error: "")
    }

    func saveImageAtFileUrl(_ url: String) {
        guard let image = UIImage(contentsOfFile: url) else {
                    saveResult(isSuccess: false, error: "error load：\(url)")
                    return
                }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(didFinishSavingImage(image:error:contextInfo:)), nil)
    }
    


    @objc func didFinishSavingImage(image: UIImage, error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        saveResult(isSuccess: error == nil, error: error?.localizedDescription)
    }

    @objc func didFinishSavingVideo(videoPath: String, error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        saveResult(isSuccess: error == nil, error: error?.localizedDescription)
    }

    func saveResult(isSuccess: Bool, error: String? = nil) {
        if(resultCallback == nil) {
            return;
        }
        resultCallback!(.success(SaveToResult(success: isSuccess, message: error ?? "")));
    }

    func saveFile(from sourceURL: URL, saveItem: SaveItemMessage) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

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
