package com.pisey.flutter_native_player

import com.pisey.flutter_native_player.constants.Constant
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel


class PlayerMethodManager {

    fun methodChannel(binaryMessage:BinaryMessenger,handler: MethodChannel.MethodCallHandler){
        MethodChannel(binaryMessage, Constant.METHOD_CHANNEL_PLAYER).setMethodCallHandler(handler)
    }

    fun eventChannel(binaryMessage: BinaryMessenger,handler: EventChannel.StreamHandler){
        EventChannel(binaryMessage, Constant.EVENT_CHANNEL_PLAYER).setStreamHandler(handler)
    }
}