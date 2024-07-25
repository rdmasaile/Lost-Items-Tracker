// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:projectfbs/components/search.dart';
import 'package:projectfbs/helper/database_helper.dart';
import 'package:projectfbs/pages/device_login.dart';
import 'package:projectfbs/pages/device_page.dart';
import 'package:projectfbs/pages/devices_page.dart';
import 'package:projectfbs/pages/lost_devices_page.dart';
import 'package:projectfbs/pages/scan_devices.dart';
import 'package:projectfbs/widgets/widgets.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Device> devices = [];
  List<LostDevice> lostDevices = [];
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    DatabaseHelper.instance.getDevices().then((values) {
      if (mounted) {
        setState(() {
          devices = values;
        });
      }
    });
    DatabaseHelper.instance.getLostDevices().then((values) {
      if (mounted) {
        setState(() {
          lostDevices = values;
        });
      }
    });
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      DatabaseHelper.instance.getLostDevices().then((values) {
        if (mounted) {
          setState(() {
            lostDevices = values;
          });
        }
      });
    });
  }

  Widget _buildListDeviceView() {
    List containers = [];
    if (devices.isEmpty) {
      return Container(
        width: double.maxFinite,
        height: 200,
        decoration: const BoxDecoration(
          color: Color.fromARGB(213, 1, 5, 17),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: const Center(
            child: Text(
          "There are no devices.",
          style: TextStyle(color: Colors.white),
        )),
      );
    }
    for (var device in devices.reversed) {
      containers.add(Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: const BoxDecoration(
          color: Color.fromARGB(213, 1, 5, 17),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: ListTile(
          onTap: () {
            nextScreen(
              context,
              DevicePage(
                device: device,
              ),
            );
          },
          onLongPress: () {
            showDialogueBox(
              context,
              "Do you want to delete this Device?",
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              [
                button("Cancel", () {
                  popContext(context);
                }),
                button("Yes", () async {
                  await DatabaseHelper.instance.remove(device.address);
                  setState(() {
                    devices.remove(device);
                  });
                  popContext(context);
                })
              ],
            );
          },
          leading: const Icon(
            Icons.key_sharp,
            color: Colors.white,
          ),
          title: Text(
            device.name,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            device.address,
            style: const TextStyle(color: Colors.white),
          ),
          trailing: button("Find", () {
            nextScreen(
                context,
                LoginToDevice(
                    device: BluetoothDevice(
                        address: device.address, name: device.name)));
          }),
        ),
      ));
    }
    return Column(children: [...containers]);
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 215,
            width: double.maxFinite,
            child: Stack(
              children: [
                Container(
                  height: 150,
                  width: double.maxFinite,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                    color: Color.fromARGB(214, 1, 2, 29),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 90),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 130,
                        width: 110,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3505A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: () => nextScreen(context, const DevicesPage()),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Saved Devices",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              Text(
                                "${devices.length}",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 130,
                        width: 110,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3505A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: () =>
                              nextScreen(context, const LostDevicesPage()),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Lost Devices",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              Text(
                                "${lostDevices.length}",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: const Search(),
                ),
              ],
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Devices",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 25,
                  // color: Color.fromARGB(190, 14, 3, 3),
                ),
              ),
              IconButton(
                  onPressed: () {
                    GlobalValues.instance.setCurrentPage(const ScanDevices());
                  },
                  icon: const Icon(Icons.add))
            ],
          ),
          columnSpace(),
          _buildListDeviceView(),
        ],
      ),
    );
  }
}
