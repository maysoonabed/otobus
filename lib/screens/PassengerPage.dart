import 'dart:ui';
import 'package:OtoBus/chat/passchat.dart';
import 'package:OtoBus/dataProvider/appData.dart';
import 'package:OtoBus/screens/DriverMap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cube_transition/cube_transition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:OtoBus/dataProvider/address.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import '../main.dart';
import 'PassengerMap.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong/latlong.dart" as latLng;
import 'NetworkHelper.dart';
import 'LineString.dart';
import 'CurrUserInfo.dart';
import 'package:OtoBus/configMaps.dart';
import 'package:OtoBus/dataProvider/nearDriver.dart';
import 'package:OtoBus/screens/calender.dart';

import 'TheCalendar.dart';

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//final GlobalKey<IconButton> home_key=GlobalKey<IconButton>();
String name, email, password, errormsg, phone;
bool error = false;
final startPointController = TextEditingController();
Adress destinationAdd = new Adress();
var src_loc = TextEditingController();
var des_loc = TextEditingController();
bool homeispress = false;
bool msgispress = false;
bool notispress = false;
bool proispress = false;
List<NearDrivers> availableDrivers;
final picker = ImagePicker();
AssetImage img;
bool showprogress = false;
var namecon = TextEditingController();
var emailcon = TextEditingController();
var phonecon = TextEditingController();

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
class PassengerPage extends StatefulWidget {
  @override
  PassengerPageState createState() => PassengerPageState();
}

