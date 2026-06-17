# flutter_saveto

[English](README.md) | 简体中文

`flutter_saveto` 是一个用于将本地文件保存到 Android 和 iOS 用户可见位置的 Flutter 插件。

这个插件处理的是设备上已经存在的本地文件。传入本地文件路径、指定媒体类型后，插件会把文件复制到对应平台的位置。

## 平台行为

| 平台 | `MediaType.image` | `MediaType.video` | `MediaType.audio` | `MediaType.file` |
| --- | --- | --- | --- | --- |
| Android | 通过 `MediaStore` 保存到 `Pictures/<saveDirectoryPath>` | 通过 `MediaStore` 保存到 `Movies/<saveDirectoryPath>` | 通过 `MediaStore` 保存到 `Music/<saveDirectoryPath>` | 通过 `MediaStore` 保存到 `Downloads/<saveDirectoryPath>` |
| iOS | 系统相册 | 系统相册 | App Documents 目录 | App Documents 目录 |

说明：

- Android 10 及以上通过 `MediaStore` 适配分区存储。
- Android 9 及以下会写入外部公共目录并触发媒体扫描。宿主 App 在这些设备上可能需要存储权限。
- iOS 保存图片和视频到相册时需要只添加照片的权限。
- iOS 保存普通文件和音频时会复制到当前 App 的 Documents 目录，不会保存到系统 Downloads App。
- 当前包内只有 Android 和 iOS 有原生实现。

## 安装

在 Flutter App 中添加依赖：

```yaml
dependencies:
  flutter_saveto: ^0.0.1
```

然后导入：

```dart
import 'package:flutter_saveto/flutter_saveto.dart';
```

## 使用

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
  // `message` 可能包含权限拒绝、文件不存在或平台保存失败等原因。
  debugPrint(result.message);
}
```

### 保存文件到 Android Downloads

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

在 Android 上会保存到 `Downloads/Reports/report.pdf`。在 iOS 上会保存到当前 App 的 Documents 目录，即 `Reports/report.pdf`。

## API

### `FlutterSaveto.save`

```dart
static Future<SaveToResult> save(SaveItemMessage saveItem)
```

把 `saveItem` 描述的本地文件复制到宿主平台对应的位置。

### `SaveItemMessage`

| 字段 | 必填 | 说明 |
| --- | --- | --- |
| `filePath` | 是 | 已存在本地文件的绝对路径。插件不会下载远程 URL。 |
| `mediaType` | 否 | 保存目标分类，默认是 `MediaType.file`。 |
| `mimeType` | 否 | 推荐传入。用于 Android 媒体元数据，以及 `name` 为空时生成文件扩展名。 |
| `name` | 否 | 输出文件名。为空时插件会自动生成。 |
| `saveDirectoryPath` | 否 | 可选子目录，开头和结尾的 `/` 会被裁剪。 |
| `description` | 否 | 消息模型中的保留字段，当前原生实现没有使用。 |

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

| 字段 | 说明 |
| --- | --- |
| `success` | 平台保存操作完成时为 `true`。 |
| `message` | 成功时为空；失败时包含平台错误信息。 |

## iOS 相册权限

当使用 `MediaType.image` 或 `MediaType.video` 保存到系统相册时，iOS 宿主 App 必须在 `ios/Runner/Info.plist` 中声明只添加照片的用途说明：

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save images and videos to your Photos library.</string>
```

只保存、不读取相册内容时使用 `NSPhotoLibraryAddUsageDescription` 即可。除非 App 还需要读取、枚举或选择相册内容，否则不需要额外添加 `NSPhotoLibraryUsageDescription`。

系统权限弹窗读取的是宿主 App `Info.plist` 中的文案。Flutter 插件不能可靠地替宿主 App 注入最终面向用户的用途说明，因此每个 App 应按自己的业务提供文案。

如需本地化权限文案，可以在下面这些文件中声明同一个 key：

- `ios/Runner/en.lproj/InfoPlist.strings`
- `ios/Runner/zh-Hans.lproj/InfoPlist.strings`

示例：

```strings
"NSPhotoLibraryAddUsageDescription" = "需要将图片和视频保存到系统相册。";
```

如果宿主 App 缺少 `NSPhotoLibraryAddUsageDescription`，iOS 实现会返回 `success = false`，并在 `message` 中说明缺少该 key，避免直接触发系统隐私崩溃。

## 错误处理

向用户展示保存成功状态前，应始终检查 `SaveToResult.success`：

```dart
final result = await FlutterSaveto.save(item);

if (result.success) {
  // 保存成功。
} else {
  // 展示或记录 result.message。
}
```

返回的 `message` 可能包含权限拒绝、源文件不存在、目标位置无效或平台 I/O 错误等信息。
