// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:projectfbs/constants.dart';
import 'package:projectfbs/helper/bluetooth_device_connection.dart';
import 'package:projectfbs/server/bluetooth_server.dart';
import 'package:projectfbs/services/back_services.dart';
import 'package:projectfbs/widgets/widgets.dart';

class FindDevice extends StatefulWidget {
  FindDevice({super.key, required this.device, required this.password});
  String? password;
  final BluetoothDevice device;
  @override
  State<FindDevice> createState() => _FindDeviceState();
}

class _FindDeviceState extends State<FindDevice> {
  FlutterBluetoothSerial bluetoothSerial = FlutterBluetoothSerial.instance;
  BluetoothDevice get _bluetoothDevice => widget.device;
  String get _password => widget.password ?? '';
  BluetoothDeviceConnection? deviceConnection;
  bool isConnected = false;
  String _state = 'Connecting...';
  bool _isRinging = true;
  String connectionState = "Connected";
  final PROCESS_TYPE processType = PROCESS_TYPE.PAGE;

  @override
  void initState() {
    super.initState();
    print("${BackgroundProcess.instance.hashCode}.......");
    BackgroundProcess.instance.run = false;
    connect();
  }

  // Future connect() async {
  //   try {
  //     _state = 'Connecting...';
  //     setState(() {});

  //     _connection =
  //         await BluetoothConnection.toAddress(_bluetoothDevice.address);
  //     _state = 'Connected';

  //     GlobalValues.addConnectedDevice(_bluetoothDevice.address);
  //   } catch (e) {
  //     _state = 'Disconnected';
  //     print(e.toString());
  //   }
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  // Future write(String message) async {
  //   try {
  //     if (!_connection!.isConnected) {
  //       await connect();
  //     }
  //     if (_connection!.isConnected) {
  //       _connection!.output.add(ascii.encode(message));
  //       _connection!.output.allSent;

  //       setState(() {
  //         isConnected = _connection!.isConnected;
  //       });
  //       _connection?.input?.listen((Uint8List data) {
  //         print('Data incoming: ${ascii.decode(data)}');

  //         if (ascii.decode(data).contains('1')) {
  //           if (message.contains("<R>")) {
  //             _state = 'Ringing...';
  //           } else {
  //             _state = 'Stopped';
  //           }
  //           _connection!.finish();
  //           setState(() {});
  //         }
  //       }).onDone(() {
  //         print('Disconnected by remote request');
  //         GlobalValues.removeConnectedDevice(_bluetoothDevice.address);
  //       });
  //     }
  //   } catch (exception) {
  //     print(exception.toString());
  //   }
  // }

  // V2 ----------------------------------------

  void connect() async {
    BackgroundProcess.instance.run = false;
    print("${BackgroundProcess.instance.run} if Find device");
    _state = 'Connecting...';
    setState(() {});
    int trials = 0;
    while (trials < 3 && deviceConnection == null) {
      deviceConnection = await BluetoothServer.instance
          .requestConnection(to: _bluetoothDevice.address, from: processType);
      trials++;
    }
    if (deviceConnection == null) {
      _state = 'Cannot connect';

      if (mounted) {
        setState(() {});
      }
      return;
    }
    _state = 'Connected';
    setState(() {});
  }

  void write(String message) async {
    try {
      await BluetoothServer.instance.writeAndListen(
          _bluetoothDevice.address, message, processType, (String data) async {
        if (data.contains('1')) {
          _isRinging = !_isRinging;
        }
      });
    } catch (e) {
      print(e.toString());
    }
    setState(() {});
  }

  @override
  void dispose() {
    if (deviceConnection != null) {
      deviceConnection!.processType = PROCESS_TYPE.UNKNOWN;
    }
    BackgroundProcess.instance.run = true;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Searching for ${_bluetoothDevice.name}")),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 50, child: Center(child: Text(_state))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                SizedBox(
                  child: Icon(
                    Icons.phone_android_sharp,
                    size: 100,
                  ),
                ),
                SizedBox(
                  child: Icon(
                    Icons.phone_bluetooth_speaker_outlined,
                    size: 100,
                  ),
                ),
              ],
            ),
            columnSpace(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                !_isRinging
                    ? button("RING BUZZER", () {
                        write(Command.ringCommand(_password));
                      })
                    : button("STOP BUZZER", () {
                        write(Command.stopCommand());
                      }),
              ],
            )
          ],
        ),
      ),
    );
  }
}
