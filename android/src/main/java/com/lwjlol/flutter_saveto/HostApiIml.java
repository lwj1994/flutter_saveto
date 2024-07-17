package com.lwjlol.flutter_saveto;

import androidx.annotation.NonNull;

class HostApiIml implements Messages.SaveToHostApi {
    final FileSaver saver;

    public HostApiIml(FileSaver saver) {
        this.saver = saver;
    }

    @Override
    public void save(@NonNull Messages.SaveItemMessage saveItem, @NonNull Messages.Result<Messages.SaveToResult> result) {
        Messages.SaveToResult saveToResult = saver.save(saveItem);
        result.success(saveToResult);
    }
}
