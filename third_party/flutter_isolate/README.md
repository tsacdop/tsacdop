# FlutterIsolate

A Dart isolate is roughly equivalent to a single, independent execution thread. In a Flutter context, creating ("spawning") an isolate allows code to execute outside the main thread, which is important for running expensive/long-running tasks that would otherwise block the UI.

However, code in a spawned isolate will generally not be able to interact with Flutter plugins. This is due to the tight integration between the platform plugin scaffolding and the main application isolate.

The FlutterIsolate plugin fixes this with the introduction of a `FlutterIsolate` class, which is a wrapper around the platform APIs for creating isolates and setting up the bindings necessary for code running in spawned isolates to communicate with Flutter plugins.

### FlutterIsolate API

|                  |      Android       |         iOS          |             Description            |
| :--------------- | :----------------: | :------------------: |  :-------------------------------- |
| FlutterIsolate.spawn(entryPoint,message)             | :white_check_mark: |  :white_check_mark:  | spawns a new FlutterIsolate        |
| FlutterIsolate.pause()            | :white_check_mark: |  :white_check_mark:  | pauses a running isolate |
| FlutterIsolate.resume()           | :white_check_mark: |  :white_check_mark:  | resumed a paused isolate |
| FlutterIsolate.kill()             | :white_check_mark: |  :white_check_mark:  | kills a an isolate |
| FlutterIsolate.killAll()             | :white_check_mark: |  :white_check_mark:  | kills all currently running  isolates |
| FlutterIsolate.runningIsolates             | :white_check_mark: |  :white_check_mark:  | returns the IDs associated with all currently running isolates |
| flutterCompute(callback,message)  | :white_check_mark: |  :white_check_mark:  | spawns a new FlutterIsolate, runs callback and returns the returned value |

### Usage

To spawn a FlutterIsolate, call the `spawn` method with a top-level or static function that has been annotated with the `@pragma('vm:entry-point')` decorator:

```dart
import 'package:flutter_isolate/flutter_isolate.dart';

@pragma('vm:entry-point')
void someFunction(String arg) { 
  print("Running in an isolate with argument : $arg");
}
...

class SomeWidget() {
...

@override
  Widget build(BuildContext context) {
    return ElevatedButton(
            child: Text('Run'),
            onPressed: () {
                FlutterIsolate.spawn(someFunction, "hello world");
            },
    );
}
```


