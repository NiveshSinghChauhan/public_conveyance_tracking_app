import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LiveVehicleLocScreen extends StatefulWidget {
  @override
  _LiveVehicleLocScreenState createState() => _LiveVehicleLocScreenState();
}

class _LiveVehicleLocScreenState extends State<LiveVehicleLocScreen> {
  StreamSubscription<Position> positionStream;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  initState() {
    super.initState();
    getLocation();
  }

  getLocation() {
    positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      intervalDuration: Duration(seconds: 0),
    ).listen((Position position) {
      // print(position == null
      //     ? 'Unknown'
      //     : position.latitude.toString() +
      //         ', ' +
      //         position.longitude.toString());

      firestore.collection('vehicles').doc('4').update(
          {'location': GeoPoint(position.latitude, position.longitude)});
    });
  }

  @override
  void dispose() {
    super.dispose();
    positionStream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Location'),
      ),
      body: Container(),
    );
  }
}
