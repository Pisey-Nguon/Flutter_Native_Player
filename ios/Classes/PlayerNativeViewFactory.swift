//
//  PlayerNativeViewFactory.swift
//  Runner
//
//  Created by nguon pisey on 2/8/21.
//
import Foundation
import Flutter

class PlayerNativeViewFactory: NSObject,FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    init(messenger:FlutterBinaryMessenger) {
        self.messenger = messenger
    }
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return PlayerNativeView(frame,viewID: viewId,messenger: messenger,args: args)
    }
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
