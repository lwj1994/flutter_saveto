package com.lwjlol.flutter_saveto;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

class HostApiIml implements Messages.SaveToHostApi {
    final FileSaver saver;
    private final ExecutorService executor = Executors.newSingleThreadExecutor();
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    public HostApiIml(FileSaver saver) {
        this.saver = saver;
    }

    @Override
    public void save(@NonNull Messages.SaveItemMessage saveItem, @NonNull Messages.Result<Messages.SaveToResult> result) {
        executor.execute(() -> {
            Messages.SaveToResult saveToResult = saver.save(saveItem);
            mainHandler.post(() -> result.success(saveToResult));
        });
    }

    void shutdown() {
        executor.shutdown();
    }
}
