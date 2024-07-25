import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:projectfbs/helper/settings.dart';
import 'package:projectfbs/services/back_services.dart';
import 'package:projectfbs/widgets/widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Settings? _settings;
  THEME theme = THEME.dark;
  bool? monitorMode = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  void loadSettings() {
    SettingsHelper.instance.getSettings().then((value) {
      _settings = value;
      theme = _settings!.theme;
      monitorMode = _settings!.monitorMode;
      setState(() {});
    });
  }

  Future<void> updateTheme() async {
    _settings!.theme = theme;
    await SettingsHelper.instance.write(_settings!);
    loadSettings();
    GlobalValues.instance.setTheme(theme);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Container(
        padding: const EdgeInsets.all(7),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          h("General"),
          columnSpace(),
          ListTile(
            onTap: () {
              FlutterBluetoothSerial.instance.openSettings();
            },
            title: const Text("Bluetooth settings"),
            trailing: const Icon(Icons.settings),
          ),
          ListTile(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(builder: (context, setState) {
                    return AlertDialog(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      title: const Text("Theme"),
                      content: SizedBox(
                        height: 120,
                        child: Column(
                          children: [
                            const Divider(),
                            RadioMenuButton(
                              value: THEME.dark,
                              groupValue: theme,
                              onChanged: (value) async {
                                theme = value!;
                                await updateTheme();
                                setState(() {});
                                popContext(context);
                              },
                              child: const Text("Dark"),
                            ),
                            RadioMenuButton(
                              value: THEME.light,
                              groupValue: theme,
                              onChanged: (value) {
                                theme = value!;
                                updateTheme();
                                setState(() {});
                                popContext(context);
                              },
                              child: const Text("White"),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              );
            },
            title: const Text("Theme"),
            trailing: const Icon(Icons.color_lens),
          ),
          const Divider(),
          h("Services"),
          columnSpace(),
          SwitchListTile(
            value: monitorMode!,
            onChanged: (value) async {
              _settings!.monitorMode = value;
              await SettingsHelper.instance.write(_settings!);
              loadSettings();
              setState(() {});
            },
            title: const Text("Monitor Devices"),
          ),
          ListTile(
            onTap: () {},
            title: const Text("Backgroud Process"),
            trailing: BackgroundProcess.instance.isRunning
                ? iconButton(Icons.stop, () {
                    showDialogueBox(
                      context,
                      "By stopping background process will prevent you from getting locations where the devices got lost and no Notifications will be rendered!",
                      icon: const Icon(
                        Icons.warning_amber,
                        color: Colors.amber,
                      ),
                      [
                        button("Cancel", () {
                          popContext(context);
                        }),
                        button("OK", () {
                          BackgroundProcess.instance.run =
                              !BackgroundProcess.instance.run;
                          setState(() {});
                          popContext(context);
                        })
                      ],
                    );

                    setState(() {});
                  })
                : iconButton(Icons.play_arrow, () {
                    BackgroundProcess.instance.run =
                        !BackgroundProcess.instance.run;
                    setState(() {});
                  }),
          ),
        ]),
      ),
    );
  }
}

enum THEME {
  dark,
  light,
}
