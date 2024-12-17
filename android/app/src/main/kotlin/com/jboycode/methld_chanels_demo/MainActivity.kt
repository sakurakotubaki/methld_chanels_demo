package com.jboycode.methld_chanels_demo

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.*
import kotlin.concurrent.timer

class MainActivity: FlutterActivity() {
    private val TAG = "WeightScale"  // デバッグ用タグ
    private val METHOD_CHANNEL = "com.jboycode/weight_scale/method"
    private val EVENT_CHANNEL = "com.jboycode/weight_scale/event"
    private var weightTimer: Timer? = null
    private var isScaleOn = false
    private var currentWeight = 60.0
    private var isIncreasing = true
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Log.d(TAG, "Configuring Flutter Engine")

        // Method Channel setup
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "toggleScale" -> {
                        Log.d(TAG, "Toggle Scale called with: ${call.arguments}")
                        isScaleOn = call.arguments as Boolean
                        if (isScaleOn) {
                            startWeightSimulation()
                        } else {
                            stopWeightSimulation()
                        }
                        result.success(isScaleOn)
                    }
                    else -> result.notImplemented()
                }
            }

        // Event Channel setup
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    Log.d(TAG, "EventChannel onListen called")
                    eventSink = events
                    startWeightSimulation()
                }

                override fun onCancel(arguments: Any?) {
                    Log.d(TAG, "EventChannel onCancel called")
                    stopWeightSimulation()
                    eventSink = null
                }
            })
    }

    private fun startWeightSimulation() {
        Log.d(TAG, "Starting weight simulation")
        weightTimer?.cancel()
        weightTimer = timer(period = 1000) {
            if (isScaleOn) {
                if (isIncreasing) {
                    currentWeight += 0.5
                    if (currentWeight >= 70.0) isIncreasing = false
                } else {
                    currentWeight -= 0.5
                    if (currentWeight <= 50.0) isIncreasing = true
                }

                runOnUiThread {
                    Log.d(TAG, "Sending weight: $currentWeight")
                    eventSink?.success(currentWeight)
                }
            }
        }
    }

    private fun stopWeightSimulation() {
        Log.d(TAG, "Stopping weight simulation")
        weightTimer?.cancel()
        weightTimer = null
    }
}