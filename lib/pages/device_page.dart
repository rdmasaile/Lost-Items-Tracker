// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:projectfbs/constants.dart';
import 'package:projectfbs/helper/bluetooth_device_connection.dart';
import 'package:projectfbs/helper/database_helper.dart';
import 'package:projectfbs/server/bluetooth_server.dart';
import 'package:projectfbs/services/back_services.dart';
import 'package:projectfbs/widgets/widgets.dart';

class DevicePage extends StatefulWidget {
  DevicePage({super.key, required this.device});
  Device device;
  @override
  State<DevicePage> createState() => _DeviceState();
}

class _DeviceState extends State<DevicePage> {
  Device get device => widget.device;
  LostDevice? _lostDeviceData;
  bool get isPasswordSet => isLoading ? false : device.isPasswordSet;
  BluetoothConnection? connection;
  BluetoothDeviceConnection? deviceConnection;
  bool monitorMode = false;
  // Future<bool> get isMonitored async =>
  //     await DatabaseHelper.instance.checkIfThere(device.address,
  //         DatabaseHelper.instance.moniteredDevicesTable);
  Timer? updateTimer;
  String get lostOn {
    if (isLoading) {
      return '1 sec';
    }
    try {
      DateTime lostDate = DateTime.parse(_lostDeviceData!.lostAt);
      Duration duration = DateTime.now().difference(lostDate);
      if (duration.inSeconds < 60) {
        return "<1 min";
      } else if (duration.inMinutes < 60) {
        return "${duration.inMinutes} min";
      } else if (duration.inHours < 24) {
        return "${duration.inHours} hrs";
      } else if (duration.inDays < 7) {
        return "${duration.inDays} days";
      } else {
        return '${lostDate.day}-0${lostDate.month}-${lostDate.year}';
      }
    } catch (e) {
      return '';
    }
  }

  bool isInRange = false;
  bool isLoading = true;
  final PROCESS_TYPE processType = PROCESS_TYPE.PAGE;

  bool get isConnected => (deviceConnection?.connection.isConnected ?? false);

