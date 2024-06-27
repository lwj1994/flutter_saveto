package com.lwjlol.flutter_saveto;

import androidx.annotation.NonNull;

class HostApiIml implements Messages.SaveToHostApi {
    final FileSaver saver;

    public HostApiIml(FileSaver saver) {
        this.saver = saver;
    }

    @NonNull
    @Override
    public Messages.SaveToResult save(@NonNull Messages.SaveItemMessage saveItem) {
        return saver.save(saveItem);
    }
}