If you just want to spawn an isolate to perform a single task (like the [Flutter `compute` method](https://api.flutter.dev/flutter/foundation/compute-constant.html)), call `flutterCompute`:
```dart
@pragma('vm:entry-point')
Future<int> expensiveWork(int arg) async {
  int result;
  // lots of calculations
  return result;
}

Future<int> doExpensiveWorkInBackground() async {
  return await flutterCompute(expensiveWork, arg);
}
```

Isolates can also be spawned from other isolates:


```dart
import 'package:flutter_startup/flutter_startup.dart';
import 'package:flutter_isolate/flutter_isolate.dart';

@pragma('vm:entry-point')
void isolate2(String arg) {
  FlutterStartup.startupReason.then((reason){
    print("Isolate2 $reason");
  });
  Timer.periodic(Duration(seconds:1),(timer)=>print("Timer Running From Isolate 2"));
}

@pragma('vm:entry-point')
void isolate1(String arg) async  {

  final isolate = await FlutterIsolate.spawn(isolate2, "hello2");

  FlutterStartup.startupReason.then((reason){
    print("Isolate1 $reason");
  });
  Timer.periodic(Duration(seconds:1),(timer)=>print("Timer Running From Isolate 1"));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isolate = await FlutterIsolate.spawn(isolate1, "hello");
  Timer(Duration(seconds:5), (){print("Pausing Isolate 1");isolate.pause();});
  Timer(Duration(seconds:10),(){print("Resuming Isolate 1");isolate.resume();});
  Timer(Duration(seconds:20),(){print("Killing Isolate 1");isolate.kill();});

  runApp(MyApp());
}
...
```

See [example/lib/main.dart](https://github.com/rmawatson/flutter_isolate/blob/master/example/lib/main.dart) for example usage with the [flutter_downloader plugin](https://pub.dev/packages/flutter_downloader).

It is important to note that the entrypoint must be a top-level function, decorated with the `@pragma('vm:entry-point') annotation:

```dart
@pragma('vm:entry-point')
void topLevelFunction(Map<String, dynamic> args) {
  // performs work in an isolate
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    FlutterIsolate.spawn(topLevelFunction, {});
    super.initState();
  }
  Widget build(BuildContext context) {
    return Container();
  }
}
```

or a static method:

```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  @pragma('vm:entry-point')
  static void topLevelFunction(Map<String, dynamic> args) {
    // performs work in an isolate
  }

  @override
  void initState() {
    FlutterIsolate.spawn(_MyAppState.staticMethod, {});
    super.initState();
  }
  Widget build(BuildContext context) {
    return Container();
  }
}
```

A class-level method will *not* work and will throw an Exception:
```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  
  void classMethod(Map<String, dynamic> args) {
    // don't do this!
  }

  @override
  void initState() {
    
    FlutterIsolate.spawn(classMethod, {}); // this will throw NoSuchMethodError: The method 'toRawHandle' was called on null.
    super.initState();
  }
  Widget build(BuildContext context) {
    return Container();
  }
}
```

Failure to add the `@pragma('vm:entry-point')` annotation will cause the app to crash in release mode.

### Notes

Due to a FlutterIsolate being backed by a platform specific 'view', the event loop will not terminate when there is no more 'user' work left to do and FlutterIsolates will require explict termination with kill().

Additionally this plugin has not been tested with a large range of plugins, only a small subset I have been using such as flutter_notification, flutter_blue and flutter_startup.

### Communicating between isolates

To pass data between isolates, a ReceivePort should be created on your (parent) isolate with the corresponding SendPort sent via the `spawn` method:

```dart
@pragma('vm:entry-point')
void spawnIsolate(SendPort port) {
  port.send("Hello!");
}

void main() {
  var port = ReceivePort();
  port.listen((msg) {
    print("Received message from isolate $msg");
  });
  var isolate = await FlutterIsolate.spawn(spawnIsolate, port.sendPort);

}
```

Only primitives can be sent via a SendPort - [see the SendPort documentation for further details](https://api.flutter.dev/flutter/dart-isolate/SendPort/send.html).


### Custom plugin registrant

See the example project for a sample implementation using a custom plugin registrant.

#### iOS

By default, `flutter_isolate` will register all plugins provided by Flutter's automatically generated `GeneratedPluginRegistrant.m` file.

If you want to register, e.g. some custom `FlutterMethodChannel`s, you can define a custom registrant:

```swift
// Defines a custom plugin registrant, to be used specifically together with FlutterIsolatePlugin
@objc(IsolatePluginRegistrant) class IsolatePluginRegistrant: NSObject {
    @objc static func register(withRegistry registry: FlutterPluginRegistry) {
        // Register channels for Flutter Isolate
        registerMethodChannelABC(bm: registry.registrar(forPlugin: "net.myapp.myChannelABC").messenger())

        // Register default plugins
        GeneratedPluginRegistrant.register(with: registry)
    }
}

// In AppDelegate.swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window.rootViewController as! FlutterViewController

        // Register custom channels for Flutter
        registerMethodChannelABC(bm: controller.binaryMessenger) // <-- the custom method channel

        // Point FlutterIsolatePlugin to use our previously defined custom registrant.
        // The string content must be equal to the plugin registrant class annotation 
        // value: @objc(IsolatePluginRegistrant)
        FlutterIsolatePlugin.isolatePluginRegistrantClassName = "IsolatePluginRegistrant" // <--

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

#### Android

Define a custom plugin registrant, to be used specifically together with FlutterIsolatePlugin:

```Java
public final class CustomPluginRegistrant {
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(... [your plugin goes here]);
  }
}
```

Create a MainApplication class that sets this custom isolate registrant:
```Java
public class MainApplication extends FlutterApplication {
  public MainApplication() {
    FlutterIsolatePlugin.setCustomIsolateRegistrant(CustomPluginRegistrant.class);
  }
}
```
