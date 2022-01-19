//
//  PlayerMethodManager.swift
//  Runner
//
//  Created by nguon pisey on 3/8/21.
//

import Foundation

class PlayerMethodManager {
    
    func methodChannel(binaryMessenger:FlutterBinaryMessenger,handler:@escaping FlutterMethodCallHandler){
        let methodChannelPlayer = FlutterMethodChannel(name: Constant.METHOD_CHANNEL_PLAYER,binaryMessenger:binaryMessenger)
        methodChannelPlayer.setMethodCallHandler(handler)
    }
    
    func eventChannelPlayer(binaryMessenger:FlutterBinaryMessenger,handler:(FlutterStreamHandler & NSObjectProtocol)?){
        let eventChannelPlayer = FlutterEventChannel(name: Constant.EVENT_CHANNEL_PLAYER, binaryMessenger: binaryMessenger)
        eventChannelPlayer.setStreamHandler(handler)
    }

}
