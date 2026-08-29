package com.rmawatson.flutterisolate;

import android.content.Context;

import androidx.annotation.NonNull;

import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.Set;

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.FlutterEngineGroup;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.view.FlutterCallbackInformation;

/**
 * FlutterIsolatePlugin
 */

class IsolateHolder {
    FlutterEngine engine;
    String isolateId;

    EventChannel startupChannel;
    MethodChannel controlChannel;

    Long entryPoint;
    Result result;
}

public class FlutterIsolatePlugin implements FlutterPlugin, MethodCallHandler, StreamHandler {

    public static final String NAMESPACE = "com.rmawatson.flutterisolate";
    static private Class<?> registrant;
    private Queue<IsolateHolder> queuedIsolates;
    private Map<String, IsolateHolder> activeIsolates;
    private Context context;
    private FlutterEngineGroup engineGroup;

    private static void registerWithCustomRegistrant(io.flutter.embedding.engine.FlutterEngine flutterEngine) {
        if (registrant == null) return;
        try {
            FlutterIsolatePlugin.registrant.getMethod("registerWith", FlutterEngine.class).invoke(null, flutterEngine);
            android.util.Log.i("FlutterIsolate", "Using custom Flutter plugin registrant " + registrant.getCanonicalName());
        } catch (NoSuchMethodException noSuchMethodException) {
            String error = noSuchMethodException.getClass().getSimpleName()
                    + ": " + noSuchMethodException.getMessage() + "\n" +
                    "The plugin registrant must provide a static registerWith(FlutterEngine) method";
            android.util.Log.e("FlutterIsolate", error);
            return;
        } catch (InvocationTargetException invocationException) {
            Throwable target = invocationException.getTargetException();
            String error = target.getClass().getSimpleName() + ": " + target.getMessage() + "\n" +
                    "It is possible the default GeneratedPluginRegistrant is attempting to register\n" +
                    "a plugin that uses registrar.activity() or a similar method. Flutter Isolates have no\n" +
                    "access to the activity() from the registrant. If the activity is being use to register\n" +
                    "a method or event channel, have the plugin use registrar.context() instead. Alternatively\n" +
                    "use a custom registrant for isolates, that only registers plugins that the isolate needs\n" +
                    "to use.";
            android.util.Log.e("FlutterIsolate", error);
            return;
        } catch (Exception except) {
            android.util.Log.e("FlutterIsolate", except.getClass().getSimpleName() + " " + ((InvocationTargetException) except).getTargetException().getMessage());
        }
    }

    /* This should be used to provide a custom plugin registrant for any FlutterIsolates that are spawned,
     * by copying the GeneratedPluginRegistrant provided by flutter call, say "IsolatePluginRegistrant", modifying the
     * list of plugins that are registered (removing the ones you do not want to use from within a plugin) and passing
     * the class to setCustomIsolateRegistrant in your MainActivity.
     *
     * FlutterIsolatePlugin.setCustomIsolateRegistrant(IsolatePluginRegistrant.class);
     *
     * The list will have to be manually maintained if plugins are added or removed, as Flutter automatically
     * regenerates GeneratedPluginRegistrant.
     */
    public static void setCustomIsolateRegistrant(Class registrant) {
        FlutterIsolatePlugin.registrant = registrant;
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        engineGroup = new FlutterEngineGroup(binding.getApplicationContext()); 
        setupChannel(binding.getBinaryMessenger(), binding.getApplicationContext());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }

    private void setupChannel(BinaryMessenger messenger, Context context) {
        this.context = context;
        MethodChannel controlChannel = new MethodChannel(messenger, NAMESPACE + "/control");
        queuedIsolates = new LinkedList<>();
        activeIsolates = new HashMap<>();

        controlChannel.setMethodCallHandler(this);
    }

    private void startNextIsolate() {
        IsolateHolder isolate = queuedIsolates.peek();

        FlutterInjector.instance().flutterLoader().ensureInitializationComplete(context, null);

        FlutterCallbackInformation cbInfo = FlutterCallbackInformation.lookupCallbackInformation(isolate.entryPoint);

        isolate.engine = engineGroup.createAndRunEngine(context, new DartExecutor.DartEntrypoint(
            FlutterInjector.instance().flutterLoader().findAppBundlePath(),
            cbInfo.callbackLibraryPath,
            cbInfo.callbackName
        ));

        isolate.controlChannel = new MethodChannel(isolate.engine.getDartExecutor().getBinaryMessenger(), NAMESPACE + "/control");
        isolate.startupChannel = new EventChannel(isolate.engine.getDartExecutor().getBinaryMessenger(), NAMESPACE + "/event");

        isolate.startupChannel.setStreamHandler(this);
        isolate.controlChannel.setMethodCallHandler(this);

        if (registrant != null) {
            registerWithCustomRegistrant(isolate.engine);
        }
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink sink) {
        if (queuedIsolates.size() != 0) {
            IsolateHolder isolate = queuedIsolates.remove();

            sink.success(isolate.isolateId);
            sink.endOfStream();
            activeIsolates.put(isolate.isolateId, isolate);

            isolate.result.success(null);
            isolate.startupChannel = null;
            isolate.result = null;
        }

        if (queuedIsolates.size() != 0) {
            startNextIsolate();
        }
    }

    @Override
    public void onCancel(Object o) {
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull Result result) {
        if (call.method.equals("spawn_isolate")) {
            IsolateHolder isolate = new IsolateHolder();
            final Object entryPoint = call.argument("entry_point");
            if(entryPoint instanceof Long) {
                isolate.entryPoint = (Long) entryPoint;
            }

            if(entryPoint instanceof Integer) {
                isolate.entryPoint = Long.valueOf((Integer) entryPoint);
            }
            isolate.isolateId = call.argument("isolate_id");
            isolate.result = result;

            queuedIsolates.add(isolate);

            if (queuedIsolates.size() == 1) { // no other pending isolate
                startNextIsolate();
            }
        } else if (call.method.equals("kill_isolate")) {
            String isolateId = call.argument("isolate_id");

            try {
                activeIsolates.get(isolateId).engine.destroy();
            } catch (Exception e) {
                e.printStackTrace();
            }
            activeIsolates.remove(isolateId);
            result.success(true);
        } else if (call.method.equals("get_isolate_list")) {
            final Set<String> runningIsolates = activeIsolates.keySet();
            final List<String> outputList = new ArrayList<>(runningIsolates);

            result.success(outputList);
        } else if (call.method.equals("kill_all_isolates")) {
            final Collection<IsolateHolder> runningIsolates = activeIsolates.values();

            for (IsolateHolder holder : runningIsolates)
                holder.engine.destroy();

            queuedIsolates.clear();
            activeIsolates.clear();
            result.success(true);
        } else {
            result.notImplemented();
        }
    }
}
