import 'package:flutter_saveto/src/messages.g.dart';

class FlutterSaveto {
  static save(SaveItemMessage saveItem) {
    SaveToHostApi().save(saveItem);
  }
}

extension SaveItemExtension on SaveItemMessage {
  MediaType get toMediaType {
    if (_imageMimeTypes.contains(mimeType)) {
      return MediaType.image;
    } else if (_videoMimeTypes.contains(mimeType)) {
      return MediaType.video;
    } else if (_audioMimeTypes.contains(mimeType)) {
      return MediaType.audio;
    } else {
      return MediaType.file;
    }
  }
}

const _imageMimeTypes = [
  "image/apng",
  "image/avif",
  "image/bmp",
  "image/gif",
  "image/vnd.microsoft.icon",
  "image/jpeg",
  "image/png",
  "image/svg+xml",
  "image/tiff",
  "image/webp",
];

const _videoMimeTypes = [
  "video/x-msvideo",
  "video/mp4",
  "video/mpeg",
  "video/ogg",
  "video/mp2t",
  "video/webm",
  "video/3gpp",
  "video/3gpp2",
];

const _audioMimeTypes = [
  "audio/aac",
  "audio/midi",
  "audio/x-midi",
  "audio/mpeg",
  "audio/ogg",
  "audio/wav",
  "audio/webm",
  "audio/3gpp",
  "audio/3gpp2",
];
