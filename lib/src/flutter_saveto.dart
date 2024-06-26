import 'package:flutter_saveto/src/messages.g.dart';

class FlutterSaveto {
  static save(SaveItemMessage saveItem) {
    SaveToHostApi().save(saveItem);
  }
}
