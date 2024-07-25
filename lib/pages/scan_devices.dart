// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:projectfbs/helper/database_helper.dart';
import 'package:projectfbs/pages/device_page.dart';
import 'package:projectfbs/widgets/widgets.dart';
import 'package:sqflite/sqflite.dart';

class ScanDevices extends StatefulWidget {
  const ScanDevices({super.key});

  @override
  State<ScanDevices> createState() => _ScanDevicesState();
}

class _ScanDevicesState extends State<ScanDevices> {
  FlutterBluetoothSerial bluetoothSerial = FlutterBluetoothSerial.instance;
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> discoveryResult = [];
  List<BluetoothDevice> connected = [];
  bool isSearching = true;

  void _addToDiscoveredDevices(BluetoothDiscoveryResult result) {
    setState(() {
      final index = discoveryResult.indexWhere(
          (element) => element.device.address == result.device.address);
      if (index >= 0) {
        discoveryResult[index] = result;
      } else {
        discoveryResult.add(result);
      }
      isSearching = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }

  void _startDiscovery() {
    setState(() {
      isSearching = true;
    });
    _streamSubscription = bluetoothSerial.startDiscovery().listen((result) {
      _addToDiscoveredDevices(result);
      print(result);
      if (mounted) {
        setState(() {});
      }
    });
    _streamSubscription!.onDone(() {
      setState(() {
        isSearching = false;
      });
      print("Doonenenee");
    });
  }

  Widget _buildDeviceList() {
    List container = [];

    if (discoveryResult.isEmpty) {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("There are no available devices"),
            ElevatedButton(
              onPressed: () {
                _startDiscovery();
              },
              child: const Text("Refresh"),
            )
          ],
        ),
      );
    }

    for (var result in discoveryResult) {
      container.add(
        Card(
          child: ListTile(
            onTap: () {
              showDialogueBox(
                context,
                "Do you want to save this device?",
                [
                  button('Cancel', () {
                    popContext(context);
                  }),
                  button(
                    'Yes',
                    () async {
                      try {
                        await DatabaseHelper.instance.addDevice(
                          Device(
                            name: result.device.name!,
                            address: result.device.address,
                            addedOn: DateTime.now().toString(),
                            passwordSet: 0,
                          ),
                        );
                        Navigator.of(context).pop();

                        showDialogueBox(
                          context,
                          "Successfully added.",
                          icon: 'success',
                          [
                            button("OK", () {
                              Navigator.of(context).pop();
                              final device = result.device;
                              nextScreen(
                                  context,
                                  DevicePage(
                                      device: Device(
                                          address: device.address,
                                          name: device.name!)));
                            })
                          ],
                        );
                      } on DatabaseException catch (e) {
                        if (e.isUniqueConstraintError()) {
                          Navigator.of(context).pop();
                          showDialogueBox(
                              context,
                              icon: 'error',
                              "Device is already added.",
                              [
                                button("OK", () {
                                  Navigator.of(context).pop();
                                })
                              ]);
                        }
                      } catch (e) {
                        print(e.toString());
                      }
                      if (!result.device.isBonded) {
                        bluetoothSerial
                            .bondDeviceAtAddress(result.device.address);
                      }
                    },
                  )
                ],
              );
            },
            leading: Icon(
              (result.device.type != BluetoothDeviceType.classic)
                  ? Icons.phone_bluetooth_speaker
                  : Icons.devices,
              size: 50,
            ),
            title: Text(result.device.name ?? "Unknown"),
            subtitle: Text(result.device.address),
            trailing: result.device.isBonded
                ? const Icon(Icons.link)
                : const Icon(Icons.link_off),
          ),
        ),
      );
    }
    return ListView(
      children: [...container],
    );
  }

  @override
  void dispose() {
    _streamSubscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          return Future(() => _startDiscovery());
        },
        child: Container(
            child: isSearching
                ? Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("Searching..."),
                        SizedBox(height: 10),
                        CircularProgressIndicator()
                      ],
                    ),
                  )
                : _buildDeviceList()),
      ),
    );
  }
}
