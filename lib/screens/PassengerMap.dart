import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../main.dart';
import 'package:OtoBus/dataProvider/address.dart';
import 'package:provider/provider.dart';
import 'package:OtoBus/dataProvider/appData.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
const keyPoStack = 'b302ddec67beb4a453f6a3b36393cdf0';
const keyOpS = 'e29278e269d34185897708d17cb83bc4';
const keyGeo = 'AIzaSyDpIlaxbh4WTp4_Ecnz4lupswaRqyNcTv4';
const tokenkey =
    'pk.eyJ1IjoibW15eHQiLCJhIjoiY2ttbDMwZzJuMTcxdDJwazVoYjFmN29vZiJ9.zXZhziLKRg0-JEtO4KPG1w';
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
String name, email, password, errormsg, phone;
bool error = false;

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
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
  var des_loc = TextEditingController();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.947351, 35.227163),
    zoom: 14.4746,
  );

  void getData(double lat, double long) async {
    Response response = await get(
//'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=$keyGeo'

        'http://api.positionstack.com/v1/reverse?access_key=$keyPoStack&query=$lat,$long'
        //'https://api.opencagedata.com/geocode/v1/json?q=$lat+$long&key=$keyOpS'
        );

    if (response.statusCode == 200) {
      String data = response.body;
      setState(() {
        Adress pickUp = new Adress();
        pickUp.placeLabel = jsonDecode(data)['data'][0]['label'];
        pickUp.placeName = jsonDecode(data)['data'][0]['county'];

        //  pickUp.placeLabel = jsonDecode(data)['results'][0]['formatted_address'];

        //pickUp.placeLabel = jsonDecode(data)['results'][0]['formatted'];
        pickUp.long = long;
        pickUp.lat = lat;
        src_loc.text = pickUp.placeLabel;

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
  }
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  profileConnection() async {
    String apiurl =
        "http://192.168.1.107:8089/otobus/phpfiles/profile.php"; //10.0.0.13//192.168.1.107:8089

    var response = await http.post(apiurl, body: {
      'email': email,
    });
    //print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body); //json.decode
      if (jsondata["error"] == 1) {
        setState(() {
          error = true;
          errormsg = jsondata["message"];
        });
      } else {
        setState(() {
          name = jsondata["name"];
          phone = jsondata["phonenum"];
          password = jsondata["password"];
          //jsondata["image"];
        });
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
    email = "";
    phone = "";
    password = "";
    errormsg = "";
    error = false;
    //_name.text = "defaulttext";
    //_password.text = "defaultpassword";
    super.initState();
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  final _startPointController = TextEditingController();
  Adress destinationAdd = new Adress();
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
                /* SizedBox(
              height: 10,
            ), */
                new Expanded(
                  /* child: new TextField(
                    controller: des_loc,
                    autocorrect: false,
                    autofocus: true,
                    decoration: new InputDecoration(
                      labelText: 'Destination Location',
                      hintText: 'Where to',
                    ), */

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
                            onSelect: (place) {
                              _startPointController.text = place.placeName;
                              destinationAdd.lat = place.center[1];
                              destinationAdd.long = place.center[0];
                              destinationAdd.placeName = place.placeName;
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
                Navigator.pop(context);
              })
        ],
      ),
      context: context,
    );
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Widget build(BuildContext context) {
    profileConnection();
    final Size size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false, //لإخفاء شريط depug
      home: Scaffold(
        key: _scaffoldKey,
        backgroundColor: ba1color,
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
        endDrawer: Drawer(
          child: ListView(
            children: <Widget>[
              FutureBuilder(
                  future: FlutterSession().get('token'),
                  builder: (context, snapshot) {
                    email = snapshot.hasData ? snapshot.data : '';
                    return Text(
                        snapshot.hasData ? snapshot.data : 'loading...');
                  }),
              MaterialButton(
                color: Colors.blue,
                onPressed: () {
                  FlutterSession().set('token', '');
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyApp()));
                },
                child: Text('Logout'),
              ),
              ListTile(title: Text(name)),
              ListTile(title: Text(phone)),
              ListTile(title: Text(password)),
            ],
          ),
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
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MyApp()));
                                  }),
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
                                  onPressed: () {
                                    _scaffoldKey.currentState.openEndDrawer();

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
      ),
    );
  }
}

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
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
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
