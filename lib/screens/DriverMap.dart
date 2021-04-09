import 'dart:async';
import 'dart:convert';
import 'package:OtoBus/dataProvider/address.dart';
import 'package:OtoBus/dataProvider/appData.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'package:custom_switch/custom_switch.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:OtoBus/configMaps.dart';
import 'package:OtoBus/dataProvider/pushNoteficationsFire.dart';

class DriverMap extends StatefulWidget {
  @override
  _DriverMapState createState() => _DriverMapState();
}

Position currentPosition;
double _originLatitude;
double _originLongitude;
double _destLatitude;
double _destLongitude;
String _currName;
String _destName;
var currltlg;
var destltlg;
Set<Marker> gMarkers = {};
Set<Circle> circles = {};
PolylinePoints polylinePoints = PolylinePoints();
Map<PolylineId, Polyline> polylines = {};
const keyPoStack = 'b302ddec67beb4a453f6a3b36393cdf0';
final _startPointController = TextEditingController();

class _DriverMapState extends State<DriverMap> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController newGoogleMapController;
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.947351, 35.227163),
    zoom: 9.4746,
  );

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void getData(double lat, double long) async {
    Response response = await get(
        'http://api.positionstack.com/v1/reverse?access_key=$keyPoStack&query=$lat,$long');

    if (response.statusCode == 200) {
      String data = response.body;
      setState(() {
        Adress pickUp = new Adress();
        pickUp.placeName = jsonDecode(data)['data'][0]['label'];
        //  pickUp.placeName = jsonDecode(data)['data'][0]['county'];
        _currName = pickUp.placeName;
        //src_loc.text = _currName;
        Provider.of<AppData>(context, listen: false).updatePickAddress(pickUp);
      });
    } else {
      print(response.statusCode);
    }
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void setupPositionLocator() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    LatLng pos = LatLng(currentPosition.latitude, currentPosition.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cp));
    getData(currentPosition.latitude, currentPosition.longitude);
    _originLatitude = currentPosition.latitude;
    _originLongitude = currentPosition.longitude;
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void butMarker() {
    LatLngBounds bounds;
    currltlg = LatLng(_originLatitude, _originLongitude);
    destltlg = LatLng(_destLatitude, _destLongitude);
    Marker currMarker = Marker(
        markerId: MarkerId("current"),
        position: currltlg,
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: _currName, snippet: 'My Location'));
    Marker destMarker = Marker(
        markerId: MarkerId("destination"),
        position: destltlg,
        icon: BitmapDescriptor.defaultMarkerWithHue(90),
        infoWindow: InfoWindow(title: _destName, snippet: 'Destination'));
    gMarkers.add(currMarker);
    gMarkers.add(destMarker);

    Circle currCircle = Circle(
      circleId: CircleId('current'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 40,
      center: currltlg,
      fillColor: Colors.green,
    );
    Circle destCircle = Circle(
      circleId: CircleId('current'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 40,
      center: destltlg,
      fillColor: Colors.green,
    );
    circles.add(currCircle);
    circles.add(destCircle);
    //*************************************//
    if (_originLatitude > _destLatitude && _originLongitude > _destLongitude) {
      bounds = LatLngBounds(southwest: destltlg, northeast: currltlg);
    } else if (_originLongitude > _destLongitude) {
      bounds = LatLngBounds(
          southwest: LatLng(_originLatitude, _destLongitude),
          northeast: LatLng(_destLatitude, _originLongitude));
    } else if (_originLatitude > _destLatitude) {
      bounds = LatLngBounds(
          southwest: LatLng(_destLatitude, _originLongitude),
          northeast: LatLng(_originLatitude, _destLongitude));
    } else {
      bounds = LatLngBounds(southwest: currltlg, northeast: destltlg);
    }
    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Future<void> _searchDialog() async {
    return showDialog<void>(
      builder: (context) => new AlertDialog(
        contentPadding: EdgeInsets.all(20.0),
        content: Container(
            width: 300.0,
            height: 200.0,
            child: Column(
              children: <Widget>[
                new Expanded(
                  child: new TextField(
                    //controller: src_loc,
                    readOnly: true,
                    minLines: 1,
                    maxLines: null,
                    autofocus: false,
                    decoration:
                        new InputDecoration(labelText: 'Source Location'),
                  ),
                ),
                new Expanded(
                  child: CustomTextField(
                    hintText: "Select starting point",
                    textController: _startPointController,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapBoxAutoCompleteWidget(
                            apiKey: tokenkey,
                            hint: "Select starting point",
                            closeOnSelect: true,
                            onSelect: (place) {
                              _startPointController.text = place.placeName;
                              setState(() {
                                _destLatitude = place.center[1];
                                _destLongitude = place.center[0];
                                _destName = place.placeName;
                                LatLng posd =
                                    LatLng(_destLatitude, _destLongitude);
                                CameraPosition cpd =
                                    new CameraPosition(target: posd, zoom: 14);
                                newGoogleMapController.animateCamera(
                                    CameraUpdate.newCameraPosition(cpd));
                              });
                            },
                            limit: 30,
                            country: 'Ps',
                            //language: 'ar',
                          ),
                        ),
                      );
                    },
                    enabled: true,
                  ),
                )
              ],
            )),
        actions: <Widget>[
          new FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              }),
          new FlatButton(
              child: const Text('CHOOSE'),
              onPressed: () {
                setState(() {
                  _getPolyline();
                  butMarker();
                });
                Navigator.pop(context);
              })
        ],
      ),
      context: context,
    );
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void driverInfo() async {
    currUser = await FirebaseAuth.instance.currentUser;
    PushNotifications pushNot = PushNotifications();
    pushNot.initialize();
    pushNot.getToken();
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  @override
  void initState() {
    super.initState();
    driverInfo();
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  bool status = false;
  bool backOn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, //لإخفاء شريط depug
        home: Scaffold(
          appBar: AppBar(
            title: Center(
              child: Text(
                "OtoBüs",
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'Pacifico',
                  color: Colors.white,
                ),
              ),
            ),
            backgroundColor: apcolor,
          ),
          body: Stack(children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              tiltGesturesEnabled: true,
              compassEnabled: true,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              polylines: Set<Polyline>.of(polylines.values),
              markers: gMarkers,
              circles: circles,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                newGoogleMapController = controller;
                setupPositionLocator();
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 5),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  /*        mainAxisAlignment: MainAxisAlignment
                      .center, */
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    status
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              child: Container(
                                  height: 35,
                                  padding: EdgeInsets.all(3.5),
                                  width: 90,
                                  decoration: BoxDecoration(
                                    color: iconBack,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                          child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  backOn = false;
                                                });
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: backOn
                                                        ? Colors.white
                                                        : iconBack,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomLeft: Radius
                                                                .circular(12),
                                                            topLeft:
                                                                Radius.circular(
                                                                    12))),
                                                child: Text("ذهاب",
                                                    style: TextStyle(
                                                      color: backOn
                                                          ? iconBack
                                                          : Colors.white,
                                                      fontSize: 12,
                                                    )),
                                              ))),
                                      Expanded(
                                          child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  backOn = true;
                                                });
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: backOn
                                                        ? iconBack
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomRight: Radius
                                                                .circular(12),
                                                            topRight:
                                                                Radius.circular(
                                                                    12))),
                                                child: Text("عودة",
                                                    style: TextStyle(
                                                      color: backOn
                                                          ? Colors.white
                                                          : iconBack,
                                                      fontSize: 12,
                                                    )),
                                              ))),
                                    ],
                                  )),
                            ),
                          )
                        : Container(
                            height: 0.1,
                            width: 0.1,
                          ),
                    CustomSwitch(
                      activeColor: Color(0xFF094338),
                      value: status,
                      onChanged: (value) {
                        value ? GoOnline() : GoOffline();
                        value ? updateLocation() : null;
                        print("VALUE : $value");
                        setState(() {
                          status = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            )
          ]),
          bottomNavigationBar: CurvedNavigationBar(
            color: apcolor,
            backgroundColor: myG,
            items: <Widget>[
              Icon(
                Icons.notifications,
                size: 25,
                color: Colors.white,
              ),
              IconButton(
                icon: Icon(
                  Icons.messenger,
                  size: 25,
                  color: Colors.white,
                ),
                onPressed: () {
                  _searchDialog();
                },
              ),
              Icon(
                Icons.person,
                size: 25,
                color: Colors.white,
              ),
            ],
          ),
        ));
  }

  /*  _addCircle(LatLng position, String id) {
      CircleId circleId = CircleId(id);
    Circle circle =
        Circle(circleId: circleId);
    circle[circleId] = circle;
  } */
  _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      width: 3,
      color: myblue,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  void _getPolyline() async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyDpIlaxbh4WTp4_Ecnz4lupswaRqyNcTv4",
      PointLatLng(_originLatitude, _originLongitude),
      PointLatLng(_destLatitude, _destLongitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    _addPolyLine(polylineCoordinates);
  }

  void GoOnline() {
    Geofire.initialize('availableDrivers');
    Geofire.setLocation(
        currUser.uid, currentPosition.latitude, currentPosition.longitude);
    tripReq = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currUser.uid}/newTrip');
    tripReq.set('waiting');
    tripReq.onValue.listen((event) {});
  }

  void GoOffline() {
    Geofire.removeLocation(currUser.uid);
    tripReq.onDisconnect();
    tripReq.remove();
    tripReq = null;
  }

  void updateLocation() {
    posStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 4)
        .listen((Position position) {
      currentPosition = position;
      if (status) {
        Geofire.setLocation(
            currUser.uid, position.latitude, position.longitude);
      }
      LatLng pos = LatLng(position.latitude, position.longitude);
      newGoogleMapController.animateCamera(CameraUpdate.newLatLng(pos));
    });
  }
}
