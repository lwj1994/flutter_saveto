
import 'flutter_saveto_platform_interface.dart';

class FlutterSaveto {
  Future<String?> getPlatformVersion() {
    return FlutterSavetoPlatform.instance.getPlatformVersion();
  }
}
