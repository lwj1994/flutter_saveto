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
                filePath: '/Users/luwenjie/Documents/GitHub/flutter_saveto/example/cc424cb47c2c8b07469ce57c238e49b6_1721974061623.gif',
                mediaType: MediaType.image,
                mimeType: "image/gif"
              );
              try {
                final result = await api.save(request);
                print('Save result: ${result.success} ${result.message}');
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
