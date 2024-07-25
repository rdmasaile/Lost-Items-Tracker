import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:workmanager/workmanager.dart';

import '../helper/database_helper.dart';

void initForegroundTask() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'notification_channel_id',
      channelName: 'Foreground Notification',
      channelDescription:
          'This notification appears when the foreground service is running.',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      iconData: const NotificationIconData(
        resType: ResourceType.mipmap,
        resPrefix: ResourcePrefix.ic,
        name: 'launcher',
        backgroundColor: Colors.orange,
      ),
      buttons: [
        const NotificationButton(id: 'sendButton', text: 'Send'),
        const NotificationButton(id: 'testButton', text: 'Test'),
      ],
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 5000,
      isOnceEvent: false,
      autoRunOnBoot: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

class MyTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;

    // You can use the getData function to get the stored data.
    final customData =
        await FlutterForegroundTask.getData<String>(key: 'customData');
    print('customData: $customData');
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
      notificationTitle: 'MyTaskHandler',
      notificationText: 'eventCount: $_eventCount',
    );

    // Send data to the main isolate.
    sendPort?.send(_eventCount);

    _eventCount++;
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    print('onButtonPressed >> $id');
  }

  @override
  void onNotificationPressed() {
    // Called when the notification itself on the Android platform is pressed.
    //
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // this function to be called.

    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }
}

class foreground {
  ReceivePort? _receivePort;

  Future<bool> _startForegroundTask() async {
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // onNotificationPressed function to be called.
    //
    // When the notification is pressed while permission is denied,
    // the onNotificationPressed function is not called and the app opens.
    //
    // If you do not use the onNotificationPressed or launchApp function,
    // you do not need to write this code.
    if (!await FlutterForegroundTask.canDrawOverlays) {
      final isGranted =
          await FlutterForegroundTask.openSystemAlertWindowSettings();
      if (!isGranted) {
        print('SYSTEM_ALERT_WINDOW permission denied!');
        return false;
      }
    }

    // You can save data using the saveData function.
    await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    // Register the receivePort before starting the service.
    final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
    final bool isRegistered = _registerReceivePort(receivePort);
    if (!isRegistered) {
      print('Failed to register receivePort!');
      return false;
    }

    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }
  }

  Future<bool> _stopForegroundTask() {
    return FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? newReceivePort) {
    if (newReceivePort == null) {
      return false;
    }

    _closeReceivePort();

    _receivePort = newReceivePort;
    _receivePort?.listen((message) {
      if (message is int) {
        print('eventCount: $message');
      } else if (message is String) {
        if (message == 'onNotificationPressed') {
          // Navigator.of(context).pushNamed('/');
        }
      } else if (message is DateTime) {
        print('timestamp: ${message.toString()}');
      }
    });

    return _receivePort != null;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }
}

@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    print('Running background task: $taskName');
    if (taskName == "BluetoothMonitorTask") {
      var devices = await DatabaseHelper.instance.getDevices();
      for (var device in devices) {
        print(device.name);
        // await connect(
        //   BluetoothDevice(
        //     address: device.address,
        //     name: device.name,
        //   ),
        // );
      }
      return Future.value(true);
    }
    return Future.value(false);
  });
}

void deletedFromMain() {
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  // Workmanager().registerPeriodicTask(
  //   "BluetoothMonitor",
  //   "BluetoothMonitorTask",
  //   initialDelay: const Duration(seconds: 5),
  //   frequency: const Duration(minutes: 15),
  //   // constraints: Constraints(networkType: NetworkType.connected),
  // );
}

// Deleted From BackService
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      initialNotificationTitle: "Lost items Tracker",
      initialNotificationContent: "Service started",
      onStart: onStart,
      isForegroundMode: true,
      autoStartOnBoot: true,
      autoStart: true,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance serviceInstance) {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  if (serviceInstance is AndroidServiceInstance) {
    serviceInstance.on('setAsForeground').listen((event) {
      serviceInstance.setAsForegroundService();
    });
    serviceInstance.on('setAsBackground').listen((event) {
      serviceInstance.setAsBackgroundService();
    });
  }
  serviceInstance.on('setAsBackground').listen((event) {
    serviceInstance.stopSelf();
  });
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    if (serviceInstance is AndroidServiceInstance) {
      if (await serviceInstance.isForegroundService()) {
        serviceInstance.setForegroundNotificationInfo(
            title: "Lost device Tracker", content: "My channel");
      }
    }
    print("background servie is running...");
    final devices = await DatabaseHelper.instance.getDevices();
    for (var device in devices) {
      // if (await bluetoothIsAvailable()) {
      // connect(BluetoothDevice(address: device.address, name: device.name));
      // } else {
      // print("Bluetooth is not avallable");
      // }
    }
    serviceInstance.invoke('update');
  });
}
