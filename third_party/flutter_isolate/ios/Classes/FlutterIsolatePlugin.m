#import "FlutterIsolatePlugin.h"
#import <objc/message.h>

@interface IsolateHolder : NSObject
@property(nonatomic) FlutterEngine* engine;
@property(nonatomic) NSString* isolateId;
@property(nonatomic) long long entryPoint;
@property(nonatomic) FlutterResult result;
@property(nonatomic) FlutterEventChannel* startupChannel;
@property(nonatomic) FlutterMethodChannel* controlChannel;
@end

@implementation IsolateHolder
@end

static dispatch_once_t _initializeStaticPlugin = 0;
static NSMutableArray<IsolateHolder*>* _queuedIsolates;
static NSMutableDictionary<NSString*,IsolateHolder*>* _activeIsolates;


@interface FlutterIsolatePlugin()
@property(nonatomic) NSObject<FlutterPluginRegistrar> * registrar;
@property(nonatomic) FlutterMethodChannel* controlChannel;
@property FlutterEventSink sink;
@end


@interface GeneratedPluginRegistrant : NSObject
+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry;
@end

@implementation FlutterIsolatePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    dispatch_once(&_initializeStaticPlugin, ^{
        _queuedIsolates = [NSMutableArray<IsolateHolder*> new];
        _activeIsolates = [NSMutableDictionary<NSString*,IsolateHolder*> new];
    });
    
    FlutterIsolatePlugin *plugin = [[FlutterIsolatePlugin alloc] init];
    
    plugin.registrar = registrar;
    
    plugin.controlChannel = [FlutterMethodChannel methodChannelWithName:FLUTTER_ISOLATE_NAMESPACE @"/control"
                                                        binaryMessenger:[registrar messenger]];
    [registrar addMethodCallDelegate:plugin channel:plugin.controlChannel];
}

static NSString* _isolatePluginRegistrantClassName;
+ (NSString*)isolatePluginRegistrantClassName { return _isolatePluginRegistrantClassName; }
+ (void)setIsolatePluginRegistrantClassName:(NSString*)value { _isolatePluginRegistrantClassName = value; }

+ (nullable Class)lookupGeneratedPluginRegistrant {
    NSString* classNameToCompare = @"GeneratedPluginRegistrant";
    if (_isolatePluginRegistrantClassName != nil) {
        classNameToCompare = _isolatePluginRegistrantClassName;
    }

    return NSClassFromString(classNameToCompare);
}



- (void)startNextIsolate {
    IsolateHolder *isolate = _queuedIsolates.firstObject;

    FlutterCallbackInformation *info = [FlutterCallbackCache lookupCallbackInformation:isolate.entryPoint];

    isolate.engine = [FlutterEngine alloc];
    if ([isolate.engine respondsToSelector:@selector(initWithName:project:allowHeadlessExecution:)]) {
        ((id(*)(id,SEL,id,id,id))objc_msgSend)(isolate.engine, @selector(initWithName:project:allowHeadlessExecution:) , isolate.isolateId, nil, @(YES));
    }
    else // older versions before above is available
        [isolate.engine initWithName:isolate.isolateId project:nil];


    /* not entire sure if a listen on an event channel will be queued
     * as we cannot register the event channel until after runWithEntryPoint has been called. If it is not queued
     * then this will be a race on the FlutterEventChannels initialization, and could deadlock. */
    [isolate.engine runWithEntrypoint:info.callbackName libraryURI:info.callbackLibraryPath];


    isolate.controlChannel = [FlutterMethodChannel methodChannelWithName:FLUTTER_ISOLATE_NAMESPACE @"/control"
                                         binaryMessenger:isolate.engine];

    isolate.startupChannel = [FlutterEventChannel eventChannelWithName:FLUTTER_ISOLATE_NAMESPACE @"/event"
                                                         binaryMessenger:isolate.engine];

    [isolate.startupChannel setStreamHandler:self];
    [_registrar addMethodCallDelegate:self channel:isolate.controlChannel];

    [[FlutterIsolatePlugin lookupGeneratedPluginRegistrant] registerWithRegistry:isolate.engine];
}


- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"spawn_isolate" isEqualToString:call.method]) {
      IsolateHolder* isolate = [IsolateHolder new];

      isolate.entryPoint = [[call.arguments objectForKey:@"entry_point"] longLongValue];
      isolate.isolateId = [call.arguments objectForKey:@"isolate_id"];
      isolate.result = result;

      [_queuedIsolates addObject:isolate];

      if (_queuedIsolates.count == 1)
          [self startNextIsolate];

  } else if ([@"kill_isolate" isEqualToString:call.method]) {
      NSString *isolateId = [call.arguments objectForKey:@"isolate_id"];

      if ([_activeIsolates[isolateId].engine respondsToSelector:@selector(destroyContext)])
          ((void(*)(id,SEL))objc_msgSend)(_activeIsolates[isolateId].engine, @selector(destroyContext));

      [_activeIsolates removeObjectForKey:isolateId];
      result(nil);
  } else if ([@"get_isolate_list" isEqualToString:call.method]) {
      NSArray *output = [_activeIsolates allKeys];
      result(output);
  } else if ([@"kill_all_isolates" isEqualToString:call.method]) {
      for (NSString *key in _activeIsolates) {
          if ([_activeIsolates[key].engine respondsToSelector:@selector(destroyContext)])
              ((void(*)(id,SEL))objc_msgSend)(_activeIsolates[key].engine, @selector(destroyContext));
      }
      [_activeIsolates removeAllObjects];
      [_queuedIsolates removeAllObjects];
      result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)sink {

    IsolateHolder* isolate = _queuedIsolates.firstObject;

    if (isolate != nil) {
        sink(isolate.isolateId);
        sink(FlutterEndOfEventStream);
        _activeIsolates[isolate.isolateId] = isolate;
        [_queuedIsolates removeObject:isolate];

        isolate.result(@(YES));
        isolate.startupChannel = nil;
        isolate.result = nil;
    }

    if (_queuedIsolates.count != 0)
        [self startNextIsolate];

    return nil;

}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    return nil;
}

@end
