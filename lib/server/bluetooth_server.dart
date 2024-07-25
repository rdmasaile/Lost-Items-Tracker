import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:projectfbs/constants.dart';
import 'package:projectfbs/helper/bluetooth_device_connection.dart';

class BluetoothServer {
  final List<BluetoothDeviceConnection> _connectedDevices = [];
  BluetoothServer._();
  static final BluetoothServer _instance = BluetoothServer._();
  static BluetoothServer get instance => _instance;

  Future<BluetoothDeviceConnection?> _connect(
      String address, PROCESS_TYPE from) async {
    try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(address);
      debugPrint('IN connect function in server;');
      BluetoothDevice bluetoothDevice = BluetoothDevice(address: address);
      StreamSubscription subscription = connection.input!.listen((event) {});
      _connectedDevices.add(BluetoothDeviceConnection(
          device: bluetoothDevice,
          connection: connection,
          subscription: subscription));
      if (from == PROCESS_TYPE.PAGE) {
        _connectedDevices.last.processType = from;
      }
      return _connectedDevices.last;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<BluetoothDeviceConnection?> requestConnection(
      {required String to, required PROCESS_TYPE from}) async {
    BluetoothDeviceConnection? deviceConnection = find(to);
    debugPrint("IN request connection function");
    if (deviceConnection != null && isConnected(to)) {
      if (from == PROCESS_TYPE.PAGE) {
        deviceConnection.processType = from;
      }
      return deviceConnection;
    }

    return await _connect(to, from);
  }

  Future writeAndListen(
      String to, String message, from, Function callback) async {
    BluetoothDeviceConnection? deviceConnection =
        await requestConnection(to: to, from: from);
    if (deviceConnection == null) {
      throw Exception("Cannot connect to this device!");
    }

    await deviceConnection.write(message);

    await deviceConnection.listen(listener: callback);
  }

  BluetoothDeviceConnection? find(String address) {
    for (var deviceConnection in _connectedDevices) {
      if (deviceConnection.device.address == address) {
        return deviceConnection;
      }
    }
    return null;
  }

  Future terminateConnectionTo(String address) async {
    BluetoothDeviceConnection? deviceConnection = find(address);
    if (deviceConnection == null) {
      return;
    }
    await deviceConnection.connection.finish();
    _connectedDevices.remove(deviceConnection);
    debugPrint('Terminated successfully');
  }

  Future<BluetoothDeviceConnection?> refreshConnection(
      String address, PROCESS_TYPE from) async {
    terminateConnectionTo(address);
    return await requestConnection(to: address, from: from);
  }

  bool checkIfThere(String address) {
    BluetoothDeviceConnection deviceConnection = find(address)!;
    if (deviceConnection.device.isConnected) {
      return true;
    }
    _connectedDevices.remove(deviceConnection);
    return false;
  }

  bool isConnected(String address) {
    BluetoothDeviceConnection? deviceConnection = find(address);
    if (deviceConnection == null) {
      return false;
    }
    if (deviceConnection.device.isConnected ||
        deviceConnection.connection.isConnected) {
      return true;
    } else {
      deviceConnection.connection.dispose();
      _connectedDevices.remove(deviceConnection);
      return false;
    }
  }
}
