import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:projectfbs/components/table.dart';
import 'package:projectfbs/helper/database_helper.dart';
import 'package:projectfbs/pages/device_login.dart';
import 'package:projectfbs/pages/device_page.dart';
import 'package:projectfbs/widgets/widgets.dart';

class LostDevicesPage extends StatefulWidget {
  const LostDevicesPage({super.key});

  @override
  State<LostDevicesPage> createState() => _LostDevicesPageState();
}

class _LostDevicesPageState extends State<LostDevicesPage> {
  List<List<dynamic>> deviceRows = [];
  List<LostDevice> lostDevices = [];
  @override
  void initState() {
    super.initState();
    DatabaseHelper.instance.getLostDevices().then((value) {
      lostDevices = value;
      if (mounted) {
        setState(() {});
      }
    }).whenComplete(() => _buildDeviceRows());
  }

  void _buildDeviceRows() {
    for (var device in lostDevices) {
      deviceRows.add([
        Text(device.name),
        Text(device.address),
        Text(device.lostAt),
        Row(
          children: [
            IconButton(
              onPressed: () async {
                nextScreen(
                  context,
                  DevicePage(device: Device(address: device.address)),
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
        title: const Text('Lost Devices'),
      ),
      body: SingleChildScrollView(
        child: lostDevices.isEmpty
            ? nothing("No lost Devices")
            : Tables(
                heading: "Lost Devices",
                heads: const ["Name", 'Address', 'Lost on', 'Action'],
                rows: deviceRows,
                maxHeight: 500,
              ),
      ),
    );
  }
}
