import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart';
import '../main.dart';
import 'package:geocoder/geocoder.dart';

const keyWeather = 'f15dc897b26e405fe05f3b7de952c0aa';

class PassengerMap extends StatefulWidget {
  @override
  _PassengerMapState createState() => _PassengerMapState();
}

class _PassengerMapState extends State<PassengerMap> {
  double mapBottomPadding = 0;
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;
  var geoLocator = Geolocator();
  Position currentPosition;
  var src_loc = TextEditingController();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.947351, 35.227163),
    zoom: 14.4746,
  );

  void getData(double lat, double long) async {
    Response response = await get(
        'http://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$long&appid=$keyWeather');
    if (response.statusCode == 200) {
      String data = response.body;
      setState(() {
        src_loc.text = jsonDecode(data)['name'];
        //print(jsonDecode(data)['name']);
      });
    } else {
      print(response.statusCode);
    }
  }

  void setupPositionLocator() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    LatLng pos = LatLng(currentPosition.latitude, currentPosition.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cp));
    getData(currentPosition.latitude, currentPosition.longitude);

    /*  debugPrint('location: ${position.latitude}');
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first; "${first.featureName} : ${first.addressLine}";

    }); */

    //*********************************************************
    /* List<Location> locations = await locationFromAddress("Tamun");
    print(locations.toString()); */

    //print(currentPosition.latitude);
    //print(currentPosition.longitude);
    /*  List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPosition.latitude, currentPosition.longitude);
    print(placemarks[0].subLocality); */
    //jsonDecode(placemarks)['country'];
    //*********************************************************
  }

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
                    controller: src_loc,
                    readOnly: true,
                    autofocus: false,
                    decoration:
                        new InputDecoration(labelText: 'Source Location'),
                  ),
                ),
                /* SizedBox(
              height: 10,
            ), */
                new Expanded(
                  child: new TextField(
                    autofocus: true,
                    decoration: new InputDecoration(
                        labelText: 'Destination Location', hintText: 'Nablus'),
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
                Navigator.pop(context);
              })
        ],
      ),
      context: context,
    );
  }

  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false, //لإخفاء شريط depug
      home: Scaffold(
        backgroundColor: ba1color,
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
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: mapBottomPadding),
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              myLocationButtonEnabled: true,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                setState(() {
                  mapBottomPadding = 65;
                });
                setupPositionLocator();
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                // color: apcolor,
                width: size.width,
                height: 80,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(size.width, 80),
                      painter: CusPaint(),
                    ),
                    Center(
                      heightFactor: 0.6,
                      child: FloatingActionButton(
                        onPressed: () {
                          _searchDialog();
                        },
                        backgroundColor: mypink,
                        //Color(0xFF0e6655),  //Colors.black,
                        child: Icon(Icons.search),
                        elevation: 0.1,
                      ),
                    ),
                    Container(
                        width: size.width,
                        height: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceEvenly, //Center Row contents vertically,

                          children: [
                            Material(
                              color: Color(0xFF1ccdaa),
                              shape: CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              child: IconButton(
                                  icon: Icon(Icons.home),
                                  color: mypink,
                                  // iconBack, //mypink, //apcolor,
                                  onPressed: () {}),
                            ),
                            Material(
                              color: Colors.transparent,
                              shape: CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              child: IconButton(
                                  icon: Icon(Icons.message_outlined),
                                  color: Colors.white,
                                  onPressed: () {}),
                            ),
                            Container(
                              width: size.width * 0.20,
                            ),
                            Material(
                              color: Colors.transparent,
                              shape: CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              child: IconButton(
                                  icon: Icon(Icons.notifications_outlined),
                                  color: Colors.white,
                                  onPressed: () {}),
                            ),
                            Material(
                              color: Colors.transparent,
                              shape: CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              child: IconButton(
                                  icon: Icon(Icons.person_outline_rounded),
                                  color: Colors.white,
                                  onPressed: () {}),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CusPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = apcolor
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, 20);
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: Radius.circular(10), clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDElegate) {
    return false;
  }
}
