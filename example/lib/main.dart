import 'package:flutter/material.dart';
import 'package:flutter_saveto/flutter_saveto.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pigeon Example'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final request = SaveItemMessage(
                filePath:
                    '/Users/luwenjie/Documents/GitHub/flutter_saveto/example/cc424cb47c2c8b07469ce57c238e49b6_1721974061623.gif',
                mediaType: MediaType.file,
                mimeType: 'image/gif',
                name: 'test.gif',
              );
              try {
                final result = await FlutterSaveto.save(request);
                debugPrint('Save result: ${result.success} ${result.message}');
              } catch (e) {
                debugPrint('Error: $e');
              }
            },
            child: const Text('Save Image'),
          ),
        ),
      ),
    );
  }
}
