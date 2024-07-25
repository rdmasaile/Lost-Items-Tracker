import 'dart:convert';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothHelper {
  final FlutterBluetoothSerial _bluetoothSerial =
      FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;
  BluetoothHelper._();
  static final BluetoothHelper instance = BluetoothHelper._();

  Future connect(BluetoothDevice bluetoothDevice) async {
    await _bluetoothSerial.getBondedDevices().then((value) {
      for (var device in value) {
        if (bluetoothDevice.address == device.address) {
          bluetoothDevice = device;
          break;
        }
      }
    });

    _connection = await BluetoothConnection.toAddress(bluetoothDevice.address);
    return _connection;
  }

  Future write(String data) async {
    if (_connection == null) {
      throw Exception("No connection Instance in Write function");
    }
    _connection!.output.add(ascii.encode(data));
    await _connection!.output.allSent;
  }

  Future<String> listen() async {
    String receivedData = '0';
    _connection!.input!.listen((data) {
      receivedData = ascii.decode(data);
    });
    print(receivedData);
    return receivedData;
  }

  void disconnect() {
    if (_connection == null) {
      throw Exception("No connection Instance");
    }
    _connection!.close();
    _connection!.dispose();
  }
}
