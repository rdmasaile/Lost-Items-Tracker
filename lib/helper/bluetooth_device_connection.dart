import 'dart:async';
import 'dart:convert';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:projectfbs/constants.dart';

class BluetoothDeviceConnection {
  final BluetoothDevice device;
  final BluetoothConnection connection;
  final StreamSubscription subscription;
  PROCESS_TYPE processType = PROCESS_TYPE.UNKNOWN;

  BluetoothDeviceConnection(
      {required this.device,
      required this.connection,
      required this.subscription});

  Future<void> write(String message) async {
    connection.output.add(ascii.encode(message));
    connection.output.allSent;
  }

  Future<void> listen({required Function listener}) async {
    print('IN Listner');

    try {
      subscription.onData((data) {
        listener(ascii.decode(data));
      });
    } catch (e) {
      print(e);
    }
  }

  Future<String> getData() async {
    String receivedData = "";
    try {
      subscription.onData((data) {
        receivedData = ascii.decode(data);
      });
    } catch (e) {
      print(e);
    }

    return Future.value(receivedData);
  }

  Future<String> writeAndListen(String message, Function listener) async {
    try {
      await write(message);

      await listen(listener: listener);
    } catch (e) {
      print(e);
    }
    return "";
  }
}
