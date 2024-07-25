import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projectfbs/constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

abstract class Table {
  get address => null;

  Map<String, dynamic> toMap();
}

class Device {
  String name;
  String address;
  String? imagePath;
  String addedOn;
  int passwordSet;

  bool get isPasswordSet => passwordSet == 1;

  Device({
    this.name = 'Unknown',
    required this.address,
    this.imagePath,
    this.addedOn = '2023-08-01',
    this.passwordSet = 0,
  });

  factory Device.fromMap(Map<String, dynamic> json) => Device(
        name: json['name'],
        address: json['address'],
        imagePath: json['image_path'],
        addedOn: json['added_on'],
        passwordSet: json['password_set'],
      );

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'image_path': imagePath,
      'added_on': addedOn,
      'password_set': passwordSet,
    };
  }

  Map<String, dynamic> toMapFromSubclass() {
    return {
      'name': name,
      'address': address,
      'image_path': imagePath,
      'added_on': addedOn,
      'password_set': passwordSet,
    };
  }
}

class MonitoredDevice extends Device {
  MonitoredDevice({required address}) : super(address: address);

  factory MonitoredDevice.fromMap(Map<String, dynamic> json) =>
      MonitoredDevice(address: json['address']);

  @override
  Map<String, dynamic> toMap() {
    return {'address': address};
  }
}

class LostDevice extends Table {
  String address;
  String name;
  double longitude;
  double latitude;
  String lostAt;

  LostDevice({
    required this.address,
    required this.longitude,
    required this.latitude,
    required this.lostAt,
    this.name = '',
  });

  factory LostDevice.fromMap(Map<String, dynamic> json) => LostDevice(
        address: json['address'],
        longitude: num.parse(json['longitude']).toDouble(),
        latitude: num.parse(json['latitude']).toDouble(),
        lostAt: json['lost_at'],
      );

  @override
  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'lost_at': lostAt,
    };
  }
}

class DatabaseHelper {
  String devicesTable = 'devices';
  String moniteredDevicesTable = 'monitored_devices';
  String lostDevicesTable = 'lost_devices';

  DatabaseHelper._privateConstructer();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructer();

  static Database? _database;

  Future<Database> get database async => _database ?? await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    // deleteDatabase(join(documentsDirectory.path, 'devices.db'));

    String path = join(documentsDirectory.path, 'devices.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future removeDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    deleteDatabase(join(documentsDirectory.path, 'devices.db'));
    print("Database deleted");
  }

  Future _onCreate(Database db, int version) async {
    print("Create database");
    await db.execute('''
          CREATE TABLE devices ( 
            name VARCHAR(100),
            address VARCHAR(30) PRIMARY KEY, 
            image_path TEXT,
            password_set BOOLEAN,
            added_on TIMESTAMP
          );
          ''');
    await db.execute('''
        CREATE TABLE monitored_devices(
          address VARCHAR(30) PRIMARY KEY
        );
      ''');
    await db.execute('''
      CREATE TABLE lost_devices(
        address VARCHAR(30) PRIMARY KEY,
        longitude VARCHAR(100),
        latitude VARCHAR(50),
        lost_at TIMESTAMP
      )
      ''');
    // await db.execute(
    //     '''ALTER TABLE `lost_devices` ADD CONSTRAINT `fk_for_devices` FOREIGN KEY (`address`) REFERENCES `devices`(`address`) ON DELETE RESTRICT ON UPDATE RESTRICT;''');
  }

  Future<List<Device>> getDevices() async {
    Database db = await instance.database;
    var devices = await db.query('devices');
    List<Device> deviceList = devices.isNotEmpty
        ? devices.map((device) => Device.fromMap(device)).toList()
        : [];
    return deviceList;
  }

  Future<LostDevice?> getLostDeviceWhere(String address) async {
    Database db = await instance.database;
    var devices = await db.query(lostDevicesTable,
        where: 'address = ?', whereArgs: [address], limit: 1);
    List<LostDevice> lostDevicesList = devices.isNotEmpty
        ? devices.map((device) => LostDevice.fromMap(device)).toList()
        : [];
    try {
      return lostDevicesList.firstWhere((device) => device.address == address);
    } catch (e) {
      return null;
    }
  }

