import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transportation_tracking_app/class/route.dart';
import 'package:transportation_tracking_app/screens/RouteInfoScreen.dart';

class RoutesListScreen extends StatefulWidget {
  @override
  _RoutesListScreenState createState() => _RoutesListScreenState();
}

class _RoutesListScreenState extends State<RoutesListScreen> {
  List<VehicleRoute> routes;

  List<VehicleRoute> visibleRoutes;

  VehicleRoute selectedRoute;

  String settingRouteloading;

  bool gettingRoutesLoading = true;

  @override
  void initState() {
    super.initState();
    getRoute();
  }

  getRoute() async {
    setState(() {
      gettingRoutesLoading = true;
    });
    var _routes = await FirebaseFirestore.instance
        .collection('routes')
        .get()
        .then((value) => value.docs);

    routes = _routes.map((QueryDocumentSnapshot route) {
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
    visibleRoutes = List.from(routes);

    setState(() {
      gettingRoutesLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Routes List'),
      ),
      body: gettingRoutesLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...visibleRoutes?.map(
                      (route) => Card(
                        child: ListTile(
                          selected: selectedRoute != null &&
                              selectedRoute.routeId == route.routeId,
                          selectedTileColor: Theme.of(context)
                              .primaryColorLight
                              .withOpacity(0.4),
                          title: Text('Route - ${route.label}'),
                          subtitle: Text(
                            'From ${route.startName} to ${route.endName}',
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.keyboard_arrow_right),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RouteInfoScreen(
                                    routeTitle: route.label,
                                    routeId: route.routeId,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
