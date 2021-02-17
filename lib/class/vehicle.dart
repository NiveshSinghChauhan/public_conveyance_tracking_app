import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Vehicle {
  LatLng location;
  String id;
  String driverId;
  String routeId;
  String vehicleNumber;

  Vehicle.from({
    @required GeoPoint location,
    @required this.id,
    @required this.driverId,
    @required this.routeId,
    @required this.vehicleNumber,
  }) {
    this.location = LatLng(location.latitude, location.longitude);
  }
}
