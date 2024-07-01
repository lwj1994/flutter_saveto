import 'package:flutter/material.dart';
import 'package:flutter_saveto/flutter_saveto.dart';
import 'package:flutter_saveto/src/messages.g.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Pigeon Example'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final api = SaveToHostApi();
              final request = SaveItemMessage(
                filePath: '/Users/luwenjie/Downloads/发布.png',
                mediaType: MediaType.file,
                saveDirectoryPath: ""
              );
              try {
                final result = await api.save(request);
                print('Save result: ${result.success}');
              } catch (e) {
                print('Error: $e');
              }
            },
            child: Text('Save Image'),
          ),
        ),
      ),
    );
  }
}
