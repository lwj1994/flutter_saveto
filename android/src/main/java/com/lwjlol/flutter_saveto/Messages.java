// Copyright 2024 EchoTech. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v20.0.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon

package com.lwjlol.flutter_saveto;

import static java.lang.annotation.ElementType.METHOD;
import static java.lang.annotation.RetentionPolicy.CLASS;

import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.common.StandardMessageCodec;
import java.io.ByteArrayOutputStream;
import java.lang.annotation.Retention;
import java.lang.annotation.Target;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Generated class from Pigeon. */
@SuppressWarnings({"unused", "unchecked", "CodeBlock2Expr", "RedundantSuppression", "serial"})
public class Messages {

  /** Error class for passing custom error details to Flutter via a thrown PlatformException. */
  public static class FlutterError extends RuntimeException {

    /** The error code. */
    public final String code;

    /** The error details. Must be a datatype supported by the api codec. */
    public final Object details;

    public FlutterError(@NonNull String code, @Nullable String message, @Nullable Object details) 
    {
      super(message);
      this.code = code;
      this.details = details;
    }
  }

  @NonNull
  protected static ArrayList<Object> wrapError(@NonNull Throwable exception) {
    ArrayList<Object> errorList = new ArrayList<Object>(3);
    if (exception instanceof FlutterError) {
      FlutterError error = (FlutterError) exception;
      errorList.add(error.code);
      errorList.add(error.getMessage());
      errorList.add(error.details);
    } else {
      errorList.add(exception.toString());
      errorList.add(exception.getClass().getSimpleName());
      errorList.add(
        "Cause: " + exception.getCause() + ", Stacktrace: " + Log.getStackTraceString(exception));
    }
    return errorList;
  }

  @Target(METHOD)
  @Retention(CLASS)
  @interface CanIgnoreReturnValue {}

  public enum MediaType {
    AUDIO(0),
    FILE(1),
    VIDEO(2),
    IMAGE(3);

    final int index;

    private MediaType(final int index) {
      this.index = index;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static final class SaveItemMessage {
    private @NonNull MediaType mediaType;

    public @NonNull MediaType getMediaType() {
      return mediaType;
    }

    public void setMediaType(@NonNull MediaType setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"mediaType\" is null.");
      }
      this.mediaType = setterArg;
    }

    private @Nullable String name;

    public @Nullable String getName() {
      return name;
    }

    public void setName(@Nullable String setterArg) {
      this.name = setterArg;
    }

    private @NonNull String filePath;

    public @NonNull String getFilePath() {
      return filePath;
    }

