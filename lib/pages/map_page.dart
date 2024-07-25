import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:projectfbs/helper/database_helper.dart';

class MyMap extends StatefulWidget {
  const MyMap({super.key, required this.device});
  final LostDevice device;
  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  // final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _googleMapController;
  Position? position;
  late CameraPosition initPosition;
  Set<Marker> markers = {};
  @override
  void initState() {
    super.initState();
    // position = Position(longitude: longitude, latitude: latitude, timestamp: timestamp, accuracy: accuracy, altitude: altitude, heading: heading, speed: speed, speedAccuracy: speedAccuracy)
    _determineCurrentPositon();
    initPosition = CameraPosition(
        target: LatLng(widget.device.latitude, widget.device.longitude));
    if (mounted) {
      setState(() {});
    }
  }

  Future _determineCurrentPositon() async {
    LocationPermission permission;
    bool servicesEnabled = await Geolocator.isLocationServiceEnabled();

    if (!servicesEnabled) {
      return Future.error("Location services disabled");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location Pemissions are denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location Pemissions are permanatly denied");
    }

    position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
      ),
      body: FutureBuilder(
        future: _determineCurrentPositon(),
        builder: (context, snapshot) {
          return GoogleMap(
            initialCameraPosition: initPosition,
            markers: markers,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              _googleMapController = controller;
            },
          );
        },
      ),
    );
  }
}
