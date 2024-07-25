import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:projectfbs/widgets/widgets.dart';

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: Center(
          child: Column(
            children: [
              columnSpace(height: 100),
              const Text(
                "OOPS!!!",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
              ),
              const Text(
                "Turn on Bluetooth!",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 30),
              ),
              columnSpace(height: 150),
              const Text(
                "BLUETOOTH IS OFF",
                style: TextStyle(color: Colors.redAccent),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FlutterBluetoothSerial.instance.requestEnable();
                },
                child: const Text("Turn On"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
