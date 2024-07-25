// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
// import 'dart:js';
import 'dart:typed_data';
import 'dart:ui';

import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:projectfbs/constants.dart';
import 'package:projectfbs/helper/bluetooth_device_connection.dart';
import 'package:projectfbs/helper/database_helper.dart';
import 'package:projectfbs/helper/settings.dart';
import 'package:projectfbs/server/bluetooth_server.dart';
import 'package:projectfbs/services/notification_service.dart';
import 'package:projectfbs/widgets/widgets.dart';

// class BackgroundProcess {
//   static Timer? _moniterTimer;
//   static bool waited = false;

//   BackgroundProcess._();
//   static final BackgroundProcess instance = BackgroundProcess._();
//   static void start() {
//     print("in Start fun");
//     Timer.periodic(const Duration(seconds: 10), (timer) async {
//       print("starting Timer1");
//       List devices = await DatabaseHelper.instance.getDevices();
//       List lostDevices = await DatabaseHelper.instance.getLostDevices();
//       for (var device in devices) {
//         if (lostDevices.isEmpty) {
//           await connect(BluetoothDevice(address: device.address),
//               function: "start");
//         } else {
//           for (var lostDevice in lostDevices) {
//             if (device.address == lostDevice.address) {
//               print("There in Lost devices");
//               continue;
//             }
//             print("Not there in Lost devices");
//             await connect(BluetoothDevice(address: device.address),
//                 function: "start");
//           }
//         }
//       }
//     });
//   }

//   void run() {
//     if (_moniterTimer != null) {
//       throw FlutterError("Background process is already running");
//     }

//     _moniterTimer = Timer.periodic(const Duration(seconds: 60), (timer) async {
//       List monitoredDevices =
//           await DatabaseHelper.instance.getMonitoredDevices();
//       for (var device in monitoredDevices) {
//         await connect(
//             BluetoothDevice(address: device.address, name: device.name));
//       }
//     });
//   }

//   static Future<void> stop() async {
//     FlutterRingtonePlayer.stop();
//     if (_moniterTimer != null) {
//       _moniterTimer!.cancel();
//       _moniterTimer = null;
//     }
//   }

//   static Future<void> connect(BluetoothDevice bluetoothDevice,
//       {String? function}) async {
//     debugPrint(bluetoothDevice.name);
//     BluetoothConnection? connection;

//     var devices = await FlutterBluetoothSerial.instance.getBondedDevices();

//     for (var device in devices) {
//       if (device.address == bluetoothDevice.address) {
//         bluetoothDevice = device;
//       }
//     }
//     if (!waited) {
//       if (!bluetoothDevice.isBonded) {
//         try {
//           await FlutterBluetoothSerial.instance
//               .bondDeviceAtAddress(bluetoothDevice.address);
//           debugPrint("Parring...");
//         } catch (error) {
//           debugPrint(error.toString());
//           await Future.delayed(const Duration(seconds: 30)).whenComplete(() {
//             waited = true;
//           });
//         }
//       }

//       waited = false;
//       if (!bluetoothDevice.isBonded) {
//         debugPrint("not bonded or connected");
//         if (function == 'start') {
//           try {
//             await DatabaseHelper.instance.addLostDevice(LostDevice(
//               address: bluetoothDevice.address,
//               longitude: 388888,
//               latitude: 77778,
//               lostAt: DateTime.now().toString(),
//             ));
//           } catch (e) {
//             print(e.toString());
//           }
//         }
//         return;
//       }
//       if (bluetoothDevice.isConnected) {
//         if (function == 'start') {
//           await DatabaseHelper.instance
//               .remove(bluetoothDevice.address, table: "lost_devices");
//         }
//         return;
//       }
//       try {
//         connection =
//             await BluetoothConnection.toAddress(bluetoothDevice.address);
//         debugPrint('Connected to the device ${bluetoothDevice.name}');

//         if (function == 'start') {
//           await DatabaseHelper.instance
//               .remove(bluetoothDevice.address, table: "lost_devices");
//         }

//         connection.input?.listen((Uint8List data) {
//           debugPrint('Data incoming: ${ascii.decode(data)}');
//         });
//       } catch (exception) {
//         // AudioManager.instance.setVolume(5.0);
//         debugPrint('Cannot connect, exception occured ');
//         if (function == 'start') {
//           try {
//             await DatabaseHelper.instance.addLostDevice(LostDevice(
//               address: bluetoothDevice.address,
//               longitude: 388888,
//               latitude: 77778,
//               lostAt: DateTime.now().toString(),
//             ));
//           } catch (e) {
//             print(e.toString());
//           }
//         } else {
//           FlutterRingtonePlayer.playAlarm(
//             asAlarm: true,
//             looping: false,
//             volume: 5,
//           );
//         }
//         // await Future.delayed(const Duration(seconds: 30));
//       } finally {
//         if (connection != null) {
//           print("connection was created");
//           await Future.delayed(const Duration(minutes: 1)).whenComplete(() {
//             print("CLOSING...");
//             connection!.close();
//             connection.dispose();
//           });
//         }
//       }
//     }
//   }
// }

