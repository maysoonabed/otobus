import 'dart:async';
import 'dart:convert';
import 'package:OtoBus/dataProvider/address.dart';
import 'package:OtoBus/dataProvider/appData.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class PassMap extends StatefulWidget {
  @override
  _PassMapState createState() => _PassMapState();
}

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Position currentPosition;
double _originLatitude;
double _originLongitude;
double _destLatitude;
double _destLongitude;
String _currName;
String _destName;
var currltlg;
var destltlg;
var src_loc = TextEditingController();
Set<Marker> markers = {};
Set<Circle> circles = {};
PolylinePoints polylinePoints = PolylinePoints();
Map<PolylineId, Polyline> polylines = {};
const keyPoStack = 'b302ddec67beb4a453f6a3b36393cdf0';
const tokenkey =
    'pk.eyJ1IjoibW15eHQiLCJhIjoiY2ttbDMwZzJuMTcxdDJwazVoYjFmN29vZiJ9.zXZhziLKRg0-JEtO4KPG1w';
final _startPointController = TextEditingController();
String name, email, password, errormsg, phone;
bool error = false;
bool homeispress = false;
bool msgispress = false;
bool notispress = false;
bool proispress = false;
double mapBottomPadding = 0;

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
class _PassMapState extends State<PassMap> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController newGoogleMapController;
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.947351, 35.227163),
    zoom: 9.4746,
  );
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  profileConnection() async {
    String apiurl =
        "http://192.168.1.107:8089/otobus/phpfiles/profile.php"; //10.0.0.13//

    var response = await http.post(apiurl, body: {
      'email': email,
    });
    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body);
      if (jsondata["error"] == 1) {
        setState(() {
          error = true;
          errormsg = jsondata["message"];
        });
      } else {
        if (this.mounted) {
          setState(() {
            email = email;
            name = jsondata["name"];
            phone = jsondata["phonenum"];
            //jsondata["image"];
          });
        }
      }
    } else {
      setState(() {
        error = true;
        errormsg = "هناك مشكلة في الاتصال بالسيرفر";
      });
    }
  }

  void initState() {
    name = "";
    phone = "";
    email = "";
    errormsg = "";
    error = false;
    super.initState();
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void getData(double lat, double long) async {
    Response response = await get(
        'http://api.positionstack.com/v1/reverse?access_key=$keyPoStack&query=$lat,$long');

    if (response.statusCode == 200) {
      String data = response.body;
      setState(() {
        Adress pickUp = new Adress();
        pickUp.placeName = jsonDecode(data)['data'][0]['label'];
        //pickUp.placeName = jsonDecode(data)['data'][0]['county'];
        _currName = pickUp.placeName;
        src_loc.text = _currName;
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
    markers.add(currMarker);
    markers.add(destMarker);

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
        .animateCamera(CameraUpdate.newLatLngBounds(bounds, 30));
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
                    controller: src_loc,
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
                    hintText: "Select Destinaton Point",
                    textController: _startPointController,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapBoxAutoCompleteWidget(
                            apiKey: tokenkey,
                            hint: "Select Destinaton Point",
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

  @override
  Widget build(BuildContext context) {
    profileConnection();
    final Size size = MediaQuery.of(context).size;
    return MaterialApp(
        debugShowCheckedModeBanner: false, //لإخفاء شريط depug
        home: Scaffold(
          key: _scaffoldkey,
          appBar: AppBar(
            actions: <Widget>[
              new Container(),
            ],
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
          //#######################################
          endDrawer: Drawer(
            child: Column(
              children: <Widget>[
                Stack(
                  overflow: Overflow.visible,
                  alignment: Alignment.center,
                  children: <Widget>[
                    Image(image: AssetImage('lib/Images/passengercover.jpg')),
                    Positioned(
                        bottom: -50.0,
                        child: CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                (AssetImage('lib/Images/Defultprof.jpg')))),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                ListTile(
                    title: Center(
                        child: Text(name,
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "Lemonada",
                            )))),
                SizedBox(
                  height: 20,
                ),
                FutureBuilder(
                    future: FlutterSession().get('token'),
                    builder: (context, snapshot) {
                      email = snapshot.hasData ? snapshot.data : '';
                      return Text(
                          snapshot.hasData ? snapshot.data : 'Loading...',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: "Lemonada",
                          ));
                    }),
                SizedBox(
                  height: 20,
                ),
                ListTile(
                  title: Center(
                      child: Text(phone,
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: "Lemonada",
                          ))),
                ),
                SizedBox(
                  height: 100,
                ),
                MaterialButton(
                  color: apBcolor,
                  height: 30,
                  minWidth: 150.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  onPressed: () {
                    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
                    markers.isNotEmpty ? markers.clear() : null;
                    polylines.isNotEmpty ? polylines.clear() : null;
                    homeispress = false;
                    msgispress = false;
                    notispress = false;
                    proispress = false;
                    _destName = "";
                    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
                    FlutterSession().set('token', '');
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyApp()));
                  },
                  child: Text('تسجيل الخروج',
                      style: TextStyle(
                          fontSize: 15,
                          fontFamily: "Lemonada",
                          color: Colors.white)),
                ),
              ],
            ),
          ),
          //#######################################
          body: Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                padding: EdgeInsets.only(bottom: mapBottomPadding),
                initialCameraPosition: _kGooglePlex,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                tiltGesturesEnabled: true,
                compassEnabled: true,
                scrollGesturesEnabled: true,
                zoomGesturesEnabled: true,
                polylines: Set<Polyline>.of(polylines.values),
                markers: markers,
                circles: circles,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
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
                            //markers.remove(destltlg);
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
                                color:
                                    (homeispress) ? Color(0xFF1ccdaa) : apcolor,
                                shape: CircleBorder(),
                                clipBehavior: Clip.hardEdge,
                                child: IconButton(
                                    icon: (homeispress)
                                        ? Icon(Icons.home)
                                        : Icon(Icons.home_outlined),
                                    color:
                                        (homeispress) ? mypink : Colors.white,
                                    // iconBack, //mypink, //apcolor,
                                    onPressed: () {
                                      setState(() {
                                        homeispress = true;
                                        msgispress = false;
                                        notispress = false;
                                        proispress = false;
                                      });
                                    }),
                              ),
                              Material(
                                color:
                                    (msgispress) ? Color(0xFF1ccdaa) : apcolor,
                                shape: CircleBorder(),
                                clipBehavior: Clip.hardEdge,
                                child: IconButton(
                                    icon: (msgispress)
                                        ? Icon(Icons.message)
                                        : Icon(Icons.message_outlined),
                                    color: (msgispress) ? mypink : Colors.white,
                                    onPressed: () {
                                      setState(() {
                                        homeispress = false;
                                        msgispress = true;
                                        notispress = false;
                                        proispress = false;
                                      });
                                    }),
                              ),
                              Container(
                                width: size.width * 0.20,
                              ),
                              Material(
                                color:
                                    (notispress) ? Color(0xFF1ccdaa) : apcolor,
                                shape: CircleBorder(),
                                clipBehavior: Clip.hardEdge,
                                child: IconButton(
                                    icon: (notispress)
                                        ? Icon(Icons.notifications)
                                        : Icon(Icons.notifications_outlined),
                                    color: (notispress) ? mypink : Colors.white,
                                    onPressed: () {
                                      setState(() {
                                        homeispress = false;
                                        msgispress = false;
                                        notispress = true;
                                        proispress = false;
                                      });
                                    }),
                              ),
                              Material(
                                color:
                                    (proispress) ? Color(0xFF1ccdaa) : apcolor,
                                shape: CircleBorder(),
                                clipBehavior: Clip.hardEdge,
                                child: IconButton(
                                    icon: (proispress)
                                        ? Icon(Icons.person)
                                        : Icon(Icons.person_outline_rounded),
                                    color: (proispress) ? mypink : Colors.white,
                                    onPressed: () {
                                      setState(() {
                                        homeispress = false;
                                        msgispress = false;
                                        notispress = false;
                                        proispress = true;
                                      });
                                      _scaffoldkey.currentState.openEndDrawer();
                                      //Navigator.of(context).pop();  //For close the drawer
                                    }),
                              ),
                            ],
                          ))
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

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
