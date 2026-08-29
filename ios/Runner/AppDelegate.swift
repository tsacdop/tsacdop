import Flutter
import UIKit
import flutter_downloader
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    WorkmanagerPlugin.registerLaunchHandlers()
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerDownloaderPlugins)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

private func registerDownloaderPlugins(registry: FlutterPluginRegistry) {
  guard !registry.hasPlugin("FlutterDownloaderPlugin") else {
    return
  }

  FlutterDownloaderPlugin.register(
    with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!
  )
}
