import 'package:flutter_saveto/src/flutter_saveto_method_channel.dart';
import 'package:flutter_saveto/src/flutter_saveto_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_saveto/flutter_saveto.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterSavetoPlatform
    with MockPlatformInterfaceMixin
    implements FlutterSavetoPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterSavetoPlatform initialPlatform = FlutterSavetoPlatform.instance;

  test('$MethodChannelFlutterSaveto is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterSaveto>());
  });

  test('getPlatformVersion', () async {
    FlutterSaveto FlutterSavetoPlugin = FlutterSaveto();
    MockFlutterSavetoPlatform fakePlatform = MockFlutterSavetoPlatform();
    FlutterSavetoPlatform.instance = fakePlatform;

    expect(await FlutterSavetoPlugin.getPlatformVersion(), '42');
  });
}
