import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projectfbs/pages/settings_page.dart';

// class Setting {
//   String name;
//   String value;

//   Setting({required this.name, required this.value});
//   factory Setting.fromString(String str) {
//     List list = str.split("=");
//     return Setting(name: list[0], value: list[1]);
//   }
//   @override
//   String toString() {
//     return "$name=$value";
//   }
// }

// class Settings {
//   static File? _file;
//   static List<Setting> _settings = [];

//   Settings._();
//   static final Settings instance = Settings._();

//   File get file => _file ?? initFile();

//   List<Setting> get settings => _settings.isEmpty ? _read() : _settings;

//   Future<String> get filePath async {
//     final dir = await getApplicationDocumentsDirectory();
//     return dir.path;
//   }

//   File initFile() {
//     filePath.then((path) {
//       _file = File(path);
//     });
//     return _file!;
//   }

//   List<Setting> _read() {
//     if (!file.existsSync()) {
//       file.writeAsStringSync("back=1\ntheme=dark");
//     }
//     for (String line in file.readAsLinesSync()) {
//       _settings.add(Setting.fromString(line));
//     }
//     return _settings;
//   }

//   void update(key, value) {
//     for (Setting setting in instance.settings) {
//       if (setting.name == key) {
//         setting.value = value;
//         break;
//       }
//     }
//     instance.write();
//   }

//   void write() {
//     String ss = "";
//     for (Setting setting in instance.settings) {
//       ss += setting.toString() + "\n";
//     }
//     instance.file.writeAsStringSync(ss);
//   }
// }

class Settings {
  THEME theme;
  bool monitorMode;

  Settings({required this.theme, required this.monitorMode});
  factory Settings.fromMap(Map<String, dynamic> json) {
    return Settings(
        theme: stringToTheme(json["theme"]), monitorMode: json["monitor_mode"]);
  }
  Map<String, dynamic> toMap() {
    return {
      "monitor_mode": monitorMode,
      "theme": themeToString(),
    };
  }

  String themeToString() {
    if (theme == THEME.dark) {
      return 'dark';
    } else {
      return 'light';
    }
  }
}

THEME stringToTheme(String theme) {
  if (theme == 'dark') {
    return THEME.dark;
  } else {
    return THEME.light;
  }
}

class SettingsHelper {
  // static File? file;
  SettingsHelper._();
  static final SettingsHelper _instance = SettingsHelper._();
  static final SettingsHelper instance = _instance;

  Future<File> get _file async => await _initFile();

  Future<String> get filePath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> _initFile() async {
    String path = await filePath;
    return File("$path/settings.json");
  }

  Future<Settings> getSettings() async {
    Settings? settings = await read();
    if (settings == null) {
      await write(Settings(theme: THEME.dark, monitorMode: true));
      settings = await read();
      print(settings.toString());
    }
    return settings!;
  }

  Future<Settings?> read() async {
    try {
      File file = await _file;
      Map<String, dynamic> json = jsonDecode(await file.readAsString());
      return Settings.fromMap(json);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> write(Settings settings) async {
    File file = await _file;
    await file.writeAsString(jsonEncode(settings.toMap()));
  }
}