// class BackgroundProcess {
//   static Timer? _moniterTimer;
//   static Timer? _backGroundTimer;
//   // static List checkedDevices;
//   BackgroundProcess._();
//   static final BackgroundProcess instance = BackgroundProcess._();
//   static void start() {
//     print("in Start fun");
//     _backGroundTimer =
//         Timer.periodic(const Duration(seconds: 15), (timer) async {
//       print("starting Timer1");
//       List<Device> devices = await DatabaseHelper.instance.getDevices();
//       for (Device device in devices) {
//         await connect(BluetoothDevice(address: device.address));
//       }
//     });
//   }

//   void run(BuildContext context) {
//     if (_moniterTimer != null) {
//       throw FlutterError("Background process is already running");
//     }
//     bool connected;
//     _moniterTimer = Timer.periodic(const Duration(seconds: 60), (timer) async {
//       List monitoredDevices =
//           await DatabaseHelper.instance.getMonitoredDevices();
//       for (var device in monitoredDevices) {
//         connected = await connect(
//             BluetoothDevice(address: device.address, name: device.name));
//         if (!connected) {
//           showDialogueBox(
//               context,
//               icon: const Icon(
//                 Icons.warning_amber,
//                 color: Colors.amber,
//               ),
//               'Device ${device.name} is lost!!!',
//               [
//                 button('Stop', () {
//                   stop();
//                   Navigator.of(context).pop();
//                 })
//               ]);

//           FlutterRingtonePlayer.playAlarm(
//               volume: 3, looping: false, asAlarm: true);
//         }
//       }
//     });
//   }

//   /// Returns true when it is connected and false if not connected
//   ///
//   static Future<bool> connect(BluetoothDevice bluetoothDevice) async {
//     BluetoothConnection? connection;
//     if (GlobalValues.connectedDevices.contains(bluetoothDevice.address)) {
//       print(GlobalValues.connectedDevices);
//       await DatabaseHelper.instance
//           .remove(bluetoothDevice.address, table: "lost_devices");
//       return true;
//     }
//     try {
//       connection = await BluetoothConnection.toAddress(bluetoothDevice.address);
//       // if (connection.isConnected) {
//       await DatabaseHelper.instance
//           .remove(bluetoothDevice.address, table: "lost_devices");
//       // }
//       return true;
//     } catch (e) {
//       print("Connection Error");
//       try {
//         bool found = await DatabaseHelper.instance
//             .checkIfThere(bluetoothDevice.address, 'lost_devices');
//         print(found);
//         print("checked");
//         if (found) {
//           return false;
//         }
//         print("POSOTION...");
//         Position position = await Geolocator.getCurrentPosition();
//         await DatabaseHelper.instance.addLostDevice(LostDevice(
//           address: bluetoothDevice.address,
//           longitude: position.longitude,
//           latitude: position.latitude,
//           lostAt: DateTime.now().toString(),
//         ));
//       } catch (e) {
//         print(e.toString());
//       }
//       return false;
//     } finally {
//       if (connection != null) {
//         connection.close();
//         connection.dispose();
//       }
//     }
//   }

//   static Future<void> stop() async {
//     FlutterRingtonePlayer.stop();
//     if (_moniterTimer != null) {
//       _moniterTimer!.cancel();
//       _moniterTimer = null;
//     }
//   }

//   static Future<void> stopAll() async {
//     FlutterRingtonePlayer.stop();
//     if (_backGroundTimer != null) {
//       _backGroundTimer!.cancel();
//       _backGroundTimer = null;
//     }
//     if (_moniterTimer != null) {
//       _moniterTimer!.cancel();
//       _moniterTimer = null;
//     }
//   }
// }