  TextEditingController newPasswordController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController contactsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    BackgroundProcess.instance.run = false;
    loadDeviceData();
    DatabaseHelper.instance
        .checkIfThere(
            device.address, DatabaseHelper.instance.moniteredDevicesTable)
        .then((value) {
      monitorMode = value;
      if (mounted) {
        setState(() {});
      }
    });
    connect();
    updateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      loadDeviceData();
    });
  }

  void loadDeviceData() async {
    final device =
        await DatabaseHelper.instance.getDeviceWhere(widget.device.address);
    if (device != null) {
      widget.device.name = device.name;
      widget.device = device;
    }
    _lostDeviceData =
        await DatabaseHelper.instance.getLostDeviceWhere(widget.device.address);
    widget.device.name = device!.name;
    isInRange = await DatabaseHelper.instance
        .checkIfThere(device.address, DatabaseHelper.instance.lostDevicesTable);
    if (_lostDeviceData == null) {
      Position location = await Geolocator.getCurrentPosition();
      _lostDeviceData = LostDevice(
          address: device.address,
          longitude: location.longitude,
          latitude: location.latitude,
          lostAt: DateTime.now().toString());
    }
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }
  // V2 ----------------------------------------

  void connect() async {
    deviceConnection = await BluetoothServer.instance
        .requestConnection(to: device.address, from: processType);
    debugPrint('IN connect function in Login page;');
    if (mounted) {
      setState(() {});
    }

    if (deviceConnection == null) {
      if (mounted) {
        showSnackBar(context, "Cannot connect to ${device.name}.",
            color: const Color.fromARGB(200, 1, 2, 29));
      }
      return;
    }
    if (mounted) {
      setState(() {
        showSnackBar(context, "Connected to ${device.name}.",
            color: const Color.fromARGB(200, 1, 2, 29));
      });
    }
  }

  Future<void> disconnect() async {
    isConnected;
    await BluetoothServer.instance.terminateConnectionTo(device.address);
    if (mounted) {
      showSnackBar(context, "Cannot connect to ${device.name}.",
          color: const Color.fromARGB(200, 1, 2, 29));

      setState(() {});
    }
  }

  Future<void> write() async {
    try {
      BluetoothServer.instance.writeAndListen(
          device.address,
          isPasswordSet
              ? Command.changePinCommand(
                  "${oldPasswordController.text}/${newPasswordController.text}")
              : Command.changePinCommand(newPasswordController.text),
          processType, (String data) async {
        if (data.contains('1')) {
          try {
            if (!isPasswordSet) {
              device.passwordSet = 1;
              await DatabaseHelper.instance.updateD(device);
            }
          } catch (e) {
            print(e.toString());
          }
          showDialogueBox(
              context,
              "Successfully Registered.",
              icon: 'success',
              [
                button('OK', () {
                  popContext(context);
                })
              ]);
        } else if (data.contains('0')) {
          showDialogueBox(context, "Old Password is invalid.", icon: 'error', [
            button('OK', () {
              popContext(context);
            })
          ]);
          setState(() {});
        }
      });
      setState(() {});
    } catch (e) {
      showDialogueBox(
        context,
        e.toString(),
        icon: 'error',
        [
          button('OK', () {
            popContext(context);
          })
        ],
      );
      setState(() {});
    }
  }

  void validate() async {
    if (_formKey.currentState!.validate()) {
      //Register to the device
      await write();
      print("REGISTER");
    }
  }

  @override
  void dispose() {
    BackgroundProcess.instance.run = true;
    if (updateTimer != null) {
      updateTimer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(188, 1, 2, 29),
        title: Text(device.name),
        actions: [
          (isConnected)
              ? button("Disconnect", () async {
                  await disconnect();
                })
              : button("Connect", () {
                  connect();
                }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 150,
              width: double.maxFinite,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(40),
                ),
                color: Color.fromARGB(214, 1, 2, 29),
              ),
              child: Column(
                children: [
                  SizedBox(
                    child: ListTile(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        contentPadding: const EdgeInsets.all(5),
                        leading: Container(
                          // margin: const EdgeInsets.only(left: 30),
                          child: const Icon(
                            Icons.devices,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(device.name,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(device.address,
                            style: const TextStyle(color: Colors.white)),
                        trailing: iconButton(Icons.edit, () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                TextEditingController name =
                                    TextEditingController();
                                name.text = device.name;
                                return AlertDialog(
                                  title: const Text('Edit name'),
                                  content: SizedBox(
                                    height: 50,
                                    child: Column(children: [
                                      TextField(
                                        controller: name,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        decoration: inputDecoration,
                                      )
                                    ]),
                                  ),
                                  actions: [
                                    button('Cancel', () {
                                      popContext(context);
                                    }),
                                    button('Save', () async {
                                      device.name = name.text.trim();
                                      await DatabaseHelper.instance
                                          .updateD(device);
                                      setState(() {});
                                      popContext(context);
                                    }),
                                  ],
                                );
                              });
                        })),
                  ),
                  columnSpace(),
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Status   ',
                          style: TextStyle(color: Colors.white),
                        ),
                        const Text(
                          '|   ',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 23),
                        ),
                        Text(isConnected ? 'In Range' : 'Lost',
                            style: TextStyle(
                                color: isConnected
                                    ? const Color.fromARGB(255, 38, 243, 10)
                                    : Colors.redAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ],
              ),
            ),
            columnSpace(),
            Container(
              height: 80,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Color.fromARGB(214, 1, 2, 29),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Added on",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(isLoading ? '' : formatDateTime(device.addedOn),
                          style: const TextStyle(color: Colors.white))
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Lost on",
                          style: TextStyle(color: Colors.white)),
                      Text(lostOn, style: const TextStyle(color: Colors.white))
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      MapsLauncher.launchCoordinates(_lostDeviceData!.latitude,
                          _lostDeviceData!.longitude);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("Location", style: TextStyle(color: Colors.white)),
                        Icon(
                          Icons.location_on,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              title: Text('Monitor mode'),
              value: monitorMode,
              // selected: monitorMode,
              onChanged: (value) async {
                monitorMode = value;

                if (monitorMode) {
                  print("Adding");
                  await DatabaseHelper.instance.addMonitoredDevice(
                      MonitoredDevice(address: device.address));
                } else {
                  print("Removing");
                  await DatabaseHelper.instance
                      .remove(device.address, table: "monitored_devices");
                }
                setState(() {});
              },
            ),
            button('Register', () {
              showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(builder: (context, setState) {
                    return AlertDialog(
                      title: Column(
                        children: const [
                          Text(
                            "Add Password",
                            textAlign: TextAlign.center,
                          ),
                          Divider(),
                        ],
                      ),
                      content: SizedBox(
                        height: 400,
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                columnSpace(),
                                TextFormField(
                                  controller: oldPasswordController,
                                  obscureText: true,
                                  enabled: isPasswordSet,
                                  validator: (value) {
                                    return value!.isEmpty
                                        ? "Password should not be empty"
                                        : value.length < 8
                                            ? "Password should not be less than 8 characters"
                                            : null;
                                  },
                                  style: const TextStyle(color: Colors.black),
                                  decoration: inputDecoration.copyWith(
                                    labelText: "Old Password",
                                    prefixIcon: const Icon(
                                      Icons.lock,
                                      color: Color(0xffee7b64),
                                    ),
                                  ),
                                ),
                                columnSpace(),
                                TextFormField(
                                  controller: newPasswordController,
                                  obscureText: true,
                                  validator: (value) {
                                    return value!.isEmpty
                                        ? "Password should not be empty"
                                        : value.length < 8
                                            ? "Password should not be less than 8 characters"
                                            : null;
                                  },
                                  style: const TextStyle(color: Colors.black),
                                  decoration: inputDecoration.copyWith(
                                    labelText: "New Password",
                                    prefixIcon: const Icon(
                                      Icons.lock,
                                      color: Color(0xffee7b64),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        button('Cancel', () {
                          popContext(context);
                        }),
                        button('Add', () {
                          validate();
                          setState(() {});
                        }),
                      ],
                    );
                  });
                },
              );
            }),
            columnSpace(),
            button('Add Contacts', () {
              showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(builder: (context, setState) {
                    return AlertDialog(
                      title: Column(
                        children: const [
                          Text(
                            "Add Contact details",
                            textAlign: TextAlign.center,
                          ),
                          Divider(),
                        ],
                      ),
                      content: SizedBox(
                        height: 165,
                        width: 165,
                        child: Form(
                          key: _formKey1,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: contactsController,
                                validator: (value) {
                                  return value!.isEmpty
                                      ? "Contacts should not be empty"
                                      : value.length != 8
                                          ? "Contacts should have 8 characters"
                                          : null;
                                },
                                style: const TextStyle(color: Colors.black),
                                decoration: inputDecoration.copyWith(
                                  labelText: "Contacts",
                                  prefixText: '+266 ',
                                  prefixIcon: const Icon(
                                    Icons.phone,
                                    color: Color(0xffee7b64),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        button('Cancel', () {
                          popContext(context);
                        }),
                        button('Add', () {
                          validateContacts();
                          setState(() {});
                        }),
                      ],
                    );
                  });
                },
              );
            }),
            columnSpace(),
          ],
        ),
      ),
    );
  }

  void validateContacts() {
    if (_formKey1.currentState!.validate()) {
      try {
        BluetoothServer.instance.writeAndListen(
            device.address,
            Command.addContactsCommand(contactsController.text),
            processType, (String data) async {
          if (data.contains('1')) {
            showDialogueBox(context, "Successfully Added.", icon: 'success', [
              button('OK', () {
                popContext(context);
              })
            ]);
          } else if (data.contains('0')) {
            showDialogueBox(
                context,
                "An Error occured. Please check the connection.",
                icon: 'error',
                [
                  button('OK', () {
                    popContext(context);
                  })
                ]);
            setState(() {});
          }
        });
      } catch (e) {
        print(e);
        showDialogueBox(
            context,
            "An Error occured. Please check the connection.",
            icon: 'error',
            [
              button('OK', () {
                popContext(context);
              })
            ]);
        setState(() {});
      }
    }
  }
}
