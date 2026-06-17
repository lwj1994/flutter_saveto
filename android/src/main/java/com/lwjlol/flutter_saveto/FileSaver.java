package com.lwjlol.flutter_saveto;

import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.text.format.DateUtils;
import android.webkit.MimeTypeMap;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

class FileSaver {
    private static final int COPY_BUFFER_SIZE = 1024 * 1024;

    final Context context;

    public FileSaver(Context context) {
        this.context = context;
    }

    static String getValidDirPath(String saveDirectoryPath) {
        String directoryPath = saveDirectoryPath == null ? "" : saveDirectoryPath.trim().replace('\\', '/');
        while (directoryPath.startsWith("/")) {
            directoryPath = directoryPath.substring(1);
        }
        while (directoryPath.endsWith("/")) {
            directoryPath = directoryPath.substring(0, directoryPath.length() - 1);
        }

        if (directoryPath.isEmpty()) {
            return "";
        }

        StringBuilder normalized = new StringBuilder();
        String[] segments = directoryPath.split("/");
        for (String segment : segments) {
            if (segment.isEmpty() || segment.equals(".") || segment.equals("..") || segment.indexOf('\0') >= 0) {
                throw new IllegalArgumentException("Invalid saveDirectoryPath: " + saveDirectoryPath);
            }
            if (normalized.length() > 0) {
                normalized.append(File.separator);
            }
            normalized.append(segment);
        }
        return normalized.toString();
    }

