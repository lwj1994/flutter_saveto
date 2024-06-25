import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_saveto_method_channel.dart';

abstract class FlutterSavetoPlatform extends PlatformInterface {
  /// Constructs a FlutterSavetoPlatform.
  FlutterSavetoPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterSavetoPlatform _instance = MethodChannelFlutterSaveto();

  /// The default instance of [FlutterSavetoPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterSaveto].
  static FlutterSavetoPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterSavetoPlatform] when
  /// they register themselves.
  static set instance(FlutterSavetoPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
