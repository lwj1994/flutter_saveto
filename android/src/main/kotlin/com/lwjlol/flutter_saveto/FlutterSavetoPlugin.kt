package com.lwjlol.flutter_saveto

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterSavetoPlugin */
class FlutterSavetoPlugin2: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_saveto")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}



private class SaveToHostApiImp : SaveToHostApi {

  override fun save(saveItem: SaveItemMessage): Boolean {
    return true;
  }
}

class FlutterSavetoPlugin : FlutterPlugin, ActivityAware {
  companion object {

  }

  private var activityPluginBinding: ActivityPluginBinding? = null
  private val onNewIntent = PluginRegistry.NewIntentListener {
    return@NewIntentListener false
  }


  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    SaveToHostApi.setUp(
      binaryMessenger = binding.binaryMessenger,
      api = SaveToHostApiImp(),
    )
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
  }


  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activityPluginBinding = binding
    activityPluginBinding?.addOnNewIntentListener(onNewIntent)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    Log.i("CongressPlugin", "onDetachedFromActivityForConfigChanges")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

  }

  override fun onDetachedFromActivity() {
    activityPluginBinding?.removeOnNewIntentListener(onNewIntent);
    activityPluginBinding = null
  }


}

