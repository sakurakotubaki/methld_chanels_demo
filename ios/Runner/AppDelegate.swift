import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let METHOD_CHANNEL = "com.jboycode/weight_scale/method"
    private let EVENT_CHANNEL = "com.jboycode/weight_scale/event"
    private var weightTimer: Timer?
    private var isScaleOn = false
    private var currentWeight = 60.0
    private var isIncreasing = true
    // eventSinkをinternalにして、同じモジュール内からアクセス可能に
    var eventSink: FlutterEventSink?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        // Method Channel setup
        let methodChannel = FlutterMethodChannel(
            name: METHOD_CHANNEL,
            binaryMessenger: controller.binaryMessenger)
        
        methodChannel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            
            if call.method == "toggleScale" {
                if let args = call.arguments as? Bool {
                    self.isScaleOn = args
                    if self.isScaleOn {
                        self.startWeightSimulation()
                    } else {
                        self.stopWeightSimulation()
                    }
                    result(self.isScaleOn)
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        // Event Channel setup
        let eventChannel = FlutterEventChannel(
            name: EVENT_CHANNEL,
            binaryMessenger: controller.binaryMessenger)
        
        eventChannel.setStreamHandler(WeightStreamHandler(delegate: self))
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func startWeightSimulation() {
        print("Starting weight simulation")
        weightTimer?.invalidate()
        
        weightTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isScaleOn else { return }
            
            if self.isIncreasing {
                self.currentWeight += 0.5
                if self.currentWeight >= 70.0 {
                    self.isIncreasing = false
                }
            } else {
                self.currentWeight -= 0.5
                if self.currentWeight <= 50.0 {
                    self.isIncreasing = true
                }
            }
            
            DispatchQueue.main.async {
                print("Sending weight: \(self.currentWeight)")
                self.eventSink?(self.currentWeight)
            }
        }
    }
    
    func stopWeightSimulation() {
        print("Stopping weight simulation")
        weightTimer?.invalidate()
        weightTimer = nil
    }
}

// Stream Handler Class
class WeightStreamHandler: NSObject, FlutterStreamHandler {
    private weak var delegate: AppDelegate?
    
    init(delegate: AppDelegate) {
        self.delegate = delegate
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("EventChannel onListen called")
        delegate?.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("EventChannel onCancel called")
        delegate?.eventSink = nil
        return nil
    }
}
