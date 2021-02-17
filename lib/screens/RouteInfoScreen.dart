import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transportation_tracking_app/class/route.dart';
import 'package:strings/strings.dart';

class RouteInfoScreen extends StatefulWidget {
  final String routeTitle;
  final String routeId;

  RouteInfoScreen({@required this.routeTitle, @required this.routeId});

  @override
  _RouteInfoScreenState createState() => _RouteInfoScreenState();
}

class _RouteInfoScreenState extends State<RouteInfoScreen> {
  VehicleRoute route;

  @override
  void initState() {
    super.initState();
    getRoute(widget.routeId);
  }

  getRoute(String routeId) async {
    var _route = await FirebaseFirestore.instance
        .collection('routes')
        .doc(routeId)
        .get();

    setState(() {
      route = VehicleRoute.from(
          routeId: _route.id,
          startName: _route.get('startName'),
          endName: _route.get('endName'),
          startPoint: _route.get('startPoint'),
          label: _route.get('label'),
          endPoint: _route.get('endPoint'),
          points: List.castFrom<dynamic, GeoPoint>(_route.get('points')),
          stops: List.castFrom<dynamic, String>(_route.get('stops')),
          color: Color(int.parse(('0xff${_route.get('color')}').toString())));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routeTitle),
      ),
      body: route == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                    height: MediaQuery.of(context).size.height / 3,
                    color: Colors.grey.shade300,
                    child: Stack(
                      children: [
                        GoogleMap(
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          initialCameraPosition: CameraPosition(
                            zoom: 13,
                            target: route.routePoints.elementAt(
                                (route.routePoints.length / 2).ceil()),
                          ),
                          polylines: {
                            Polyline(
                              polylineId: PolylineId(route.routeId),
                              visible: true,
                              color: route.color.withOpacity(0.7),
                              points: route.routePoints,
                              width: 4,
                            ),
                          },
                          markers: {
                            Marker(
                              infoWindow: InfoWindow(title: route.startName),
                              markerId: MarkerId(
                                  '${route.startPoint.latitude},${route.startPoint.longitude}'
                                      .hashCode
                                      .toString()),
                              position: LatLng(route.startPoint.latitude,
                                  route.startPoint.longitude),
                            ),
                            Marker(
                              infoWindow: InfoWindow(title: route.endName),
                              markerId: MarkerId(
                                  '${route.endPoint.latitude},${route.endPoint.longitude}'
                                      .hashCode
                                      .toString()),
                              position: LatLng(route.endPoint.latitude,
                                  route.endPoint.longitude),
                            ),
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            // color: Colors.black,
                            height: 7,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.1),
                                    Colors.transparent
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter),
                            ),
                          ),
                        )
                      ],
                    )),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.maxFinite,
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Route - ${route.label}',
                            style: TextStyle(fontSize: 22),
                          ),
                          Text(
                            'From ${route.startName} to ${route.endName}',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 16),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20, bottom: 20),
                            child: Text(
                              'Stops on ${widget.routeTitle}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          ...route.stops.asMap().entries.map((stop) =>
                              Container(
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      left: 13,
                                      bottom: 0,
                                      child: Container(
                                        width: 3,
                                        color:
                                            Theme.of(context).primaryColorLight,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (stop.key == 0 ||
                                                  stop.key ==
                                                      route.stops.length - 1)
                                                Text(
                                                  stop.key == 0
                                                      ? 'START'
                                                      : 'END',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                ),
                                              Text(
                                                capitalize(stop.value),
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
