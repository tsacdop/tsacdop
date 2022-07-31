package com.stonegate.tsacdop
import com.rmawatson.flutterisolate.FlutterIsolatePlugin
import io.flutter.app.FlutterApplication
import io.flutter.plugins.IsolatePluginRegistrant

public class MainApplication: FlutterApplication() {
    public fun MainApplication() {
        FlutterIsolatePlugin.setCustomIsolateRegistrant(IsolatePluginRegistrant::class.java);
    }
}