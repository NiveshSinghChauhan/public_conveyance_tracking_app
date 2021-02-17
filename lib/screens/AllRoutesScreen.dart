import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transportation_tracking_app/class/route.dart';
import 'package:transportation_tracking_app/class/vehicle.dart';
import 'package:transportation_tracking_app/screens/RoutesListScreen.dart';

class AllRoutesScreen extends StatefulWidget {
  @override
  _AllRoutesScreenState createState() => _AllRoutesScreenState();
}

class _AllRoutesScreenState extends State<AllRoutesScreen> {
  TextEditingController _searchController = TextEditingController();

  Stream<List<Vehicle>> vehiclesStream;
  List<VehicleRoute> routes;
  List<Vehicle> vehicles;

  List<VehicleRoute> showRoutes;
  List<Vehicle> showVehicles;

  @override
  void initState() {
    super.initState();
    getRoutes();

    FirebaseFirestore.instance
        .collection('vehicles')
        .snapshots()
        .listen((event) {
      setState(() {
        vehicles = event.docs
            .map((vehicle) => Vehicle.from(
                  location: vehicle.get('location'),
                  id: vehicle.id,
                  driverId: vehicle.get('driver_id'),
                  routeId: vehicle.get('route'),
                  vehicleNumber: vehicle.get('vehicle_number'),
                ))
            .toList();
        showVehicles = vehicles;
      });
    });
  }

  searchRoute(String routeId) async {
    // String routeId = _searchController.value.text;

    var searchedResult = await Future.wait([
      FirebaseFirestore.instance.collection('routes').doc(routeId).get(),
      FirebaseFirestore.instance
          .collection('vehicles')
          .where('route', isEqualTo: routeId)
          .get()
    ]);

    DocumentSnapshot searchedRoute = searchedResult.elementAt(0);
    QuerySnapshot searchedVehicles = searchedResult.elementAt(1);

    setState(() {
      showRoutes = [
        VehicleRoute.from(
            routeId: searchedRoute.id,
            startName: searchedRoute.get('startName'),
            endName: searchedRoute.get('endName'),
            startPoint: searchedRoute.get('startPoint'),
            endPoint: searchedRoute.get('endPoint'),
            label: searchedRoute.get('label'),
            points:
                List.castFrom<dynamic, GeoPoint>(searchedRoute.get('points')),
            color: Color(
                int.parse(('0xff${searchedRoute.get('color')}').toString())))
      ];

      showVehicles = searchedVehicles.docs
          .map((searchedVehicle) => Vehicle.from(
                location: searchedVehicle.get('location'),
                id: searchedVehicle.id,
                driverId: searchedVehicle.get('driver_id'),
                routeId: searchedVehicle.get('route'),
                vehicleNumber: searchedVehicle.get('vehicle_number'),
              ))
          .toList();
    });
  }

  getRoutes() async {
    List<QueryDocumentSnapshot> _routes = await FirebaseFirestore.instance
        .collection('routes')
        .get()
        .then((value) => value.docs);

    routes = _routes.map((route) {
      return VehicleRoute.from(
          routeId: route.id,
          startName: route.get('startName'),
          endName: route.get('endName'),
          startPoint: route.get('startPoint'),
          endPoint: route.get('endPoint'),
          label: route.get('label'),
          points: List.castFrom<dynamic, GeoPoint>(route.get('points')),
          color: Color(int.parse(('0xff${route.get('color')}').toString())));
    }).toList();

    showRoutes = routes;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: CameraPosition(
              zoom: 13,
              target: LatLng(
                26.4616325,
                74.6795442,
              ),
            ),
            polylines: {
              if (showRoutes != null)
                ...showRoutes.map(
                  (route) => Polyline(
                    polylineId: PolylineId(route.routeId),
                    visible: true,
                    color: route.color.withOpacity(0.7),
                    points: route.routePoints,
                    width: 4,
                  ),
                )
            },
            markers: {
              if (showVehicles != null)
                ...showVehicles.map(
                  (vehicle) => Marker(
                    infoWindow: InfoWindow(
                        title: 'Vehicle Number: ${vehicle.vehicleNumber}'),
                    markerId: MarkerId(vehicle.id),
                    position: vehicle.location,
                  ),
                )
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Card(
                    margin: EdgeInsets.all(0),
                    elevation: 3,
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RoutesListScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.menu_rounded,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton(
                    child: Card(
                      margin: EdgeInsets.all(0),
                      elevation: 3,
                      child: Container(
                        padding: EdgeInsets.all(15),
                        child: Row(
                          children: [
                            Text(_searchController.value.text.isNotEmpty
                                ? _searchController.value.text
                                : 'Select Route'),
                            SizedBox(width: 10),
                            Icon(
                              Icons.expand_more,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    onSelected: (value) {
                      print(value);
                      if (value == -1) {
                        setState(() {
                          showRoutes = routes;
                          showVehicles = vehicles;
                        });
                      } else {
                        searchRoute(routes[value].routeId);
                      }
                      _searchController.text = routes[value].label;
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text('All'),
                        value: -1,
                      ),
                      ...routes
                          .asMap()
                          .entries
                          .map<PopupMenuItem<int>>((route) => PopupMenuItem(
                                child: Text(route.value.label),
                                value: route.key,
                              ))
                          .toList()
                    ],
                  )
                  // Expanded(
                  //   child: Column(
                  //     children: [
                  //       Card(
                  //         margin: EdgeInsets.all(0),
                  //         elevation: 3,
                  //         child: Container(
                  //           child: TextField(
                  //             controller: _searchController,
                  //             decoration: InputDecoration(
                  //                 contentPadding: EdgeInsets.all(15),
                  //                 hintText: 'Search Route Id',
                  //                 border: InputBorder.none,
                  //                 prefixIcon: Icon(Icons.search),
                  //                 suffixIcon:
                  //                     _searchController.value.text.isNotEmpty
                  //                         ? IconButton(
                  //                             color: Colors.grey,
                  //                             icon: Icon(Icons.close),
                  //                             onPressed: () {
                  //                               setState(() {
                  //                                 showRoutes = routes;
                  //                                 showVehicles = vehicles;
                  //                               });
                  //                               _searchController.clear();
                  //                             })
                  //                         : null),
                  //             onSubmitted: (value) => searchRoute(value),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
