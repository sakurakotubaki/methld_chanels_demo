package com.jboycode.methld_chanels_demo

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.le.BluetoothLeScanner
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val channel = "com.jboycode/platforms"
    private lateinit var methodChannel: MethodChannel
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var bluetoothLeScanner: BluetoothLeScanner? = null
    private var isScanning = false

    private val PERMISSION_REQUEST_CODE = 123
    private val requiredPermissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        arrayOf(
            Manifest.permission.BLUETOOTH_SCAN,
            Manifest.permission.BLUETOOTH_CONNECT,
            Manifest.permission.ACCESS_FINE_LOCATION
        )
    } else {
        arrayOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.BLUETOOTH,
            Manifest.permission.BLUETOOTH_ADMIN
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // BluetoothManagerの初期化
        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothAdapter = bluetoothManager.adapter
        bluetoothLeScanner = bluetoothAdapter?.bluetoothLeScanner

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "callNative" -> {
                    result.success("Android ${android.os.Build.VERSION.RELEASE}")
                }
                "startScan" -> {
                    if (checkPermissions()) {
                        startScan()
                        result.success(null)
                    } else {
                        requestPermissions()
                        result.error(
                            "PERMISSION_DENIED",
                            "BLE permissions not granted",
                            null
                        )
                    }
                }
                "stopScan" -> {
                    stopScan()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkPermissions(): Boolean {
        return requiredPermissions.all {
            ContextCompat.checkSelfPermission(this, it) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun requestPermissions() {
        ActivityCompat.requestPermissions(this, requiredPermissions, PERMISSION_REQUEST_CODE)
    }

    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult) {
            val device = result.device
            val deviceInfo = mapOf(
                "name" to (device.name ?: "Unknown"),
                "id" to device.address,
                "rssi" to result.rssi
            )
            runOnUiThread {
                methodChannel.invokeMethod("deviceFound", deviceInfo)
            }
        }

        override fun onScanFailed(errorCode: Int) {
            super.onScanFailed(errorCode)
            runOnUiThread {
                methodChannel.invokeMethod("scanError", "Scan failed with error code: $errorCode")
            }
        }
    }

    private fun startScan() {
        if (!isScanning && checkPermissions()) {
            bluetoothLeScanner?.startScan(scanCallback)
            isScanning = true
            methodChannel.invokeMethod("bluetoothState", "on")
        }
    }

    private fun stopScan() {
        if (isScanning && checkPermissions()) {
            bluetoothLeScanner?.stopScan(scanCallback)
            isScanning = false
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                startScan()
            } else {
                methodChannel.invokeMethod(
                    "permissionError",
                    "Required permissions were not granted"
                )
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        stopScan()
    }
}