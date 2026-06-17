package com.lwjlol.flutter_saveto;

import android.content.Intent;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry;

public class FlutterSavetoPlugin implements FlutterPlugin, ActivityAware {
    private ActivityPluginBinding activityPluginBinding;
    private HostApiIml hostApi;
    private final PluginRegistry.NewIntentListener onNewIntent = new PluginRegistry.NewIntentListener() {
        @Override
        public boolean onNewIntent(Intent intent) {
            return false;
        }
    };

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        hostApi = new HostApiIml(
                new FileSaver(
                        binding.getApplicationContext()
                )
        );
        Messages.SaveToHostApi.setUp(
                binding.getBinaryMessenger(),
                hostApi
        );
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        Messages.SaveToHostApi.setUp(binding.getBinaryMessenger(), null);
        if (hostApi != null) {
            hostApi.shutdown();
            hostApi = null;
        }
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
        if (activityPluginBinding != null) {
            activityPluginBinding.removeOnNewIntentListener(onNewIntent);
        }
        activityPluginBinding = null;
    }
}
