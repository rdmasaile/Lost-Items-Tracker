import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:projectfbs/components/button.dart';
import 'package:projectfbs/helper/database_helper.dart';
import 'package:projectfbs/pages/map_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<LostDevice> notifiations = [];
  @override
  void initState() {
    super.initState();
    DatabaseHelper.instance.getLostDevices().then((lostDevices) {
      notifiations = lostDevices;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget _buildNotificationList() {
    List containers = [];
    if (notifiations.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
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
              "There are no notifiations.",
              style: TextStyle(color: Colors.white),
            )),
          ),
        ],
      );
    }
    for (var device in notifiations) {
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
            // nextScreen(context, MyMap(device: device));
            MapsLauncher.launchCoordinates(device.latitude, device.longitude);
          },
          onLongPress: () {},
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
          trailing: button("More...", () {}),
        ),
      ));
    }
    return Column(children: [...containers]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: _buildNotificationList(),
    );
  }
}
