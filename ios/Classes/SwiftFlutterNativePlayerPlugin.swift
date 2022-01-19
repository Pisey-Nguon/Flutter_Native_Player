import Flutter
import UIKit

public class SwiftFlutterNativePlayerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
//    let channel = FlutterMethodChannel(name: "flutter_native_player", binaryMessenger: registrar.messenger())
//    let instance = SwiftFlutterNativePlayerPlugin()
//    registrar.addMethodCallDelegate(instance, channel: channel)
      
      registrar.register(PlayerNativeViewFactory(messenger: registrar.messenger()), withId: Constant.MP_VIEW_TYPE)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
