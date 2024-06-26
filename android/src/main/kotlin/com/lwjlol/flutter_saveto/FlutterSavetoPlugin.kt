package com.lwjlol.flutter_saveto

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry


class FlutterSavetoPlugin : FlutterPlugin, ActivityAware {
    private var activityPluginBinding: ActivityPluginBinding? = null
    private val onNewIntent = PluginRegistry.NewIntentListener {
        return@NewIntentListener false
    }


    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Messages.SaveToHostApi.setUp(
            binding.binaryMessenger,
            HostApiIml(FileSaver(binding.applicationContext)),
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        activityPluginBinding?.addOnNewIntentListener(onNewIntent)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

    }

    override fun onDetachedFromActivity() {
        activityPluginBinding?.removeOnNewIntentListener(onNewIntent);
        activityPluginBinding = null
    }
}