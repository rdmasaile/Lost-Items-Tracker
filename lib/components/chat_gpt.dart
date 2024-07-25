// import 'dart:async';
// import 'package:flutter_blue/flutter_blue.dart';
// import 'package:flutter_background/flutter_background.dart';

// void main() {
//   FlutterBackground.initialize();
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {

//   StreamSubscription<BluetoothDeviceState> _stateSubscription;
//   bool _isConnected = false;

//   @override
//   void initState() {
//     super.initState();
//     _startBackgroundTask();
//   }

//   Future<void> _startBackgroundTask() async {
//     await FlutterBackground.enableBackgroundExecution();
//     await FlutterBlue.instance.startScan(timeout: Duration(seconds: 10));
//     _stateSubscription = FlutterBlue.instance.scanResults.listen((results) {
//       for (ScanResult result in results) {
//         if (result.device.name == 'MyBluetoothDevice') {
//           setState(() {
//             _isConnected = true;
//           });
//         }
//       }
//     });
//     await FlutterBackground.executeTask((_) async {
//       // This block will run in the background.
//       // Do any additional background work here.
//       // For example, send a notification if the Bluetooth connection is lost.
//       if (!_isConnected) {
//         // Send a notification if the Bluetooth connection is lost.
//         // ...
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _stateSubscription?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: Text('Bluetooth connection status: $_isConnected'),
//         ),
//       ),
//     );
//   }
// }



// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:flutter_background/flutter_background.dart';

// void main() {
//   FlutterBackground.initialize();
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {

//   BluetoothConnection? _connection;
//   bool _isConnected = false;

//   @override
//   void initState() {
//     super.initState();
//     _startBackgroundTask();
//   }

//   Future<void> _startBackgroundTask() async {
//     await FlutterBackground.enableBackgroundExecution();
//     await FlutterBluetoothSerial.instance.requestEnable();
//     BluetoothDevice device = await FlutterBluetoothSerial.instance.getBondedDevices().then((devices) => devices.firstWhere((device) => device.name == 'MyBluetoothDevice'));
//     _connection = await BluetoothConnection.toAddress(device.address);
//     _connection.input.listen((data) {
//       // Handle incoming data here.
//     });
//     await FlutterBackground.executeTask((_) async {
//       // This block will run in the background.
//       // Do any additional background work here.
//       // For example, send a notification if the Bluetooth connection is lost.
//       if (_connection.isConnected == false) {
//         // Send a notification if the Bluetooth connection is lost.
//         // ...
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _connection.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: Text('Bluetooth connection status: ${_connection.isConnected}'),
//         ),
//       ),
//     );
//   }
// }



// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:flutter_background/flutter_background.dart';
// import 'package:workmanager/workmanager.dart';
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

// void main() {
//   FlutterBackground.initialize();
//   Workmanager.initialize(callbackDispatcher);
//   Workmanager.registerPeriodicTask("BluetoothMonitor", "BluetoothMonitorTask",
//       frequency: Duration(minutes: 15),
//       initialDelay: Duration(seconds: 10),
//       constraints: Constraints(networkType: NetworkType.connected));
// }

// void callbackDispatcher() {
//   Workmanager.executeTask((task, inputData) async {
//     if (task == "BluetoothMonitorTask") {
//       BluetoothConnection connection;
//       try {
//         // Connect to the Bluetooth device using its MAC address.
//         connection = await BluetoothConnection.toAddress("00:11:22:33:44:55");
//         connection.input.listen((data) {
//           // Handle incoming data from the Bluetooth device here.
//         });
//       } catch (e) {
//         // The Bluetooth connection failed.
//         FlutterRingtonePlayer.playAlarm();
//       } finally {
//         if (connection != null) {
//           // Close the Bluetooth connection if it was opened successfully.
//           connection.close();
//         }
//       }
//       return Future.value(true);
//     }
//     return Future.value(false);
//   });
// }


// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:flutter_background/flutter_background.dart';
// import 'package:workmanager/workmanager.dart';
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
// import 'package:audio_manager/audio_manager.dart';

// void main() {
//   FlutterBackground.initialize();
//   Workmanager.initialize(callbackDispatcher);
//   Workmanager.registerPeriodicTask("BluetoothMonitor", "BluetoothMonitorTask",
//       frequency: Duration(minutes: 15),
//       initialDelay: Duration(seconds: 10),
//       constraints: Constraints(networkType: NetworkType.connected));
// }

// void callbackDispatcher() {
//   Workmanager.executeTask((task, inputData) async {
//     if (task == "BluetoothMonitorTask") {
//       BluetoothConnection connection;
//       try {
//         // Connect to the Bluetooth device using its MAC address.
//         connection = await BluetoothConnection.toAddress("00:11:22:33:44:55");
//         connection.input.listen((data) {
//           // Handle incoming data from the Bluetooth device here.
//         });
//       } catch (e) {
//         // The Bluetooth connection failed.
//         AudioManager.setVolume(AudioManager.STREAM_MUSIC, 1.0);
//         FlutterRingtonePlayer.playAlarm(volume: 1.0);
//       } finally {
//         if (connection != null) {
//           // Close the Bluetooth connection if it was opened successfully.
//           connection.close();
//         }
//       }
//       return Future.value(true);
//     }
//     return Future.value(false);
//   });
// }

// Future<void> startBluetoothMonitoring() async {
//   await FlutterForegroundTask.start((stopTask) async {
//     // Get the current Bluetooth connection state
//     final BluetoothConnectionState connectionState =
//         await FlutterBluetoothSerial.instance.getConnectionState();

//     // If the connection is lost, make the phone ring
//     if (connectionState == BluetoothConnectionState.disconnected) {
//       // TODO: Make the phone ring
//     }
//   });
// }


// import 'dart:isolate';

// import 'package:flutter/material.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// void main() => runApp(const ExampleApp());

// // The callback function should always be a top-level function.
// @pragma('vm:entry-point')
// void startCallback() {
//   // The setTaskHandler function must be called to handle the task in the background.
//   FlutterForegroundTask.setTaskHandler(MyTaskHandler());
// }

// class MyTaskHandler extends TaskHandler {
//   SendPort? _sendPort;
//   int _eventCount = 0;

//   @override
//   Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
//     _sendPort = sendPort;

//     // You can use the getData function to get the stored data.
//     final customData =
//         await FlutterForegroundTask.getData<String>(key: 'customData');
//     print('customData: $customData');
//   }

//   @override
//   Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
//     FlutterForegroundTask.updateService(
//       notificationTitle: 'MyTaskHandler',
//       notificationText: 'eventCount: $_eventCount',
//     );

//     // Send data to the main isolate.
//     sendPort?.send(_eventCount);

//     _eventCount++;
//   }

//   @override
//   Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
//     // You can use the clearAllData function to clear all the stored data.
//     await FlutterForegroundTask.clearAllData();
//   }

//   @override
//   void onButtonPressed(String id) {
//     // Called when the notification button on the Android platform is pressed.
//     print('onButtonPressed >> $id');
//   }

//   @override
//   void onNotificationPressed() {
//     // Called when the notification itself on the Android platform is pressed.
//     //
//     // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
//     // this function to be called.

//     // Note that the app will only route to "/resume-route" when it is exited so
//     // it will usually be necessary to send a message through the send port to
//     // signal it to restore state when the app is already started.
//     FlutterForegroundTask.launchApp("/resume-route");
//     _sendPort?.send('onNotificationPressed');
//   }
// }

// class ExampleApp extends StatelessWidget {
//   const ExampleApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       initialRoute: '/',
//       routes: {
//         '/': (context) => const ExamplePage(),
//         '/resume-route': (context) => const ResumeRoutePage(),
//       },
//     );
//   }
// }

// class ExamplePage extends StatefulWidget {
//   const ExamplePage({Key? key}) : super(key: key);

//   @override
//   State<StatefulWidget> createState() => _ExamplePageState();
// }

// class _ExamplePageState extends State<ExamplePage> {
//   ReceivePort? _receivePort;

//   void _initForegroundTask() {
//     FlutterForegroundTask.init(
//       androidNotificationOptions: AndroidNotificationOptions(
//         channelId: 'notification_channel_id',
//         channelName: 'Foreground Notification',
//         channelDescription:
//             'This notification appears when the foreground service is running.',
//         channelImportance: NotificationChannelImportance.LOW,
//         priority: NotificationPriority.LOW,
//         iconData: const NotificationIconData(
//           resType: ResourceType.mipmap,
//           resPrefix: ResourcePrefix.ic,
//           name: 'launcher',
//           backgroundColor: Colors.orange,
//         ),
//         buttons: [
//           const NotificationButton(id: 'sendButton', text: 'Send'),
//           const NotificationButton(id: 'testButton', text: 'Test'),
//         ],
//       ),
//       iosNotificationOptions: const IOSNotificationOptions(
//         showNotification: true,
//         playSound: false,
//       ),
//       foregroundTaskOptions: const ForegroundTaskOptions(
//         interval: 5000,
//         isOnceEvent: false,
//         autoRunOnBoot: true,
//         allowWakeLock: true,
//         allowWifiLock: true,
//       ),
//     );
//   }

//   Future<bool> _startForegroundTask() async {
//     // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
//     // onNotificationPressed function to be called.
//     //
//     // When the notification is pressed while permission is denied,
//     // the onNotificationPressed function is not called and the app opens.
//     //
//     // If you do not use the onNotificationPressed or launchApp function,
//     // you do not need to write this code.
//     if (!await FlutterForegroundTask.canDrawOverlays) {
//       final isGranted =
//           await FlutterForegroundTask.openSystemAlertWindowSettings();
//       if (!isGranted) {
//         print('SYSTEM_ALERT_WINDOW permission denied!');
//         return false;
//       }
//     }

//     // You can save data using the saveData function.
//     await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

//     // Register the receivePort before starting the service.
//     final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
//     final bool isRegistered = _registerReceivePort(receivePort);
//     if (!isRegistered) {
//       print('Failed to register receivePort!');
//       return false;
//     }

//     if (await FlutterForegroundTask.isRunningService) {
//       return FlutterForegroundTask.restartService();
//     } else {
//       return FlutterForegroundTask.startService(
//         notificationTitle: 'Foreground Service is running',
//         notificationText: 'Tap to return to the app',
//         callback: startCallback,
//       );
//     }
//   }

//   Future<bool> _stopForegroundTask() {
//     return FlutterForegroundTask.stopService();
//   }

//   bool _registerReceivePort(ReceivePort? newReceivePort) {
//     if (newReceivePort == null) {
//       return false;
//     }

//     _closeReceivePort();

//     _receivePort = newReceivePort;
//     _receivePort?.listen((message) {
//       if (message is int) {
//         print('eventCount: $message');
//       } else if (message is String) {
//         if (message == 'onNotificationPressed') {
//           Navigator.of(context).pushNamed('/resume-route');
//         }
//       } else if (message is DateTime) {
//         print('timestamp: ${message.toString()}');
//       }
//     });

//     return _receivePort != null;
//   }

//   void _closeReceivePort() {
//     _receivePort?.close();
//     _receivePort = null;
//   }

//   T? _ambiguate<T>(T? value) => value;

//   @override
//   void initState() {
//     super.initState();
//     _initForegroundTask();
//     _ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) async {
//       // You can get the previous ReceivePort without restarting the service.
//       if (await FlutterForegroundTask.isRunningService) {
//         final newReceivePort = FlutterForegroundTask.receivePort;
//         _registerReceivePort(newReceivePort);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _closeReceivePort();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // A widget that prevents the app from closing when the foreground service is running.
//     // This widget must be declared above the [Scaffold] widget.
//     return WithForegroundTask(
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Flutter Foreground Task'),
//           centerTitle: true,
//         ),
//         body: _buildContentView(),
//       ),
//     );
//   }

//   Widget _buildContentView() {
//     buttonBuilder(String text, {VoidCallback? onPressed}) {
//       return ElevatedButton(
//         child: Text(text),
//         onPressed: onPressed,
//       );
//     }

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           buttonBuilder('start', onPressed: _startForegroundTask),
//           buttonBuilder('stop', onPressed: _stopForegroundTask),
//         ],
//       ),
//     );
//   }
// }

// class ResumeRoutePage extends StatelessWidget {
//   const ResumeRoutePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Resume Route'),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             // Navigate back to first route when tapped.
//             Navigator.of(context).pop();
//           },
//           child: const Text('Go back!'),
//         ),
//       ),
//     );
//   }
// }
