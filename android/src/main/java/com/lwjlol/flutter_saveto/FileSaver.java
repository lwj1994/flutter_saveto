package com.lwjlol.flutter_saveto;

import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.text.format.DateUtils;
import android.webkit.MimeTypeMap;

import androidx.annotation.Nullable;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

class FileSaver {
    final Context context;

    public FileSaver(Context context) {
        this.context = context;
    }

    static String getValidDirPath(String getSaveDirectoryPath) {
        String directoryPath = getSaveDirectoryPath;
        if (directoryPath.startsWith("/")) {
            directoryPath = directoryPath.substring(1);
        }
        if (directoryPath.endsWith("/")) {
            directoryPath = directoryPath.substring(0, directoryPath.length() - 1);
        }
        return directoryPath;
    }

    Messages.SaveToResult save(Messages.SaveItemMessage saveItem) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return save29(saveItem, context);
        }
        Messages.SaveToResult.Builder resultBuilder = new Messages.SaveToResult.Builder();
        resultBuilder.setSuccess(true);
        try {
            long currentTime = System.currentTimeMillis();
            String imageDate =
                    new SimpleDateFormat("yyyyMMdd-HHmmss", Locale.getDefault()).format(new Date(currentTime));
            String extension = MimeTypeMap.getSingleton().getExtensionFromMimeType(saveItem.getMimeType());
            if (extension == null) {
                extension = "";
            }
            String screenshotFileNameTemplate = "%s.$suffix";
            String name = saveItem.getName();
            if (name == null || name.isEmpty()) {
                name = String.format(screenshotFileNameTemplate, imageDate, extension);
            }

            ContentValues contentValues = new ContentValues();
            contentValues.put(MediaStore.MediaColumns.DISPLAY_NAME, name);
            contentValues.put(MediaStore.MediaColumns.TITLE, name);
            if (saveItem.getMimeType() != null && !saveItem.getMimeType().isEmpty()) {
                contentValues.put(MediaStore.MediaColumns.MIME_TYPE, saveItem.getMimeType());
            }
            contentValues.put(MediaStore.MediaColumns.DATE_ADDED, System.currentTimeMillis() / 1000);
            contentValues.put(MediaStore.MediaColumns.DATE_MODIFIED, System.currentTimeMillis() / 1000);
            contentValues.put(
                    MediaStore.MediaColumns.DATE_EXPIRES,
                    (currentTime + DateUtils.DAY_IN_MILLIS) / 1000
            );
            contentValues.put(MediaStore.MediaColumns.IS_PENDING, 1);

            @Nullable
            Uri uri = null;
            switch (saveItem.getMediaType()) {
                case FILE:
                    contentValues.put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS + File.separator + getValidDirPath(saveItem.getSaveDirectoryPath()));
                    uri = MediaStore.Files.getContentUri("external");
                    break;
                case VIDEO:
                    contentValues.put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_MOVIES + File.separator + getValidDirPath(saveItem.getSaveDirectoryPath()));
                    uri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
                    break;
                case IMAGE:
                    contentValues.put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_PICTURES + File.separator + getValidDirPath(saveItem.getSaveDirectoryPath()));
                    uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                    break;
                case AUDIO:
                    contentValues.put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_MUSIC + File.separator + getValidDirPath(saveItem.getSaveDirectoryPath()));
                    uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
                    break;
            }


            if (uri == null) {
                resultBuilder.setMessage("uri == null");
                resultBuilder.setSuccess(false);
            } else {
                context.getContentResolver().insert(uri, contentValues);
                contentValues.clear();
                contentValues.put(MediaStore.MediaColumns.IS_PENDING, 0);
                FileInputStream fileInputStream = null;
                OutputStream outStream = null;
                try {
                    outStream = context.getContentResolver().openOutputStream(uri);
                    fileInputStream = new FileInputStream(saveItem.getFilePath());
                    byte[] buffer = new byte[1024];
                    int count;
                    while ((count = fileInputStream.read(buffer)) > 0) {
                        outStream.write(buffer, 0, count);
                    }

                    contentValues.clear();
                    contentValues.put(MediaStore.MediaColumns.IS_PENDING, 0);
                    contentValues.putNull(MediaStore.MediaColumns.DATE_EXPIRES);
                } catch (Exception e) {
                    resultBuilder.setSuccess(false);
                    resultBuilder.setMessage(e.toString());
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        context.getContentResolver().delete(uri, null);
                    }
                } finally {
                    if (fileInputStream != null) {
                        fileInputStream.close();
                    }
                    if (outStream != null) {
                        outStream.flush();
                        outStream.close();
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

        long currentTime = System.currentTimeMillis();
        String imageDate =
                new SimpleDateFormat("yyyyMMdd-HHmmss", Locale.getDefault()).format(new Date(currentTime));
        String screenshotFileNameTemplate = "%s.$suffix";
        String fileName = saveItem.getName();
        String extension = MimeTypeMap.getSingleton().getExtensionFromMimeType(saveItem.getMimeType());
        if (extension == null) {
            extension = "";
        }
        if (fileName == null || fileName.isEmpty()) {
            fileName = String.format(screenshotFileNameTemplate, imageDate, extension);
        }
        String storePath = "";
        try {
            File originalFile = new File(saveItem.getFilePath());
            switch (saveItem.getMediaType()) {
                case FILE:
                    storePath = Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator + Environment.DIRECTORY_DOWNLOADS + File.separator + getValidDirPath(saveItem.getSaveDirectoryPath());
                    break;
                case VIDEO:
                    storePath = Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator + Environment.DIRECTORY_MOVIES + File.separator + getValidDirPath(saveItem.getSaveDirectoryPath());
                    break;
                case IMAGE:
                    storePath = Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator + Environment.DIRECTORY_PICTURES + File.separator + getValidDirPath(saveItem.getSaveDirectoryPath());
                    break;
                case AUDIO:
                    storePath = Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator + Environment.DIRECTORY_MUSIC + File.separator + getValidDirPath(saveItem.getSaveDirectoryPath());
                    break;
            }
            File appDir = new File(storePath);
            if (!appDir.exists()) {
                appDir.mkdirs();
            }
            Uri uri = Uri.fromFile(new File(appDir, fileName));


            OutputStream outputStream = null;
            FileInputStream fileInputStream = null;

            try {
                outputStream = context.getContentResolver().openOutputStream(uri);
                fileInputStream = new FileInputStream(originalFile);
                byte[] buffer = new byte[1024];
                int count;
                while ((count = fileInputStream.read(buffer)) > 0) {
                    outputStream.write(buffer, 0, count);
                }
            } catch (Exception e) {
                resultBuilder.setSuccess(false);
                resultBuilder.setMessage(e.toString());
            } finally {
                if (outputStream != null) {
                    outputStream.flush();
                    outputStream.close();
                }
                if (fileInputStream != null) {
                    fileInputStream.close();
                }
            }
            context.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri));
        } catch (IOException e) {
            resultBuilder.setSuccess(false);
            resultBuilder.setMessage(e.toString());
        }

        return resultBuilder.build();
    }


    private String getMIMEType(String extension) {
        String type = null;
        if (!TextUtils.isEmpty(extension)) {
            type = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension.toLowerCase());
        }
        return type;
    }
}