class PassengerPageState extends State<PassengerPage> {
  final GlobalKey<ScaffoldState> _scafkey = GlobalKey<ScaffoldState>();
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  setPolyLines() {
    setState(() {
      polyLines.isNotEmpty ? polyLines.clear() : null;
    });

    Polyline polyline = Polyline(
      points: points,
      strokeWidth: 5.0,
      color: myblue,
    );
    polyLines.add(polyline);
    setState(() {});
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  void initState() {
    name = thisUser.name != null ? thisUser.name : "";
    phone = thisUser.phone != null ? thisUser.phone : "";
    email = thisUser.email != null ? thisUser.email : "";
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
  Future<void> searchDialog() async {
    return showDialog<void>(
      builder: (context) => new AlertDialog(
        contentPadding: EdgeInsets.all(20.0),
        content: Container(
            width: 300.0,
            height: 300.0,
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(primaryColor: apcolor),
                    child: TextField(
                      textAlign: TextAlign.end,
                      controller: src_loc,
                      readOnly: true,
                      minLines: 1,
                      maxLines: null,
                      autofocus: false,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.location_on),
                        hintText: 'الموقع',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(primaryColor: apcolor),
                    child: TextField(
                      minLines: 1,
                      maxLines: null,
                      readOnly: true,
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.location_on_outlined),
                        hintText: 'الوجهة',
                      ),
                      controller: startPointController,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapBoxAutoCompleteWidget(
                              apiKey: tokenkey,
                              hint: "حدد وجهتك",
                              onSelect: (place) {
                                startPointController.text = place.placeName;
                                setState(() {
                                  destinationAdd.lat = place.center[1];
                                  destinationAdd.long = place.center[0];
                                  destinationAdd.placeName = place.placeName;
                                  Provider.of<AppData>(context, listen: false)
                                      .updateDestAddress(destinationAdd);
                                });
                                print(destinationAdd.lat.toString() +
                                    destinationAdd.long.toString());
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
                  ),
                ),
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(primaryColor: apcolor),
                    child: TextField(
                      textAlign: TextAlign.end,
                      onChanged: (v) {
                        numCont = int.parse(v);
                      },
                      keyboardType: TextInputType.number,
                      autofocus: false,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        hintText: 'عدد الركاب',
                      ),
                    ),
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FlatButton(
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(
                                color: Colors.black, fontFamily: 'Lemonada'),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      FlatButton(
                          child: const Text(
                            'اختيار',
                            style: TextStyle(
                                color: Colors.black, fontFamily: 'Lemonada'),
                          ),
                          onPressed: () {
                            setState(() {
                              markers.length == 2 ? markers.removeAt(1) : null;
                            });

                            markers.insert(
                              1,
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: latLng.LatLng(
                                    destinationAdd.lat, destinationAdd.long),
                                builder: (ctx) => Container(
                                    child: Icon(
                                  Icons.location_on,
                                  color: Colors.black,
                                  size: 40,
                                )),
                              ),
                            );
                            getJsonData();
                            Navigator.pop(context);
                          })
                    ])
              ],
            )),
        /*
         */
      ),
      context: context,
    );
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void pic() async {
    var pic = await FlutterSession().get('profpic');
    setState(() {
      if (pic != "") {
        profname = pic;
        img = AssetImage('phpfiles/cardlic/$profname');
      } else
        profname = null;
    });
  }

  int msgsCount = 0;
  int busflaf = 0;
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    pic();
    numUnredMsgs() {
      int count = 0;
      FirebaseFirestore.instance
          .collection('chatrooms')
          .where("users", arrayContains: thisUser.email)
          .get()
          .then((val) {
        for (int i = 0; i < val.docs.length; i++) {
          if (val.docs[i]['lastmsgread'] == null) {
            break;
          } else if ((val.docs[i]['lastmsgread'] == false) &&
              (val.docs[i]['lastMessageSendBy'] != thisUser.name)) {
            count++;
          }
        }
        setState(() {
          msgsCount = count;
        });
        //print(count);
      });
    }

    numUnredMsgs();
    return MaterialApp(
        debugShowCheckedModeBanner: false, //لإخفاء شريط depug
        home: Scaffold(
            key: _scafkey,
            backgroundColor: ba1color,
            //#######################################
            appBar: AppBar(
              automaticallyImplyLeading: false,
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
            //######################################
            drawer: Drawer(
                child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  (currUser.uid != null)
                      ? StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .doc(currUser.uid)
                              .collection("favorit")
                              .snapshots(),
                          builder: (context, snapshot) {
                            return snapshot.hasData
                                ? ListView.builder(
                                    itemCount: snapshot.data.docs.length,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.only(top: 16),
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      if (!snapshot.hasData) {
                                        return Container();
                                      }
                                      DocumentSnapshot favp =
                                          snapshot.data.docs[index];
                                      var fpname = favp['FavPlaceName'];
                                      var ltt = favp['lattitude'];
                                      var lgg = favp['longitude'];
                                      return PassengerMapState()
                                          .favlist(fpname, ltt, lgg, context);
                                    })
                                : Center(child: CircularProgressIndicator());
                          })
                      : Container(),
                ],
              ),
            )),
            //######################################
            endDrawer: Drawer(
                child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Stack(
                    overflow: Overflow.visible,
                    alignment: Alignment.center,
                    children: <Widget>[
                      Image(image: AssetImage('lib/Images/passengercover.jpg')),
                      Positioned(
                          //key: _photopickey,
                          bottom: -50.0,
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.white,
                            backgroundImage: (prof != null)
                                ? FileImage(prof)
                                : (profname != null
                                    ? img
                                    : AssetImage('lib/Images/Defultprof.jpg')),
                            child: MaterialButton(
                              height: 170,
                              minWidth: 170.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(80)),
                              onPressed: () async {
                                var picked = await picker.getImage(
                                    source: ImageSource.gallery);
                                prof = File(picked.path);
                                profname = prof.path.split('/').last;
                                PassengerMapState().upload(prof, profname);
                                setState(() {
                                  img =
                                      AssetImage('phpfiles/cardlic/$profname');
                                });
                              },
                            ),
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  Container(
                      child: TextField(
                    controller: namecon,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: "Lemonada",
                    ),
                    readOnly: true,
                    autofocus: false,
                    decoration: myInputDecoration(
                      label: " ",
                      icon: Icons.person,
                    ),
                  )),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: TextField(
                      controller: emailcon,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: "Lemonada",
                      ),
                      readOnly: true,
                      autofocus: false,
                      decoration: myInputDecoration(
                        label: " ",
                        icon: Icons.email,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: TextField(
                      controller: phonecon,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: "Lemonada",
                      ),
                      readOnly: true,
                      autofocus: false,
                      decoration: myInputDecoration(
                        label: " ",
                        icon: Icons.phone_android,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: FloatingActionButton.extended(
                        backgroundColor: Colors.amber,
                        isExtended: true,
                        onPressed: () {
                          _scafkey.currentState.openDrawer();
                        },
                        label: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.star_sharp),
                            ),
                            Text("الأماكن المفضلة",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: "Lemonada",
                                    color: Colors.white)),
                          ],
                        )),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: FloatingActionButton.extended(
                        backgroundColor: apBcolor,
                        isExtended: true,
                        onPressed: () {},
                        label: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                Icons.update,
                                size: 20,
                              ),
                            ),
                            Text("تحديث المعلومات",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "Lemonada",
                                    color: Colors.white)),
                          ],
                        )),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: FloatingActionButton.extended(
                        backgroundColor: apBcolor,
                        isExtended: true,
                        onPressed: () {
                          //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
                          setState(() {
                            FirebaseAuth.instance.signOut();
                            markers.clear();
                            polyLines.clear();
                            homeispress = false;
                            msgispress = false;
                            notispress = false;
                            proispress = false;
                            startPointController.text = "";
                            FlutterSession().set('passemail', '');
                            FlutterSession().set('name', '');
                            FlutterSession().set('phone', '');
                            FlutterSession().set('password', '');
                            FlutterSession().set('profpic', '');
                          });
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => MyApp()));
                        },
                        label: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                Icons.logout,
                                size: 20,
                              ),
                            ),
                            Text("تسجيل الخروج",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "Lemonada",
                                    color: Colors.white)),
                          ],
                        )),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            )),
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
                              driversDetailes == 0 ? searchDialog() : null;
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
                                  color: (homeispress)
                                      ? Color(0xFF1ccdaa)
                                      : apcolor,
                                  shape: CircleBorder(),
                                  clipBehavior: Clip.hardEdge,
                                  child: IconButton(
                                      icon: Icon(Icons.home),
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
                                  color: (msgispress)
                                      ? Color(0xFF1ccdaa)
                                      : apcolor,
                                  shape: CircleBorder(),
                                  clipBehavior: Clip.hardEdge,
                                  child: IconButton(
                                      icon: new Stack(
                                        children: <Widget>[
                                          Icon(Icons
                                              .chat_bubble_outlined), //Icons.message_outlined
                                          new Positioned(
                                            right: 0,
                                            child: new Container(
                                              padding: EdgeInsets.all(1),
                                              decoration: new BoxDecoration(
                                                color: (msgsCount > 0)
                                                    ? Colors.red
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              constraints: BoxConstraints(
                                                minWidth: 15,
                                                minHeight: 15,
                                              ),
                                              child: new Text(
                                                (msgsCount > 0)
                                                    ? '$msgsCount'
                                                    : '',
                                                style: new TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      color:
                                          (msgispress) ? mypink : Colors.white,
                                      onPressed: () {
                                        setState(() {
                                          homeispress = false;
                                          msgispress = true;
                                          notispress = false;
                                          proispress = false;
                                        });
                                        Navigator.of(context).push(
                                          CubePageRoute(
                                            enterPage: PassChat(
                                                thisUser.email, thisUser.name),
                                            exitPage: PassengerMap(),
                                            duration: const Duration(
                                                milliseconds: 1200),
                                          ),
                                        );
                                      }),
                                ),
                                Container(
                                  width: size.width * 0.20,
                                ),
                                Material(
                                  color: (notispress)
                                      ? Color(0xFF1ccdaa)
                                      : apcolor,
                                  shape: CircleBorder(),
                                  clipBehavior: Clip.hardEdge,
                                  child: IconButton(
                                      icon: Icon(Icons.notifications),
                                      color:
                                          (notispress) ? mypink : Colors.white,
                                      onPressed: () {
                                        setState(() {
                                          homeispress = false;
                                          msgispress = false;
                                          notispress = true;
                                          proispress = false;
                                        });
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TheCalendar()),
                                        );
                                      }),
                                ),
                                Material(
                                  color: (proispress)
                                      ? Color(0xFF1ccdaa)
                                      : apcolor,
                                  shape: CircleBorder(),
                                  clipBehavior: Clip.hardEdge,
                                  child: IconButton(
                                      icon: Icon(Icons.person),
                                      color:
                                          (proispress) ? mypink : Colors.white,
                                      onPressed: () {
                                        _scafkey.currentState.openEndDrawer();
                                        setState(() {
                                          homeispress = false;
                                          msgispress = false;
                                          notispress = false;
                                          proispress = true;
                                        });
                                      }),
                                ),
                              ],
                            ))
                      ],
                    ),
                  ),
                )
              ],
            )));
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  InputDecoration myInputDecoration({String label, IconData icon}) {
    return InputDecoration(
      hintText: label, //show label as placeholder
      alignLabelWithHint: true,
      suffixIcon: Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Icon(
            icon,
            color: Colors.black,
          )),
      contentPadding: EdgeInsets.fromLTRB(10, 10, 0, 10),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide:
              BorderSide(color: apcolor, width: 1)), //default border of input
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(color: apBcolor, width: 1)),
      fillColor: apcolor,
      filled: false, //set true if you want to show input background
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
