package com.lwjlol.flutter_saveto;

import android.content.Intent;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry;

public class FlutterSavetoPlugin implements FlutterPlugin, ActivityAware {
    private ActivityPluginBinding activityPluginBinding;
    private final PluginRegistry.NewIntentListener onNewIntent = new PluginRegistry.NewIntentListener() {
        @Override
        public boolean onNewIntent(Intent intent) {
            return false;
        }
    };

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        Messages.SaveToHostApi.setUp(
                binding.getBinaryMessenger(),
                new HostApiIml(
                        new FileSaver(
                                binding.getApplicationContext()
                        )
                )
        );
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        activityPluginBinding = binding;
        activityPluginBinding.addOnNewIntentListener(onNewIntent);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    }

    @Override
    public void onDetachedFromActivity() {
        activityPluginBinding.removeOnNewIntentListener(onNewIntent);
        activityPluginBinding = null;
    }
}
