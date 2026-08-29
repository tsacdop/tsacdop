package com.stonegate.tsacdop

import android.app.Application
import com.rmawatson.flutterisolate.FlutterIsolatePlugin
import io.flutter.plugins.IsolatePluginRegistrant

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        FlutterIsolatePlugin.setCustomIsolateRegistrant(
            IsolatePluginRegistrant::class.java,
        )
    }
}
