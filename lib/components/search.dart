import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:projectfbs/pages/device_login.dart';
import 'package:projectfbs/pages/device_page.dart';
import '../helper/database_helper.dart';
import '../pages/find_device.dart';
import '../widgets/widgets.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  List<Device> searchedDevices = [];
  bool searching = false;

  Widget _buildListDeviceView(BuildContext context) {
    List containers = [];
    if (searchedDevices.isEmpty) {
      return Container(
        width: double.maxFinite,
        margin: const EdgeInsets.only(top: 41),
        height: 60,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 252, 252, 252),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: const Center(
            child: Text(
          "No devices found.",
          style: TextStyle(color: Colors.black),
        )),
      );
    }
    for (var device in searchedDevices) {
      print(device.toString());
      containers.add(Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: const BoxDecoration(
          color: Color.fromARGB(213, 1, 5, 17),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: ListTile(
          onLongPress: () {
            showDialogueBox(
              context,
              "Do you want to delete this Device?",
              [
                button("Cancel", () {
                  print("Canceled");
                  popContext(context);
                }),
                button("Yes", () {
                  print("Delete");
                  DatabaseHelper.instance.remove(device.address);
                  setState(() {
                    searchedDevices.remove(device);
                  });
                  popContext(context);
                })
              ],
            );
          },
          onTap: () {
            nextScreen(
              context,
              DevicePage(
                device: device,
              ),
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
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(top: 41),
        // height: 200,
        color: Colors.white,
        child: Column(children: [...containers]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextFormField(
          controller: searchController,
          onTapOutside: (event) {
            Future.delayed(const Duration(milliseconds: 500)).then((value) {
              if (mounted) {
                setState(() {
                  searching = false;
                  searchedDevices = [];
                  searchController.clear();
                  searchController.clearComposing();
                });
              }
            });
          },
          onChanged: (value) async {
            searching = true;
            await DatabaseHelper.instance.getDevicesWhere(value).then((value) {
              setState(() {
                searchedDevices = value;
              });
            });
            if (value.isEmpty) {
              setState(() {
                searchedDevices = [];
              });
            }
          },
          style: const TextStyle(fontSize: 20, color: Colors.black),
          decoration: inputDecoration.copyWith(
            labelText: "Search",
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        (searching) ? _buildListDeviceView(context) : const Text(""),
      ],
    );
  }
}
