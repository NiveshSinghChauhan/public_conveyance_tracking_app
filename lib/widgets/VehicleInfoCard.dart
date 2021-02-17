import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transportation_tracking_app/class/vehicle.dart';

class VehicleInfoCard extends StatefulWidget {
  final String vehicleId;

  VehicleInfoCard({@required this.vehicleId});

  @override
  _VehicleInfoCardState createState() => _VehicleInfoCardState();
}

class _VehicleInfoCardState extends State<VehicleInfoCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool loading = true;

  Map route;
  Vehicle vehicle;
  Map driver;

  @override
  initState() {
    super.initState();
    getInfo();
  }

  getInfo() async {
    setState(() {
      loading = true;
    });

    vehicle = await _firestore
        .collection('vehicles')
        .doc(widget.vehicleId)
        .get()
        .then((value) => Vehicle.from(
              location: value.get('location'),
              id: value.id,
              driverId: value.get('driver_id'),
              routeId: value.get('route'),
              vehicleNumber: value.get('vehicle_number'),
            ));

    var vehicleInfo = await Future.wait([
      _firestore.collection('routes').doc(vehicle.routeId).get(),
      _firestore.collection('driver').doc(vehicle.driverId).get()
    ]);

    setState(() {
      route = vehicleInfo[0].data();
      driver = vehicleInfo[1].data();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Text(
            driver['name'],
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 5),
          Text("Vehicle Number: ${vehicle.vehicleNumber}"),
          SizedBox(height: 5),
          Text("Route: Route #${route['label']}"),
        ],
      ),
    );
  }
}
