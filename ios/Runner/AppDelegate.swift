import Flutter
import UIKit
import CoreBluetooth

@main
@objc class AppDelegate: FlutterAppDelegate, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager!
    private var methodChannel: FlutterMethodChannel!
    private var discoveredDevices: [CBPeripheral] = []

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

        methodChannel = FlutterMethodChannel(name: "com.jboycode/platforms",
                                           binaryMessenger: controller.binaryMessenger)

        centralManager = CBCentralManager(delegate: self, queue: nil)

        methodChannel.setMethodCallHandler { [weak self]
            (call, result) in
            switch call.method {
            case "startScan":
                self?.startScan()
                result(nil)
            case "stopScan":
                self?.stopScan()
                result(nil)
            case "getDevices":
                let devices = self?.discoveredDevices.map {
                    ["name": $0.name ?? "Unknown", "id": $0.identifier.uuidString]
                }
                result(devices)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // CBCentralManagerDelegate methods
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            methodChannel.invokeMethod("bluetoothState", arguments: "on")
        case .poweredOff:
            methodChannel.invokeMethod("bluetoothState", arguments: "off")
        default:
            methodChannel.invokeMethod("bluetoothState", arguments: "unavailable")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredDevices.contains(peripheral) {
            discoveredDevices.append(peripheral)
            let deviceInfo = ["name": peripheral.name ?? "Unknown", "id": peripheral.identifier.uuidString]
            methodChannel.invokeMethod("deviceFound", arguments: deviceInfo)
        }
    }

    private func startScan() {
        discoveredDevices.removeAll()
        centralManager.scanForPeripherals(withServices: nil)
    }

    private func stopScan() {
        centralManager.stopScan()
    }
}