import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projectfbs/components/dashboard.dart';
import 'package:projectfbs/components/menu_list.dart';
import 'package:projectfbs/helper/database_helper.dart';
import 'package:projectfbs/helper/settings.dart';
import 'package:projectfbs/pages/bluetooth_off_screen.dart';
import 'package:projectfbs/pages/notification_page.dart';
import 'package:projectfbs/services/back_services.dart';
import 'package:projectfbs/services/notification_service.dart';
import 'package:projectfbs/widgets/widgets.dart';

import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  await Permission.location.isDenied.then((value) {
    if (value) {
      Permission.location.request();
    }
  });
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  Settings settings = await SettingsHelper.instance.getSettings();
  GlobalValues.instance.setTheme(settings.theme);
  NotificationService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    GlobalValues.instance.setMyApp(this);
  }

  void update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: GlobalValues.instance.theme.copyWith(
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(250, 1, 2, 29),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: Colors.white,
          filled: true,
          labelStyle:
              const TextStyle(color: Color.fromARGB(255, 192, 185, 185)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 30),
          border: OutlineInputBorder(
            borderSide: const BorderSide(width: 5),
            borderRadius: BorderRadius.circular(60),
          ),
        ),
        // switchTheme: SwitchThemeData(
        //   trackColor: MaterialStateProperty.resolveWith<Color>((states) =>
        //       states.contains(MaterialState.disabled)
        //           ? Colors.grey
        //           : Color.fromARGB(255, 147, 173, 147)),
        //   thumbColor: MaterialStateProperty.resolveWith<Color>((states) =>
        //       states.contains(MaterialState.disabled)
        //           ? Colors.grey
        //           : Color.fromARGB(255, 82, 199, 82)),
        // ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            foregroundColor: const MaterialStatePropertyAll(Colors.white),
            backgroundColor: const MaterialStatePropertyAll(Colors.redAccent),
          ),
        ),
        primaryColor: Constants().primaryColor,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
      },
      // home: const MyHomePage(title: 'Lost Items Tracker'),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  final FlutterBluetoothSerial bluetoothSerial =
      FlutterBluetoothSerial.instance;
  BluetoothState bleState = BluetoothState.UNKNOWN;
  @override
  void initState() {
    super.initState();
    bluetoothSerial.onStateChanged().listen((state) {
      bleState = state;
      setState(() {});
    });
    GlobalValues.instance.setHomePage(this);
    try {
      BackgroundProcess.instance.start();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: BluetoothState.UNKNOWN,
      stream: bluetoothSerial.onStateChanged(),
      builder: (context, snapshot) => FutureBuilder(
        future: bluetoothSerial.state,
        builder: (context, snapshot) =>
            (snapshot.data == BluetoothState.STATE_OFF ||
                    snapshot.data == BluetoothState.UNKNOWN)
                ? const BluetoothOffScreen()
                : const MyHomePage(title: 'Lost Items Tracker'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final FlutterBluetoothSerial bluetoothSerial =
      FlutterBluetoothSerial.instance;
  bool backRunning = false;
  Widget currentPage = const Dashboard();

  @override
  void initState() {
    super.initState();
    GlobalValues.instance.setHome(this);
  }

  void setCurrentPage(Widget page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            StreamBuilder(
                stream: DatabaseHelper.instance.getLostDevices().asStream(),
                builder: (context, snapShot) => SizedBox(
                      child: Stack(
                          alignment: AlignmentDirectional(0.5, -1),
                          children: [
                            snapShot.hasData && snapShot.data!.length > 0
                                ? Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle),
                                    child: Text(
                                      '${snapShot.data!.length}',
                                    ),
                                  )
                                : const Text(''),
                            IconButton(
                              onPressed: () {
                                nextScreen(context, const NotificationPage());
                              },
                              icon: const Icon(Icons.notifications),
                            ),
                          ]),
                    ))
          ],
        ),
        drawer: const Drawer(
          width: 260,
          child: SingleChildScrollView(
            child: MenuList(),
          ),
        ),
        body: currentPage);
  }
}

// Test-------------------------------------------------------------------------------------
class First extends StatefulWidget {
  const First({super.key});

  @override
  State<First> createState() => _FirstState();
}

class _FirstState extends State<First> {
  FlutterBluetoothSerial bluetoothSerial = FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;
  StreamSubscription? subscription;
  String receivedData = "";
  String get _data => receivedData;
  @override
  void initState() {
    super.initState();
    connect();
  }

  void connect() async {
    try {
      debugPrint('Connecting...');

      connection = await BluetoothConnection.toAddress('00:21:13:00:FC:ED');
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendData() async {
    print('sending data');
    if (connection == null || !connection!.isConnected) {
      debugPrint('Connecting...');
      try {
        connection = await BluetoothConnection.toAddress('00:21:13:00:FC:ED');
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    try {
      connection!.output.add(ascii.encode('<R>|'));
      connection!.output.allSent;
    } catch (e) {
      print(e);
    }
    // connection!.output.done;
    try {
      subscription = connection!.input!.listen((data) {
        print(receivedData);
        setState(() {
          receivedData = ascii.decode(data).replaceAll('\n', '');
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Received: $_data'),
            Text(_data),
            button("Send Data", () async {
              await sendData();
            }),
            button("Next Page", () {
              nextScreen(context,
                  Second(subscription: subscription!, connection: connection!));
            })
          ],
        )),
      ),
    );
  }
}

class Second extends StatefulWidget {
  const Second(
      {super.key, required this.subscription, required this.connection});
  final StreamSubscription subscription;
  final BluetoothConnection connection;
  @override
  State<Second> createState() => _SecondState();
}

class _SecondState extends State<Second> {
  FlutterBluetoothSerial bluetoothSerial = FlutterBluetoothSerial.instance;
  BluetoothConnection get connection => widget.connection;
  StreamSubscription get subscription => widget.subscription;
  String receivedData = "";
  int times = 0;
  String get _data => receivedData;
  bool ring = true;
  @override
  void initState() {
    super.initState();
  }

  Future<void> sendData() async {
    connection.output.add(ascii.encode(ring ? '<P>|' : '<R>|'));
    connection.output.allSent;
    subscription.onData((data) {
      times++;
      print(times);
      if (times % 2 == 0) {
        setState(() {
          ring = !ring;
          receivedData = ascii.decode(data).replaceAll('\n', '');
        });
        // print(ring);
        print(receivedData);
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Received: $_data'),
            Text(_data),
            button("Send Data", () async {
              await sendData();
            })
          ],
        )),
      ),
    );
  }
}