    public void setFilePath(@NonNull String setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"filePath\" is null.");
      }
      this.filePath = setterArg;
    }

    private @NonNull String saveDirectoryPath;

    public @NonNull String getSaveDirectoryPath() {
      return saveDirectoryPath;
    }

    public void setSaveDirectoryPath(@NonNull String setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"saveDirectoryPath\" is null.");
      }
      this.saveDirectoryPath = setterArg;
    }

    private @Nullable String description;

    public @Nullable String getDescription() {
      return description;
    }

    public void setDescription(@Nullable String setterArg) {
      this.description = setterArg;
    }

    private @Nullable String mimeType;

    public @Nullable String getMimeType() {
      return mimeType;
    }

    public void setMimeType(@Nullable String setterArg) {
      this.mimeType = setterArg;
    }

    /** Constructor is non-public to enforce null safety; use Builder. */
    SaveItemMessage() {}

    public static final class Builder {

      private @Nullable MediaType mediaType;

      @CanIgnoreReturnValue
      public @NonNull Builder setMediaType(@NonNull MediaType setterArg) {
        this.mediaType = setterArg;
        return this;
      }

      private @Nullable String name;

      @CanIgnoreReturnValue
      public @NonNull Builder setName(@Nullable String setterArg) {
        this.name = setterArg;
        return this;
      }

      private @Nullable String filePath;

      @CanIgnoreReturnValue
      public @NonNull Builder setFilePath(@NonNull String setterArg) {
        this.filePath = setterArg;
        return this;
      }

      private @Nullable String saveDirectoryPath;

      @CanIgnoreReturnValue
      public @NonNull Builder setSaveDirectoryPath(@NonNull String setterArg) {
        this.saveDirectoryPath = setterArg;
        return this;
      }

      private @Nullable String description;

      @CanIgnoreReturnValue
      public @NonNull Builder setDescription(@Nullable String setterArg) {
        this.description = setterArg;
        return this;
      }

      private @Nullable String mimeType;

      @CanIgnoreReturnValue
      public @NonNull Builder setMimeType(@Nullable String setterArg) {
        this.mimeType = setterArg;
        return this;
      }

      public @NonNull SaveItemMessage build() {
        SaveItemMessage pigeonReturn = new SaveItemMessage();
        pigeonReturn.setMediaType(mediaType);
        pigeonReturn.setName(name);
        pigeonReturn.setFilePath(filePath);
        pigeonReturn.setSaveDirectoryPath(saveDirectoryPath);
        pigeonReturn.setDescription(description);
        pigeonReturn.setMimeType(mimeType);
        return pigeonReturn;
      }
    }

    @NonNull
    ArrayList<Object> toList() {
      ArrayList<Object> toListResult = new ArrayList<Object>(6);
      toListResult.add(mediaType);
      toListResult.add(name);
      toListResult.add(filePath);
      toListResult.add(saveDirectoryPath);
      toListResult.add(description);
      toListResult.add(mimeType);
      return toListResult;
    }

    static @NonNull SaveItemMessage fromList(@NonNull ArrayList<Object> __pigeon_list) {
      SaveItemMessage pigeonResult = new SaveItemMessage();
      Object mediaType = __pigeon_list.get(0);
      pigeonResult.setMediaType((MediaType) mediaType);
      Object name = __pigeon_list.get(1);
      pigeonResult.setName((String) name);
      Object filePath = __pigeon_list.get(2);
      pigeonResult.setFilePath((String) filePath);
      Object saveDirectoryPath = __pigeon_list.get(3);
      pigeonResult.setSaveDirectoryPath((String) saveDirectoryPath);
      Object description = __pigeon_list.get(4);
      pigeonResult.setDescription((String) description);
      Object mimeType = __pigeon_list.get(5);
      pigeonResult.setMimeType((String) mimeType);
      return pigeonResult;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static final class SaveToResult {
    private @NonNull Boolean success;

    public @NonNull Boolean getSuccess() {
      return success;
    }

    public void setSuccess(@NonNull Boolean setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"success\" is null.");
      }
      this.success = setterArg;
    }

    private @NonNull String message;

    public @NonNull String getMessage() {
      return message;
    }

    public void setMessage(@NonNull String setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"message\" is null.");
      }
      this.message = setterArg;
    }

    /** Constructor is non-public to enforce null safety; use Builder. */
    SaveToResult() {}

    public static final class Builder {

      private @Nullable Boolean success;

      @CanIgnoreReturnValue
      public @NonNull Builder setSuccess(@NonNull Boolean setterArg) {
        this.success = setterArg;
        return this;
      }

      private @Nullable String message;

      @CanIgnoreReturnValue
      public @NonNull Builder setMessage(@NonNull String setterArg) {
        this.message = setterArg;
        return this;
      }

      public @NonNull SaveToResult build() {
        SaveToResult pigeonReturn = new SaveToResult();
        pigeonReturn.setSuccess(success);
        pigeonReturn.setMessage(message);
        return pigeonReturn;
      }
    }

    @NonNull
    ArrayList<Object> toList() {
      ArrayList<Object> toListResult = new ArrayList<Object>(2);
      toListResult.add(success);
      toListResult.add(message);
      return toListResult;
    }

    static @NonNull SaveToResult fromList(@NonNull ArrayList<Object> __pigeon_list) {
      SaveToResult pigeonResult = new SaveToResult();
      Object success = __pigeon_list.get(0);
      pigeonResult.setSuccess((Boolean) success);
      Object message = __pigeon_list.get(1);
      pigeonResult.setMessage((String) message);
      return pigeonResult;
    }
  }

  private static class PigeonCodec extends StandardMessageCodec {
    public static final PigeonCodec INSTANCE = new PigeonCodec();

    private PigeonCodec() {}

    @Override
    protected Object readValueOfType(byte type, @NonNull ByteBuffer buffer) {
      switch (type) {
        case (byte) 129:
          return SaveItemMessage.fromList((ArrayList<Object>) readValue(buffer));
        case (byte) 130:
          return SaveToResult.fromList((ArrayList<Object>) readValue(buffer));
        case (byte) 131:
          Object value = readValue(buffer);
          return value == null ? null : MediaType.values()[(int) value];
        default:
          return super.readValueOfType(type, buffer);
      }
    }

    @Override
    protected void writeValue(@NonNull ByteArrayOutputStream stream, Object value) {
      if (value instanceof SaveItemMessage) {
        stream.write(129);
        writeValue(stream, ((SaveItemMessage) value).toList());
      } else if (value instanceof SaveToResult) {
        stream.write(130);
        writeValue(stream, ((SaveToResult) value).toList());
      } else if (value instanceof MediaType) {
        stream.write(131);
        writeValue(stream, value == null ? null : ((MediaType) value).index);
      } else {
        super.writeValue(stream, value);
      }
    }
  }


  /** Asynchronous error handling return type for non-nullable API method returns. */
  public interface Result<T> {
    /** Success case callback method for handling returns. */
    void success(@NonNull T result);

    /** Failure case callback method for handling errors. */
    void error(@NonNull Throwable error);
  }
  /** Asynchronous error handling return type for nullable API method returns. */
  public interface NullableResult<T> {
    /** Success case callback method for handling returns. */
    void success(@Nullable T result);

    /** Failure case callback method for handling errors. */
    void error(@NonNull Throwable error);
  }
  /** Asynchronous error handling return type for void API method returns. */
  public interface VoidResult {
    /** Success case callback method for handling returns. */
    void success();

    /** Failure case callback method for handling errors. */
    void error(@NonNull Throwable error);
  }
  /** Generated interface from Pigeon that represents a handler of messages from Flutter. */
  public interface SaveToHostApi {

    void save(@NonNull SaveItemMessage saveItem, @NonNull Result<SaveToResult> result);

    /** The codec used by SaveToHostApi. */
    static @NonNull MessageCodec<Object> getCodec() {
      return PigeonCodec.INSTANCE;
    }
    /**Sets up an instance of `SaveToHostApi` to handle messages through the `binaryMessenger`. */
    static void setUp(@NonNull BinaryMessenger binaryMessenger, @Nullable SaveToHostApi api) {
      setUp(binaryMessenger, "", api);
    }
    static void setUp(@NonNull BinaryMessenger binaryMessenger, @NonNull String messageChannelSuffix, @Nullable SaveToHostApi api) {
      messageChannelSuffix = messageChannelSuffix.isEmpty() ? "" : "." + messageChannelSuffix;
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger, "dev.flutter.pigeon.flutter_saveto.SaveToHostApi.save" + messageChannelSuffix, getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                ArrayList<Object> wrapped = new ArrayList<Object>();
                ArrayList<Object> args = (ArrayList<Object>) message;
                SaveItemMessage saveItemArg = (SaveItemMessage) args.get(0);
                Result<SaveToResult> resultCallback =
                    new Result<SaveToResult>() {
                      public void success(SaveToResult result) {
                        wrapped.add(0, result);
                        reply.reply(wrapped);
                      }

                      public void error(Throwable error) {
                        ArrayList<Object> wrappedError = wrapError(error);
                        reply.reply(wrappedError);
                      }
                    };

                api.save(saveItemArg, resultCallback);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
    }
  }
}
