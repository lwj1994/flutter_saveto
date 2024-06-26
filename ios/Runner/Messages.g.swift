// Copyright 2024 EchoTech. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v20.0.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

/// Error class for passing custom error details to Dart side.
final class PigeonError: Error {
  let code: String
  let message: String?
  let details: Any?

  init(code: String, message: String?, details: Any?) {
    self.code = code
    self.message = message
    self.details = details
  }

  var localizedDescription: String {
    return
      "PigeonError(code: \(code), message: \(message ?? "<nil>"), details: \(details ?? "<nil>")"
      }
}

private func wrapResult(_ result: Any?) -> [Any?] {
  return [result]
}

private func wrapError(_ error: Any) -> [Any?] {
  if let pigeonError = error as? PigeonError {
    return [
      pigeonError.code,
      pigeonError.message,
      pigeonError.details,
    ]
  }
  if let flutterError = error as? FlutterError {
    return [
      flutterError.code,
      flutterError.message,
      flutterError.details,
    ]
  }
  return [
    "\(error)",
    "\(type(of: error))",
    "Stacktrace: \(Thread.callStackSymbols)",
  ]
}

private func isNullish(_ value: Any?) -> Bool {
  return value is NSNull || value == nil
}

private func nilOrValue<T>(_ value: Any?) -> T? {
  if value is NSNull { return nil }
  return value as! T?
}

enum MediaType: Int {
  case audio = 0
  case file = 1
  case video = 2
  case image = 3
}

/// Generated class from Pigeon that represents data sent in messages.
struct SaveItemMessage {
  var mediaType: MediaType
  var name: String? = nil
  var filePath: String
  var saveDirectoryPath: String
  var saveFilePath: String? = nil
  var description: String? = nil
  var mimeType: String? = nil

  // swift-format-ignore: AlwaysUseLowerCamelCase
  static func fromList(_ __pigeon_list: [Any?]) -> SaveItemMessage? {
    let mediaType = __pigeon_list[0] as! MediaType
    let name: String? = nilOrValue(__pigeon_list[1])
    let filePath = __pigeon_list[2] as! String
    let saveDirectoryPath = __pigeon_list[3] as! String
    let saveFilePath: String? = nilOrValue(__pigeon_list[4])
    let description: String? = nilOrValue(__pigeon_list[5])
    let mimeType: String? = nilOrValue(__pigeon_list[6])

    return SaveItemMessage(
      mediaType: mediaType,
      name: name,
      filePath: filePath,
      saveDirectoryPath: saveDirectoryPath,
      saveFilePath: saveFilePath,
      description: description,
      mimeType: mimeType
    )
  }
  func toList() -> [Any?] {
    return [
      mediaType,
      name,
      filePath,
      saveDirectoryPath,
      saveFilePath,
      description,
      mimeType,
    ]
  }
}

/// Generated class from Pigeon that represents data sent in messages.
struct SaveToResult {
  var success: Bool
  var message: String

  // swift-format-ignore: AlwaysUseLowerCamelCase
  static func fromList(_ __pigeon_list: [Any?]) -> SaveToResult? {
    let success = __pigeon_list[0] as! Bool
    let message = __pigeon_list[1] as! String

    return SaveToResult(
      success: success,
      message: message
    )
  }
  func toList() -> [Any?] {
    return [
      success,
      message,
    ]
  }
}
private class MessagesPigeonCodecReader: FlutterStandardReader {
  override func readValue(ofType type: UInt8) -> Any? {
    switch type {
    case 129:
      return SaveItemMessage.fromList(self.readValue() as! [Any?])
    case 130:
      return SaveToResult.fromList(self.readValue() as! [Any?])
    case 131:
      var enumResult: MediaType? = nil
      let enumResultAsInt: Int? = nilOrValue(self.readValue() as? Int)
      if let enumResultAsInt = enumResultAsInt {
        enumResult = MediaType(rawValue: enumResultAsInt)
      }
      return enumResult
    default:
      return super.readValue(ofType: type)
    }
  }
}

private class MessagesPigeonCodecWriter: FlutterStandardWriter {
  override func writeValue(_ value: Any) {
    if let value = value as? SaveItemMessage {
      super.writeByte(129)
      super.writeValue(value.toList())
    } else if let value = value as? SaveToResult {
      super.writeByte(130)
      super.writeValue(value.toList())
    } else if let value = value as? MediaType {
      super.writeByte(131)
      super.writeValue(value.rawValue)
    } else {
      super.writeValue(value)
    }
  }
}

private class MessagesPigeonCodecReaderWriter: FlutterStandardReaderWriter {
  override func reader(with data: Data) -> FlutterStandardReader {
    return MessagesPigeonCodecReader(data: data)
  }

  override func writer(with data: NSMutableData) -> FlutterStandardWriter {
    return MessagesPigeonCodecWriter(data: data)
  }
}

class MessagesPigeonCodec: FlutterStandardMessageCodec, @unchecked Sendable {
  static let shared = MessagesPigeonCodec(readerWriter: MessagesPigeonCodecReaderWriter())
}

/// Generated protocol from Pigeon that represents a handler of messages from Flutter.
protocol SaveToHostApi {
  func save(saveItem: SaveItemMessage) throws -> SaveToResult
}

/// Generated setup class from Pigeon to handle messages through the `binaryMessenger`.
class SaveToHostApiSetup {
  static var codec: FlutterStandardMessageCodec { MessagesPigeonCodec.shared }
  /// Sets up an instance of `SaveToHostApi` to handle messages through the `binaryMessenger`.
  static func setUp(binaryMessenger: FlutterBinaryMessenger, api: SaveToHostApi?, messageChannelSuffix: String = "") {
    let channelSuffix = messageChannelSuffix.count > 0 ? ".\(messageChannelSuffix)" : ""
    let saveChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.flutter_saveto.SaveToHostApi.save\(channelSuffix)", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      saveChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let saveItemArg = args[0] as! SaveItemMessage
        do {
          let result = try api.save(saveItem: saveItemArg)
          reply(wrapResult(result))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      saveChannel.setMessageHandler(nil)
    }
  }
}
