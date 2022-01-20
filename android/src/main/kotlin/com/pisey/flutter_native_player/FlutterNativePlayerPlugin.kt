package com.pisey.flutter_native_player

import androidx.annotation.NonNull
import com.pisey.flutter_native_player.constants.Constant

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterNativePlayerPlugin */
class FlutterNativePlayerPlugin: FlutterPlugin{

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    /// The flutterPluginBinding.binaryMessenger that will the communication between Flutter and native Android
    flutterPluginBinding.platformViewRegistry.registerViewFactory(Constant.MP_VIEW_TYPE,PlayerNativeViewFactory(flutterPluginBinding.binaryMessenger))
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