  Future<Device?> getDeviceWhere(String address) async {
    Database db = await instance.database;
    var devices = await db.query('devices',
        where: 'address = ?', whereArgs: [address], limit: 1);
    List<Device> deviceList = devices.isNotEmpty
        ? devices.map((device) => Device.fromMap(device)).toList()
        : [];
    try {
      return deviceList.firstWhere((device) => device.address == address);
    } catch (e) {
      return null;
    }
  }

  Future<List<LostDevice>> getLostDevices() async {
    Database db = await instance.database;
    var devices = await getDevices();
    var ldevices = await db.query('lost_devices');
    List<LostDevice> lostDeviceList = ldevices.isNotEmpty
        ? ldevices.map((ldevice) => LostDevice.fromMap(ldevice)).toList()
        : [];
    for (var ldevice in lostDeviceList) {
      try {
        Device device = devices.firstWhere(
          (device) => device.address == ldevice.address,
        );
        ldevice.name = device.name;
      } catch (e) {
        print(e.toString());
      }
    }
    return lostDeviceList;
  }

  Future<List<Device>> getDevicesWhere(String name) async {
    Database db = await instance.database;
    List devices = await db.query('devices', where: 'name LIKE "%$name%"');
    List<Device> deviceList = devices.isNotEmpty
        ? devices.map((device) => Device.fromMap(device)).toList()
        : [];
    return deviceList;
  }

  Future<MonitoredDevice> getMonitoredDeviceWhere(String address) async {
    Database db = await instance.database;
    List device = await db.query("monitored_devices",
        where: "address = ?", whereArgs: [address], distinct: true);
    return device.first;
  }

  Future<List<Device>> getMonitoredDevices() async {
    Database db = await instance.database;
    List<Device> devices = await getDevices();
    List mdevices = await db.query('monitored_devices');
    List<MonitoredDevice> deviceList = devices.isNotEmpty
        ? mdevices.map((device) => MonitoredDevice.fromMap(device)).toList()
        : [];
    List<Device> monitoredDevices = [];
    for (var mdevice in deviceList) {
      monitoredDevices.add(
          devices.firstWhere((device) => device.address == mdevice.address));
    }
    return monitoredDevices;
  }

  Future addDevice(Device device) async {
    Database db = await instance.database;
    try {
      return db.insert('devices', device.toMap());
    } catch (e) {
      print(e.toString());
    }
  }

  Future updateD(Device device) async {
    Database db = await instance.database;

    try {
      int res = await db.update(
        devicesTable,
        device.toMap(),
        where: 'address=?',
        whereArgs: [device.address],
      );
      print(res);
      print("Updated..........");
    } catch (e) {
      print(e);
    }
  }

  Future updateDevice(Device device, {String? table}) async {
    Database db = await instance.database;
    try {
      db.update(
        table ?? devicesTable,
        device.toMap(),
        where: "address = ${device.address}",
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future addMonitoredDevice(MonitoredDevice device) async {
    Database db = await instance.database;
    try {
      return db.insert('monitored_devices', device.toMap());
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> checkIfThere(String key, String table) async {
    List devices = [];
    bool found = false;
    if (table == lostDevicesTable) {
      devices = await getLostDevices();
    } else if (table == moniteredDevicesTable) {
      devices = await getMonitoredDevices();
    } else if (table == devicesTable) {
      devices = await getDevices();
    }
    for (var device in devices) {
      if (device.address == key) {
        found = true;
        break;
      }
    }
    return found;
  }

  Future addLostDevice(LostDevice device) async {
    Database db = await instance.database;
    bool found = await checkIfThere(device.address, 'lost_devices');
    if (found) {
      return;
    }
    try {
      return db.insert('lost_devices', device.toMap());
    } catch (e) {
      print(e.toString());
    }
  }

  Future remove(String address, {String table = 'devices'}) async {
    Database db = await instance.database;
    if (table == devicesTable) {
      await db.delete(moniteredDevicesTable,
          where: "address = ?", whereArgs: [address]);
      await db
          .delete(lostDevicesTable, where: "address = ?", whereArgs: [address]);
    }
    return await db.delete(table, where: "address = ?", whereArgs: [address]);
  }
}
