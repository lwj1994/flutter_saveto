# flutter_saveto

English | [简体中文](README.zh-CN.md)

`flutter_saveto` is a Flutter plugin for saving local files to user-visible locations on Android and iOS.

It is designed for files that already exist on the device. Pass a local file path, choose the media type, and the plugin copies the file to the platform-specific destination.

## Platform behavior

| Platform | `MediaType.image` | `MediaType.video` | `MediaType.audio` | `MediaType.file` |
| --- | --- | --- | --- | --- |
| Android | `Pictures/<saveDirectoryPath>` via `MediaStore` | `Movies/<saveDirectoryPath>` via `MediaStore` | `Music/<saveDirectoryPath>` via `MediaStore` | `Downloads/<saveDirectoryPath>` via `MediaStore` |
| iOS | Photos library | Photos library | App Documents directory | App Documents directory |

Notes:

- Android 10+ uses scoped storage through `MediaStore`.
- Android 9 and earlier write to external public directories and trigger a media scan. Your host app may need storage permissions for those devices.
- iOS image and video saves require add-only Photos permission.
- iOS file and audio saves are copied into the app's Documents directory, not the system Downloads app.
- Only Android and iOS have native implementations in this package at the moment.

## Installation

Add the package to your Flutter app:

```yaml
dependencies:
  flutter_saveto: ^0.0.1
```

Then import it:

```dart
import 'package:flutter_saveto/flutter_saveto.dart';
```

## Usage

```dart
final result = await FlutterSaveto.save(
  SaveItemMessage(
    filePath: localImagePath,
    mediaType: MediaType.image,
    mimeType: 'image/png',
    name: 'image.png',
    saveDirectoryPath: 'MyApp',
  ),
);

if (!result.success) {
  // `message` may contain permission, missing file, or platform save errors.
  debugPrint(result.message);
}
```

### Save a file to Android Downloads

```dart
final result = await FlutterSaveto.save(
  SaveItemMessage(
    filePath: localPdfPath,
    mediaType: MediaType.file,
    mimeType: 'application/pdf',
    name: 'report.pdf',
    saveDirectoryPath: 'Reports',
  ),
);
```

On Android this saves to `Downloads/Reports/report.pdf`. On iOS this saves to the app Documents directory under `Reports/report.pdf`.

## API

### `FlutterSaveto.save`

```dart
static Future<SaveToResult> save(SaveItemMessage saveItem)
```

Copies the local file described by `saveItem` to the host platform destination.

### `SaveItemMessage`

| Field | Required | Description |
| --- | --- | --- |
| `filePath` | Yes | Absolute path to an existing local file. Remote URLs are not downloaded by this plugin. |
| `mediaType` | No | Destination category. Defaults to `MediaType.file`. |
| `mimeType` | No | Recommended. Used for Android metadata and for generating file extensions when `name` is empty. |
| `name` | No | Output file name. The plugin generates one when this is empty. |
| `saveDirectoryPath` | No | Optional subdirectory. Leading and trailing slashes are trimmed. |
| `description` | No | Reserved by the message model; currently not used by the native implementations. |

### `MediaType`

```dart
enum MediaType {
  audio,
  file,
  video,
  image,
}
```

### `SaveToResult`

| Field | Description |
| --- | --- |
| `success` | `true` when the platform save operation completed. |
| `message` | Empty on success. Contains a platform error message on failure. |

## iOS Photos permission

When saving `MediaType.image` or `MediaType.video` to Photos, the iOS host app must declare add-only Photos usage in `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save images and videos to your Photos library.</string>
```

Use `NSPhotoLibraryAddUsageDescription` for add-only writes. Do not add `NSPhotoLibraryUsageDescription` unless your app also reads, lists, or selects Photos library content.

The system permission prompt reads this value from the host app's `Info.plist`. A Flutter plugin cannot reliably inject the final user-facing usage text for the host app, so each app should provide its own copy.

For localized permission text, add the same key to files such as:

- `ios/Runner/en.lproj/InfoPlist.strings`
- `ios/Runner/zh-Hans.lproj/InfoPlist.strings`

Example:

```strings
"NSPhotoLibraryAddUsageDescription" = "Save images and videos to your Photos library.";
```

If the host app is missing `NSPhotoLibraryAddUsageDescription`, the iOS implementation returns `success = false` with a message explaining the missing key instead of triggering a system privacy crash.

## Error handling

Always check `SaveToResult.success` before showing a success state to users:

```dart
final result = await FlutterSaveto.save(item);

if (result.success) {
  // Saved.
} else {
  // Show or log result.message.
}
```

The returned `message` can include permission denial, missing source file, invalid destination, or platform I/O errors.
