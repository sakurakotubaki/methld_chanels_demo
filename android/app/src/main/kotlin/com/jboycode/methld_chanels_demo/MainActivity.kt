package com.jboycode.methld_chanels_demo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    // Flutterで定義した final platform channelと同じ名前にする。
    // final platform = MethodChannel("com.jboycode/platforms");
    private val channel = "com.jboycode/platforms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                // Flutterのメソッドと同じ名前にする。
                if (call.method == "callNative") {
                    result.success("Android ${android.os.Build.VERSION.RELEASE}")
                } else {
                    result.notImplemented()
                }
            }
    }
}
