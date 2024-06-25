import 'package:pigeon/pigeon.dart';

// #docregion config
@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartOptions: DartOptions(),
  // Android
  kotlinOut: 'android/src/main/kotlin/com/lwjlol/flutter_saveto/Messages.g.kt',
  kotlinOptions: KotlinOptions(package: "com.lwjlol.flutter_saveto"),
  // javaOut: 'android/src/main/java/io/flutter/plugins/Messages.java',
  // javaOptions: JavaOptions(package: "io.flutter.plugins"),
  // iOS macOS
  swiftOut: 'ios/Runner/Messages.g.swift',
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
enum SaveToLocation {
  // public download
  download,
  // only for mobile(iOS+Android)
  gallery;
}

class SaveItemMessage {
  SaveItemMessage({
    required this.filePath,
    this.location = SaveToLocation.download,
  });

  SaveToLocation location;
  String? name;
  String filePath;
  String? description;
  String? mimeType;
}

@HostApi()
abstract class SaveToHostApi {
  bool save(SaveItemMessage saveItem);
}
