import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
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
                filePath: '/Users/macbookpro/Desktop/WX20240627-192152@2x.png',
                mediaType: MediaType
                    .image, 
              );              try {
                final result = await api.save(request);
                print('Save result: ${result.message}');
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
