import 'package:pigeon/pigeon.dart';

// #docregion config
@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartOptions: DartOptions(),
  // Android
  // kotlinOut: 'android/src/main/kotlin/com/lwjlol/flutter_saveto/Messages.g.kt',
  // kotlinOptions: KotlinOptions(package: "com.lwjlol.flutter_saveto"),
  javaOut: 'android/src/main/java/com/lwjlol/flutter_saveto/Messages.java',
  javaOptions: JavaOptions(package: "com.lwjlol.flutter_saveto"),

  // iOS macOS
  swiftOut: 'ios/Classes/Messages.g.swift',
  swiftOptions: SwiftOptions(),
  //objcHeaderOut: 'macos/Runner/messages.g.h',
  //objcSourceOut: 'macos/Runner/messages.g.m',

  cppOptions: CppOptions(namespace: 'flutter_saveto'),
  cppHeaderOut: 'windows/runner/messages.g.h',
  cppSourceOut: 'windows/runner/messages.g.cpp',
  // Set this to a unique prefix for your plugin or application, per Objective-C naming conventions.
  //objcOptions: ObjcOptions(prefix: 'PGN'),
  copyrightHeader: 'pigeons/copyright.txt',
  dartPackageName: 'flutter_saveto',
))
enum MediaType {
  // public download
  audio,
  file,
  video,
  // only for mobile(iOS+Android)
  image;
}

class SaveItemMessage {
  SaveItemMessage({
    required this.filePath,
    this.saveDirectoryPath = "",
    this.mediaType = MediaType.file,
  });

  MediaType mediaType;
  String? name;
  String filePath;
  String saveDirectoryPath;
  String? description;
  String? mimeType;
}

class SaveToResult {
  SaveToResult({
    this.success = true,
    this.message = "",
  });

  bool success;
  String message;
}

@HostApi()
abstract class SaveToHostApi {
  @async
  SaveToResult save(SaveItemMessage saveItem);
}
