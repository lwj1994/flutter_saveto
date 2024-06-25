import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_saveto_platform_interface.dart';

/// An implementation of [FlutterSavetoPlatform] that uses method channels.
class MethodChannelFlutterSaveto extends FlutterSavetoPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_saveto');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
