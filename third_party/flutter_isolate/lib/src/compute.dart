import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_isolate/flutter_isolate.dart';

/// A function that spawns a flutter isolate and runs the provided [callback] on
/// that isolate, passes it the provided [message], and (eventually) returns the
/// value returned by [callback].
///
/// Since [callback] needs to be passed between isolates, it must be a top-level
/// function or a static method.
///
/// Both the return type and the [message] type must be supported by
/// [SendPort.send] stated in
/// https://api.dart.dev/stable/dart-isolate/SendPort/send.html
@pragma('vm:entry-point')
Future<T> flutterCompute<T, U>(
  FutureOr<T> Function(U message) callback,
  U message,
) async {
  final callbackHandle = PluginUtilities.getCallbackHandle(callback)!
      .toRawHandle();
  final completer = Completer<dynamic>();
  final port = RawReceivePort();
  port.handler = (dynamic response) {
    port.close();
    completer.complete(response);
  };

  FlutterIsolate? isolate;
  try {
    isolate = await FlutterIsolate.spawn(_isolateMain, {
      "callback": callbackHandle,
      "port": port.sendPort,
      "message": message,
    });
  } catch (_) {
    port.close();
    isolate?.kill();
    rethrow;
  }
  final response = await completer.future;
  isolate.kill();

  if (response == null) {
    throw RemoteError("Isolate exited without result or error.", "");
  }
  if (response["status"] == _Status.ok.index) {
    return response["result"] as T;
  } else {
    await Future<Never>.error(
      RemoteError(response["error"], response["stackTrace"]),
    );
  }
}

enum _Status { ok, error }

@pragma('vm:entry-point')
Future<void> _isolateMain(Map<String, dynamic> config) async {
  final port = config["port"] as SendPort;
  try {
    final callbackHandle = CallbackHandle.fromRawHandle(config["callback"]);
    final callback = PluginUtilities.getCallbackFromHandle(callbackHandle);
    final message = config["message"];
    final result = await callback!(message);
    port.send({"status": _Status.ok.index, "result": result});
  } catch (e, stackTrace) {
    port.send({
      "status": _Status.error.index,
      "error": e.toString(),
      "stackTrace": stackTrace.toString(),
    });
  }
}