class BackgroundProcess {
  Timer? _backGroundTimer;
  bool _ringing = false;
  bool run = true;
  bool get isRunning => run;
  BackgroundProcess._();
  static final BackgroundProcess _instance = BackgroundProcess._();
  static final BackgroundProcess instance = _instance;
  void start() {
    _backGroundTimer =
        Timer.periodic(const Duration(seconds: 15), (timer) async {
      if (!run ||
          await FlutterBluetoothSerial.instance.state ==
              BluetoothState.UNKNOWN ||
          await FlutterBluetoothSerial.instance.state ==
              BluetoothState.STATE_OFF) {
        print("Stopped");
        return;
      }
      List<Device> devices = await DatabaseHelper.instance.getDevices();
      for (Device device in devices) {
        BluetoothDeviceConnection? deviceConnection =
            await BluetoothServer.instance.requestConnection(
                to: device.address, from: PROCESS_TYPE.BACKGROUND);
        if (deviceConnection != null) {
          try {
            await DatabaseHelper.instance.remove(device.address,
                table: DatabaseHelper.instance.lostDevicesTable);
          } catch (e) {
            print(e.toString());
          }
          if (deviceConnection.processType != PROCESS_TYPE.PAGE) {
            await deviceConnection.listen(listener: (String message) async {
              if (message.contains('R')) {
                ring(
                  message: "Ringing by ${device.name}!!!",
                ); // await Future.delayed(const Duration(seconds: 30), () {});
              }
            });
          }
        } else {
          try {
            bool found = await DatabaseHelper.instance.checkIfThere(
                device.address, DatabaseHelper.instance.lostDevicesTable);
            if (found) {
              print("checked");
              continue;
            }
            print("POSOTION...");
            Position position = await Geolocator.getCurrentPosition();
            await DatabaseHelper.instance.addLostDevice(LostDevice(
              address: device.address,
              longitude: position.longitude,
              latitude: position.latitude,
              lostAt: DateTime.now().toString(),
            ));
          } catch (e) {
            print(e.toString());
          }
        }
      }
      Settings settings = await SettingsHelper.instance.getSettings();
      if (settings.monitorMode) {
        checkMonitoredDevices();
      }
    });
  }

  void checkMonitoredDevices() async {
    List<String> deviceNames = [];

    List<Device> monitoredDevices =
        await DatabaseHelper.instance.getMonitoredDevices();

    for (var device in monitoredDevices) {
      BluetoothDeviceConnection? bluetoothConnection =
          await BluetoothServer.instance.requestConnection(
        to: device.address,
        from: PROCESS_TYPE.BACKGROUND,
      );
      if (bluetoothConnection == null) {
        deviceNames.add(device.name);
      }
    }
    if (deviceNames.isNotEmpty) {
      await ring(
          message:
              'Device${deviceNames.length == 1 ? '' : 's'} ${deviceNames.join(", and ")} ${deviceNames.length == 1 ? 'is' : 'are'} Lost!!!');
    }
  }

  Future<void> ring({required String message}) async {
    BuildContext context = GlobalValues.homePage.context;

    if (!_ringing) {
      _ringing = true;

      showDialogueBox(
        context,
        message,
        barrierDismissible: false,
        [
          button('Stop', () {
            stopRinging();
            Navigator.of(context).pop();
          })
        ],
        icon: const Icon(Icons.notifications),
      );
      FlutterRingtonePlayer.playAlarm(volume: 3);
      await NotificationService.instance
          .showNotification(title: 'Lost Devices', body: message);
    }
  }

  void stopBack() {
    try {
      _backGroundTimer!.cancel();
      _backGroundTimer = null;
      print('Stopped');
    } catch (e) {
      print(e);
    }
  }

  void stopRinging() {
    _ringing = false;
    FlutterRingtonePlayer.stop();
  }
}

// final notificationId = 8888;
// const notificationChannelId = 'my_foreground';

// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();

//   await service.configure(
//     iosConfiguration: IosConfiguration(),
//     androidConfiguration: AndroidConfiguration(
//       initialNotificationTitle: "Lost items Tracker",
//       initialNotificationContent: "Service started",
//       onStart: onStart,
//       isForegroundMode: true,
//       autoStartOnBoot: true,
//       autoStart: true,
//     ),
//   );
// }

// @pragma('vm:entry-point')
// void onStart(ServiceInstance serviceInstance) async {
//   DartPluginRegistrant.ensureInitialized();
//   WidgetsFlutterBinding.ensureInitialized();

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   if (serviceInstance is AndroidServiceInstance) {
//     serviceInstance.on('setAsForeground').listen((event) {
//       serviceInstance.setAsForegroundService();
//     });
//     serviceInstance.on('setAsBackground').listen((event) {
//       serviceInstance.setAsBackgroundService();
//     });
//   }
//   // serviceInstance.on('setAsBackground').listen((event) {
//   //   serviceInstance.stopSelf();
//   // });
//   // Timer.periodic(const Duration(minutes: 1), (timer) async {
//   //   if (serviceInstance is AndroidServiceInstance) {
//   //     if (await serviceInstance.isForegroundService()) {
//   //       serviceInstance.setForegroundNotificationInfo(
//   //           title: "Lost device Tracker", content: "My channel");
//   //     }
//   //   }
//   //   print("background servie is running...");

//   //   serviceInstance.invoke(
//   //     'update',
//   //   );
//   // });
// }
