import 'dart:ui';

import 'package:OtoBus/dataProvider/address.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';
import 'PassengerMap.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong/latlong.dart" as latLng;
import 'NetworkHelper.dart';
import 'LineString.dart';

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//final GlobalKey<IconButton> home_key=GlobalKey<IconButton>();
String name, email, password, errormsg, phone;
bool error = false;
final _startPointController = TextEditingController();
Adress destinationAdd = new Adress();
var src_loc = TextEditingController();
var des_loc = TextEditingController();
bool homeispress = false;
bool msgispress = false;
bool notispress = false;
bool proispress = false;

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
class PassengerPage extends StatefulWidget {
  @override
  _PassengerPageState createState() => _PassengerPageState();
}

class _PassengerPageState extends State<PassengerPage> {
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  setPolyLines() {
  
      polyLines.isNotEmpty ? polyLines.clear() : null;
  

    Polyline polyline = Polyline(
      points: points,
      strokeWidth: 5.0,
      color: Colors.lightBlue,
    );
    polyLines.add(polyline);
    setState(() {});
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  profileConnection() async {
    String apiurl =
        "http://192.168.1.107:8089/otobus/phpfiles/profile.php"; //10.0.0.13//192.168.1.107:8089

    var response = await http.post(apiurl, body: {
      'email': email,
    });
    //print(response.body);
    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body); //json.decode
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

  void getJsonData() async {
    // Create an instance of Class NetworkHelper which uses http package
    // for requesting data to the server and receiving response as JSON format
    points.isNotEmpty ? points.clear() : null;
    NetworkHelper network = NetworkHelper(
      startLat: currLatLng.latitude,
      startLng: currLatLng.longitude,
      endLat: destinationAdd.lat,
      endLng: destinationAdd.long,
    );

    try {
      // getData() returns a json Decoded data
      data = await network.getData();

      // We can reach to our desired JSON data manually as following
      LineString ls =
          LineString(data['features'][0]['geometry']['coordinates']);

      for (int i = 0; i < ls.lineString.length; i++) {
        points.add(latLng.LatLng(ls.lineString[i][1], ls.lineString[i][0]));
      }
      setPolyLines();
    } catch (e) {
      print(e);
    }
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
                              setState(() {
                                destinationAdd.lat = place.center[1];
                                destinationAdd.long = place.center[0];
                                destinationAdd.placeName = place.placeName;
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
                  markers.length == 2 ? markers.removeAt(1) : null;

                markers.insert(
                  1,
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point:
                        latLng.LatLng(destinationAdd.lat, destinationAdd.long),
                    builder: (ctx) => Container(
                        child: Icon(
                      Icons.directions_bus,
                      color: Colors.black,
                      size: 40,
                    )),
                  ),
                );
                getJsonData();
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
    return Scaffold(
      //key: _scaffoldKey,
      backgroundColor: ba1color,
      //#######################################
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
                  return Text(snapshot.hasData ? snapshot.data : 'Loading...',
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
                points.isNotEmpty ? points.clear() : null;
                markers.isNotEmpty ? markers.clear() : null;
                polyLines.isNotEmpty ? polyLines.clear() : null;

                FlutterSession().set('token', '');
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => MyApp()));
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
          PassengerMap(),
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
                            color: (homeispress) ? Color(0xFF1ccdaa) : apcolor,
                            shape: CircleBorder(),
                            clipBehavior: Clip.hardEdge,
                            child: IconButton(
                                icon: (homeispress)
                                    ? Icon(Icons.home)
                                    : Icon(Icons.home_outlined),
                                color: (homeispress) ? mypink : Colors.white,
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
                            color: (msgispress) ? Color(0xFF1ccdaa) : apcolor,
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
                            color: (notispress) ? Color(0xFF1ccdaa) : apcolor,
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
                            color: (proispress) ? Color(0xFF1ccdaa) : apcolor,
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
                                  
                                  //  _scaffoldKey.currentState.openEndDrawer();
                                  //Scaffold.of(context).openEndDrawer();
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
