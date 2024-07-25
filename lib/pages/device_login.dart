// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:projectfbs/constants.dart';
import 'package:projectfbs/helper/bluetooth_helper.dart';
import 'package:projectfbs/pages/find_device.dart';
import 'package:projectfbs/server/bluetooth_server.dart';
import 'package:projectfbs/services/back_services.dart';
import 'package:projectfbs/widgets/widgets.dart';

import '../helper/bluetooth_device_connection.dart';
import '../helper/database_helper.dart';

class LoginToDevice extends StatefulWidget {
  const LoginToDevice({super.key, required this.device});

  final BluetoothDevice device;
  @override
  State<LoginToDevice> createState() => _LoginToDeviceState();
}

class _LoginToDeviceState extends State<LoginToDevice> {
  FlutterBluetoothSerial bluetoothSerial = FlutterBluetoothSerial.instance;
  BluetoothDevice get _bluetoothDevice => widget.device;
  BluetoothDeviceConnection? deviceConnection;
  bool isAuthenticated = false;
  bool isBonded = false;
  bool inProgress = false;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final PROCESS_TYPE processType = PROCESS_TYPE.PAGE;
  bool connectionProgress = true;

  @override
  void initState() {
    super.initState();
    BackgroundProcess.instance.run = false;
    connect();
  }

  // void connect() async {
  //   connectionProgress = true;
  //   setState(() {});
  //   if (connection != null && connection!.isConnected) {
  //     connection!.finish();
  //   }
  //   try {
  //     connection =
  //         await BluetoothConnection.toAddress(_bluetoothDevice.address);
  //     GlobalValues.addConnectedDevice(_bluetoothDevice.address);
  //     setState(() {});

  //   } catch (e) {
  //     connectionProgress = false;
  //     setState(() {});
  //     if (mounted) {
  //       showSnackBar(context, "Cannot connect to ${_bluetoothDevice.name}.",
  //           color: Colors.black87);
  //     }
  //     print(e.toString());
  //   }

  // }

  // Future<void> write() async {
  //   try {
  //     print("writting..");
  //     BluetoothConnection connection =
  //         await BluetoothConnection.toAddress(_bluetoothDevice.address);
  //     connection.output.add(ascii.encode("<R>${passwordController.text}|"));
  //     connection.output.allSent;
  //     inProgress = true;
  //     setState(() {});
  //     connection.input!.listen((Uint8List data) {
  //       print('Data incoming: ${ascii.decode(data)}');
  //       if (ascii.decode(data).contains('1')) {
  //         inProgress = false;
  //         isAuthenticated = true;
  //         connection.finish();
  //         nextScreenReplace(
  //             context,
  //             FindDevice(
  //               device: _bluetoothDevice,
  //               password: passwordController.text,
  //             ));
  //       } else if (ascii.decode(data).contains('0')) {
  //         inProgress = false;
  //         isAuthenticated = false;
  //         connection.finish();

  //         showDialogueBox(context, icon: 'error', "Invalid password entered.", [
  //           button("OK", () {
  //             popContext(context);
  //           })
  //         ]);
  //       }
  //       setState(() {});
  //     });
  //     Future.delayed(const Duration(seconds: 30)).then((value) {
  //       if (inProgress) {
  //         inProgress = false;
  //         isAuthenticated = false;
  //         showDialogueBox(
  //             context,
  //             "Authentication is taking too long.",
  //             icon: const Icon(
  //               Icons.close,
  //               color: Colors.red,
  //             ),
  //             [
  //               button("OK", () {
  //                 popContext(context);
  //               })
  //             ]);
  //         setState(() {});
  //       }
  //     });
  //   } catch (e) {
  //     usernameController.clear();
  //     passwordController.clear();
  //     inProgress = false;
  //     setState(() {});
  //     showDialogueBox(
  //         context,
  //         'Cannot connect to ${_bluetoothDevice.name}.',
  //         icon: 'error',
  //         [
  //           button("Ok", () {
  //             Navigator.of(context).pop();
  //           })
  //         ]);
  //     print(e);
  //   }
  // }

  // V2 ----------------------------------------

  void connect() async {
    connectionProgress = true;
    if (mounted) {
      setState(() {});
    }
    deviceConnection = await BluetoothServer.instance
        .requestConnection(to: _bluetoothDevice.address, from: processType);
    print('IN connect function in Login page;');
    connectionProgress = false;
    if (mounted) setState(() {});

    if (deviceConnection == null) {
      if (mounted) {
        showSnackBar(context, "Cannot connect to ${_bluetoothDevice.name}.",
            color: Colors.black87);
      }
      return;
    }
    showSnackBar(context, "Connected to ${_bluetoothDevice.name}.",
        color: Colors.black87);
  }

  Future<void> write() async {
    print('Writting');
    try {
      // connection.output
      //     .add(ascii.encode(Command.ringCommand(passwordController.text)));
      await deviceConnection!
          .write(Command.ringCommand(passwordController.text));
      await deviceConnection!.listen(listener: (String data) {
        // deviceConnection!.subscription.onData((data) {
        inProgress = false;
        // String data = ascii.decode(message);

        print(data);

        print('after writting');
        print(data);
        if (data.contains('1')) {
          isAuthenticated = true;
          nextScreenReplace(
            context,
            FindDevice(
              device: _bluetoothDevice,
              password: passwordController.text,
            ),
          );
        } else if (data.contains('0')) {
          isAuthenticated = false;
          showDialogueBox(context, icon: 'error', "Invalid password entered.", [
            button("OK", () {
              popContext(context);
            })
          ]);
        }
      });
      isAuthenticated = true;
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        showDialogueBox(
          context,
          'Cannot connect to ${_bluetoothDevice.name}.',
          icon: 'error',
          [
            button("Ok", () {
              popContext(context);
            })
          ],
        );
      }
      print(e.toString());
    }
  }

  void authenticate() async {
    await write();
    print("Authenticated");
  }

  @override
  void dispose() {
    BackgroundProcess.instance.run = true;
    print("Disposing...............");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Log in to ${_bluetoothDevice.name}"),
        actions: [
          connectionProgress
              ? const RefreshProgressIndicator()
              : IconButton(
                  onPressed: () {
                    connect();
                  },
                  icon: const Icon(Icons.refresh),
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: Form(
            child: inProgress
                ? Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("Authenticating..."),
                        SizedBox(height: 10),
                        CircularProgressIndicator()
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Log in",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        style:
                            const TextStyle(fontSize: 20, color: Colors.black),
                        decoration: inputDecoration.copyWith(
                          labelText: "Password",
                          hintText: "",
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Color(0xffee7b64),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            authenticate();
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Log in",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
