import 'package:flutter/material.dart';
import 'package:projectfbs/components/dashboard.dart';
import 'package:projectfbs/components/drawer_header.dart';
import 'package:projectfbs/helper/database_helper.dart';
import 'package:projectfbs/pages/devices_page.dart';
import 'package:projectfbs/pages/lost_devices_page.dart';
import 'package:projectfbs/pages/notification_page.dart';
import 'package:projectfbs/pages/scan_devices.dart';
import 'package:projectfbs/pages/settings_page.dart';
import 'package:projectfbs/widgets/widgets.dart';

class MenuList extends StatefulWidget {
  const MenuList({super.key});

  @override
  State<MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {
  var currentPage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const MyDrawerHeader(),
        const Divider(),
        Container(
          color: currentPage == DrawerSection.dashboard
              ? Colors.grey[300]
              : Colors.transparent,
          child: ListTile(
            onTap: () {
              setState(() {
                currentPage = DrawerSection.dashboard;
              });
              GlobalValues.instance.setCurrentPage(const Dashboard());
            },
            leading: const Icon(Icons.dashboard_rounded),
            title: const Text("Dasboard"),
          ),
        ),
        Container(
          color: currentPage == DrawerSection.addDevices
              ? Colors.grey[300]
              : Colors.transparent,
          child: ListTile(
            onTap: () {
              setState(() {
                currentPage = DrawerSection.addDevices;
              });

              GlobalValues.instance.setCurrentPage(const ScanDevices());
              // setCurrentPage(const ScanDevices());
            },
            leading: const Icon(Icons.app_registration_rounded),
            title: const Text("Add Device"),
          ),
        ),
        Container(
          color: currentPage == DrawerSection.devices
              ? Colors.grey[300]
              : Colors.transparent,
          child: ListTile(
            onTap: () {
              setState(() {
                currentPage = DrawerSection.devices;
              });
              nextScreen(context, const DevicesPage());
            },
            leading: const Icon(Icons.devices),
            title: const Text("Devices"),
          ),
        ),
        Container(
          color: currentPage == DrawerSection.lostDevices
              ? Colors.grey[300]
              : Colors.transparent,
          child: ListTile(
            onTap: () {
              setState(() {
                currentPage = DrawerSection.lostDevices;
              });
              nextScreen(context, const LostDevicesPage());
            },
            leading: const Icon(Icons.devices),
            title: const Text("Lost Devices"),
          ),
        ),
        Container(
          color: currentPage == DrawerSection.notification
              ? Colors.grey[300]
              : Colors.transparent,
          child: ListTile(
            onTap: () {
              setState(() {
                currentPage = DrawerSection.notification;
              });
              nextScreen(context, const NotificationPage());
            },
            leading: const Icon(Icons.notifications),
            title: const Text("Notification"),
          ),
        ),
        Container(
          color: currentPage == DrawerSection.settings
              ? Colors.grey[300]
              : Colors.transparent,
          child: ListTile(
            onTap: () {
              setState(() {
                currentPage = DrawerSection.settings;
              });
              nextScreen(context, const SettingsPage());
            },
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
          ),
        ),
        Container(
          color: currentPage == DrawerSection.devices
              ? Colors.grey[300]
              : Colors.transparent,
          child: ListTile(
            onTap: () async {
              setState(() {
                currentPage = DrawerSection.devices;
              });
              await DatabaseHelper.instance.removeDatabase();
            },
            leading: const Icon(Icons.data_object),
            title: const Text("Delete database"),
          ),
        ),
      ],
    );
  }
}

enum DrawerSection {
  home,
  dashboard,
  addDevices,
  devices,
  lostDevices,
  notification,
  settings,
}