    Messages.SaveToResult save(Messages.SaveItemMessage saveItem) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return save29(saveItem, context);
        }

        Messages.SaveToResult.Builder resultBuilder = new Messages.SaveToResult.Builder();
        resultBuilder.setSuccess(true);
        resultBuilder.setMessage("");
        try {
            File sourceFile = getReadableSourceFile(saveItem.getFilePath());
            String relativePath = getValidDirPath(saveItem.getSaveDirectoryPath());
            long currentTime = System.currentTimeMillis();
            String imageDate = new SimpleDateFormat("yyyyMMdd-HHmmss", Locale.getDefault()).format(new Date(currentTime));
            String name = resolveFileName(saveItem, imageDate);

            ContentValues contentValues = new ContentValues();
            contentValues.put(MediaStore.MediaColumns.DISPLAY_NAME, name);
            contentValues.put(MediaStore.MediaColumns.TITLE, name);
            if (saveItem.getMimeType() != null && !saveItem.getMimeType().isEmpty()) {
                contentValues.put(MediaStore.MediaColumns.MIME_TYPE, saveItem.getMimeType());
            }
            contentValues.put(MediaStore.MediaColumns.DATE_ADDED, System.currentTimeMillis() / 1000);
            contentValues.put(MediaStore.MediaColumns.DATE_MODIFIED, System.currentTimeMillis() / 1000);
            contentValues.put(MediaStore.MediaColumns.DATE_EXPIRES, (currentTime + DateUtils.DAY_IN_MILLIS) / 1000);
            contentValues.put(MediaStore.MediaColumns.IS_PENDING, 1);

            Uri collectionUri = null;
            switch (saveItem.getMediaType()) {
                case FILE:
                    contentValues.put(MediaStore.MediaColumns.RELATIVE_PATH, appendRelativePath(Environment.DIRECTORY_DOWNLOADS, relativePath));
                    collectionUri = MediaStore.Downloads.EXTERNAL_CONTENT_URI;
                    break;
                case VIDEO:
                    contentValues.put(MediaStore.MediaColumns.RELATIVE_PATH, appendRelativePath(Environment.DIRECTORY_MOVIES, relativePath));
                    collectionUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
                    break;
                case IMAGE:
                    contentValues.put(MediaStore.MediaColumns.RELATIVE_PATH, appendRelativePath(Environment.DIRECTORY_PICTURES, relativePath));
                    collectionUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                    break;
                case AUDIO:
                    contentValues.put(MediaStore.MediaColumns.RELATIVE_PATH, appendRelativePath(Environment.DIRECTORY_MUSIC, relativePath));
                    collectionUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
                    break;
            }

            if (collectionUri == null) {
                resultBuilder.setMessage("uri == null");
                resultBuilder.setSuccess(false);
            } else {
                Uri itemUri = context.getContentResolver().insert(collectionUri, contentValues);
                if (itemUri == null) {
                    resultBuilder.setSuccess(false);
                    resultBuilder.setMessage("Failed to create MediaStore record.");
                } else {
                    try (OutputStream outStream = context.getContentResolver().openOutputStream(itemUri)) {
                        if (outStream == null) {
                            throw new IOException("Failed to open destination stream.");
                        }
                        copyFile(sourceFile, outStream);

                        contentValues.clear();
                        contentValues.put(MediaStore.MediaColumns.IS_PENDING, 0);
                        contentValues.putNull(MediaStore.MediaColumns.DATE_EXPIRES);
                        context.getContentResolver().update(itemUri, contentValues, null, null);
                    } catch (Exception e) {
                        deleteUriQuietly(itemUri);
                        resultBuilder.setSuccess(false);
                        resultBuilder.setMessage(e.toString());
                    }
                }
            }
        } catch (Exception e) {
            resultBuilder.setSuccess(false);
            resultBuilder.setMessage(e.toString());
        }

        return resultBuilder.build();
    }

    private Messages.SaveToResult save29(Messages.SaveItemMessage saveItem, Context context) {
        Messages.SaveToResult.Builder resultBuilder = new Messages.SaveToResult.Builder();
        resultBuilder.setSuccess(true);
        resultBuilder.setMessage("");

        long currentTime = System.currentTimeMillis();
        String imageDate = new SimpleDateFormat("yyyyMMdd-HHmmss", Locale.getDefault()).format(new Date(currentTime));
        try {
            File originalFile = getReadableSourceFile(saveItem.getFilePath());
            String relativePath = getValidDirPath(saveItem.getSaveDirectoryPath());
            String fileName = resolveFileName(saveItem, imageDate);
            File baseDirectory = null;
            switch (saveItem.getMediaType()) {
                case FILE:
                    baseDirectory = new File(Environment.getExternalStorageDirectory(), Environment.DIRECTORY_DOWNLOADS);
                    break;
                case VIDEO:
                    baseDirectory = new File(Environment.getExternalStorageDirectory(), Environment.DIRECTORY_MOVIES);
                    break;
                case IMAGE:
                    baseDirectory = new File(Environment.getExternalStorageDirectory(), Environment.DIRECTORY_PICTURES);
                    break;
                case AUDIO:
                    baseDirectory = new File(Environment.getExternalStorageDirectory(), Environment.DIRECTORY_MUSIC);
                    break;
            }
            if (baseDirectory == null) {
                throw new IOException("Unsupported media type.");
            }

            File appDir = relativePath.isEmpty() ? baseDirectory : new File(baseDirectory, relativePath);
            File destinationFile = new File(appDir, fileName);
            ensureWithinDirectory(baseDirectory, destinationFile);

            if (!appDir.exists() && !appDir.mkdirs()) {
                throw new IOException("Failed to create directory: " + appDir.getAbsolutePath());
            }

            try (OutputStream outputStream = new FileOutputStream(destinationFile)) {
                copyFile(originalFile, outputStream);
            }
            context.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.fromFile(destinationFile)));
        } catch (Exception e) {
            resultBuilder.setSuccess(false);
            resultBuilder.setMessage(e.toString());
        }

        return resultBuilder.build();
    }

    private static File getReadableSourceFile(String filePath) throws IOException {
        File sourceFile = new File(filePath);
        if (!sourceFile.exists() || !sourceFile.isFile()) {
            throw new IOException("Source file not found: " + filePath);
        }
        return sourceFile;
    }

    private static String resolveFileName(Messages.SaveItemMessage saveItem, String timestamp) {
        String fileName = getValidFileName(saveItem.getName());
        if (fileName != null) {
            return fileName;
        }

        String extension = getFileExtension(saveItem);
        return extension.isEmpty() ? timestamp : timestamp + "." + extension;
    }

    private static String getValidFileName(String rawFileName) {
        if (rawFileName == null || rawFileName.trim().isEmpty()) {
            return null;
        }
        if (rawFileName.contains("/") || rawFileName.contains("\\") || rawFileName.indexOf('\0') >= 0
                || rawFileName.equals(".") || rawFileName.equals("..")) {
            throw new IllegalArgumentException("Invalid file name: " + rawFileName);
        }
        return rawFileName;
    }

    private static String getFileExtension(Messages.SaveItemMessage saveItem) {
        String mimeType = saveItem.getMimeType();
        if (mimeType != null && !mimeType.isEmpty()) {
            String extension = MimeTypeMap.getSingleton().getExtensionFromMimeType(mimeType);
            if (extension != null && !extension.isEmpty()) {
                return extension;
            }
        }

        switch (saveItem.getMediaType()) {
            case AUDIO:
                return "aac";
            case VIDEO:
                return "mp4";
            case IMAGE:
                return "png";
            case FILE:
            default:
                return "bin";
        }
    }

    private static String appendRelativePath(String baseDirectory, String relativePath) {
        return relativePath.isEmpty() ? baseDirectory : baseDirectory + File.separator + relativePath;
    }

    private static void copyFile(File sourceFile, OutputStream outputStream) throws IOException {
        try (FileInputStream fileInputStream = new FileInputStream(sourceFile)) {
            byte[] buffer = new byte[COPY_BUFFER_SIZE];
            int count;
            while ((count = fileInputStream.read(buffer)) > 0) {
                outputStream.write(buffer, 0, count);
            }
            outputStream.flush();
        }
    }

    private void deleteUriQuietly(Uri uri) {
        try {
            context.getContentResolver().delete(uri, null, null);
        } catch (Exception ignored) {
        }
    }

    private static void ensureWithinDirectory(File baseDirectory, File destinationFile) throws IOException {
        String basePath = baseDirectory.getCanonicalPath();
        String destinationPath = destinationFile.getCanonicalPath();
        if (!destinationPath.equals(basePath) && !destinationPath.startsWith(basePath + File.separator)) {
            throw new IOException("Invalid destination path.");
        }
    }
}
