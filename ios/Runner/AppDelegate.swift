import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    
    let methodChannel =
        FlutterMethodChannel(name: "com.jboycode/platforms",
                                                      binaryMessenger: controller.binaryMessenger)
    
        methodChannel.setMethodCallHandler{
            (call, result) in
            if call.method == "callNative"{
                let message = "👻 Hello From IOS Native"
                result(message)
            }
        }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
