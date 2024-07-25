// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:projectfbs/components/table.dart';
import 'package:projectfbs/helper/database_helper.dart';
import 'package:projectfbs/pages/device_login.dart';
import 'package:projectfbs/pages/device_page.dart';
import 'package:projectfbs/widgets/widgets.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  List<List<dynamic>> deviceRows = [];
  List<Device> devices = [];
  @override
  void initState() {
    super.initState();
    DatabaseHelper.instance.getDevices().then((value) {
      devices = value;
      if (mounted) {
        setState(() {});
      }
    }).whenComplete(() => _buildDeviceRows());
  }

  void _buildDeviceRows() {
    for (var device in devices) {
      deviceRows.add([
        Text(device.name),
        Text(device.address),
        Row(
          children: [
            IconButton(
              onPressed: () async {
                showDialogueBox(
                  icon: const Icon(
                    Icons.delete,
                    color: Color.fromARGB(255, 250, 10, 10),
                  ),
                  context,
                  "Do you want to delete this Device?",
                  [
                    button("Cancel", () {
                      Navigator.of(context).pop();
                    }),
                    button("Yes", () async {
                      await DatabaseHelper.instance.remove(device.address);
                      deviceRows = [];
                      setState(() {
                        devices.remove(device);
                      });

                      _buildDeviceRows();
                      popContext(context);
                    })
                  ],
                );
              },
              icon: const Icon(
                Icons.delete,
                color: Color.fromARGB(255, 250, 10, 10),
              ),
            ),
            IconButton(
              onPressed: () async {
                nextScreen(
                  context,
                  DevicePage(device: device),
                );
              },
              icon: const Icon(Icons.edit),
            ),
            button('Find', () {
              nextScreen(
                  context,
                  LoginToDevice(
                      device: BluetoothDevice(
                          address: device.address, name: device.name)));
            })
          ],
        )
      ]);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
      ),
      body: SingleChildScrollView(
        child: devices.isEmpty
            ? nothing("No lost Devices")
            : Tables(
                heading: "Saved Devices",
                heads: const ["Name", 'Address', 'Action'],
                rows: deviceRows,
                maxHeight: 500,
              ),
      ),
    );
  }
}
