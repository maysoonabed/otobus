import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;
import 'package:OtoBus/configMaps.dart';
import 'package:OtoBus/dataProvider/address.dart';
import 'package:OtoBus/dataProvider/appData.dart';
import 'package:OtoBus/dataProvider/fUNCS.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'package:custom_switch/custom_switch.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:OtoBus/dataProvider/pushNoteficationsFire.dart';
import 'package:OtoBus/dataProvider/mapKit.dart';

DriverMapState globalState = new DriverMapState();

class DriverMap extends StatefulWidget {
  @override
  DriverMapState createState() => globalState;
}

Position currentPosition;
double destLatitude;
double destLongitude;
String currName;
String destName;
var currltlg;
var destltlg;
var pickUpLatLng;
String state = 'accepted';
bool acc;
Set<Marker> gMarkers = {};
Set<Circle> circles = {};
PolylinePoints polylinePoints = PolylinePoints();
Map<PolylineId, Polyline> polylines = {};
const keyPoStack = 'b302ddec67beb4a453f6a3b36393cdf0';
GoogleMapController newGoogleMapController;
BitmapDescriptor movingMarkerIcon;
Position myPos;
//////////////////////////////////////////////////////////////////
final GlobalKey _photopickey = GlobalKey();
File _prof;
String _profname;
var profile;
var fileImg;
String base64prof;
AssetImage img;
final picker = ImagePicker();
String name, email, phone;
var _namecon = TextEditingController();
var _emailcon = TextEditingController();
var _phonecon = TextEditingController();
//////////////////////////insurance Date/////////////////////////
var _insdate = TextEditingController();
DateTime _insT;
String date;
final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
final DateFormat serverFormater = DateFormat('dd-MM-yyyy');
DateTime displayDate;
String formatted;

//////////////////////////////////////////////////////////////////
class DriverMapState extends State<DriverMap> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.947351, 35.227163),
    zoom: 9.4746,
  );
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void creatMarker() {
    if (movingMarkerIcon == null) {
      BitmapDescriptor.fromAssetImage(
              ImageConfiguration(size: Size(1, 1)), 'lib/Images/icon2.png')
          .then((onValue) {
        movingMarkerIcon = onValue;
      });
    }
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
        //  pickUp.placeName = jsonDecode(data)['data'][0]['county'];
        currName = pickUp.placeName;
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
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void updMark() {
    gMarkers.removeWhere((marker) => marker.markerId.value == 'destination');
    Marker destMarker = Marker(
      markerId: MarkerId("destination"),
      position: destltlg,
      icon: BitmapDescriptor.defaultMarkerWithHue(90),
      infoWindow: InfoWindow(title: destName, snippet: 'Destination'),
    );
    gMarkers.add(destMarker);
  }

  //  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void endTrip() {
    state = 'ended';
    ridRef.child('status').set('ended');
    ridePosStream.cancel();
    gMarkers.removeWhere((marker) => marker.markerId.value == 'destination');
    gMarkers.removeWhere((marker) => marker.markerId.value == 'current');
    gMarkers.removeWhere((marker) => marker.markerId.value == 'moving');
    polylines.clear();
   setState(() {});
  }
  //  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  void putMarker() {
    LatLngBounds bounds;
    destLatitude = tripInfo.pickUp.latitude;
    destLongitude = tripInfo.pickUp.longitude;
    destltlg = tripInfo.pickUp;
    Marker currMarker = Marker(
      markerId: MarkerId("current"),
      position: currltlg,
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(title: currName, snippet: 'My Location'),
    );
    Marker destMarker = Marker(
      markerId: MarkerId("destination"),
      position: destltlg,
      icon: BitmapDescriptor.defaultMarkerWithHue(90),
      infoWindow: InfoWindow(title: destName, snippet: 'Destination'),
    );
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
      circleId: CircleId('destination'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 40,
      center: destltlg,
      fillColor: Colors.green,
    );
    circles.add(currCircle);
    circles.add(destCircle);
    //*************************************//
    if (currltlg.latitude > destltlg.latitude &&
        currltlg.longitude > destltlg.longitude) {
      bounds = LatLngBounds(southwest: destltlg, northeast: currltlg);
    } else if (currltlg.longitude > destltlg.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(currltlg.latitude, destLongitude),
          northeast: LatLng(destLatitude, destltlg.longitude));
    } else if (currltlg.longitude > destltlg.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destltlg.latitude, currltlg.longitude),
          northeast: LatLng(currltlg.latitude, destltlg.longitude));
    } else {
      bounds = LatLngBounds(southwest: currltlg, northeast: destltlg);
    }
    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void driverInfo() async {
    currUser = await FirebaseAuth.instance.currentUser;
    PushNotifications pushNot = PushNotifications();
    pushNot.initialize(context);
    pushNot.getToken();
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void putvalues() async {
    email = await FlutterSession().get('driveremail');
    name = await FlutterSession().get('name');
    var r = await FlutterSession().get('phone');
    phone = r.toString();
    var s = await FlutterSession().get('insdate');
    _insT = DateTime.parse(s);
    _namecon.text = name; //thisUser.name;
    _emailcon.text = email;
    _phonecon.text = phone; //thisUser.phone;

    thisDriver.begN = await FlutterSession().get('begN');
    var bLa = await FlutterSession().get('begLat');
    var bLo = await FlutterSession().get('begLng');
    thisDriver.endN = await FlutterSession().get('endN');
    var eLa = await FlutterSession().get('endLat');
    var eLo = await FlutterSession().get('endLng');
    thisDriver.busType = await FlutterSession().get('busType');
    thisDriver.numOfPass = await FlutterSession().get('numOfPass');
    thisDriver.begLoc = LatLng(bLa, bLo);
    thisDriver.endLoc = LatLng(eLa, eLo);
    print(thisDriver.begLoc.latitude.toString() +
        thisDriver.numOfPass.toString() +
        thisDriver.busType);
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void pic() async {
    var pic = await FlutterSession().get('profpic');
     setState(() {
      _profname = pic;
    });
    img = AssetImage('phpfiles/cardlic/$_profname');
    //print('phpfiles/cardlic/$_profname');
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Future upload(File img, String imgname) async {
    profile = Io.File(img.path).readAsBytesSync();
    base64prof = base64Encode(profile);
    String url =
        "http://192.168.1.108:8089/otobus/phpfiles/updatedriverimage.php"; //10.0.0.8//192.168.1.106:8089
    var response = await http.post(url, body: {
      'profimg': base64prof,
      'profname': imgname,
      'email': email,
    });
    if (response.statusCode == 200) {
      //print(jsonDecode(response.body));
    }
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Future updateinsdate(String formatted) async {
    String url =
        "http://192.168.1.108:8089/otobus/phpfiles/updateINSdate.php"; //10.0.0.8//192.168.1.106:8089
    var response =
        await http.post(url, body: {'endate': formatted, 'email': email});
    if (response.statusCode == 200) {
      //print(jsonDecode(response.body));
    }
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  @override
  void initState() {
    name = "";
    phone = "";
    email = "";
    acc = false;
    super.initState();
    driverInfo();
    putvalues();
    pic();
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
            child: Column(
              children: <Widget>[
                Stack(
                  overflow: Overflow.visible,
                  alignment: Alignment.center,
                  children: <Widget>[
                    Image(image: AssetImage('lib/Images/passengercover.jpg')),
                    Positioned(
                        key: _photopickey,
                        bottom: -50.0,
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.white,
                          backgroundImage: (_prof != null)
                              ? FileImage(_prof)
                              : (_profname != null
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
                              _prof = File(picked.path);
                              _profname = _prof.path.split('/').last;
                              upload(_prof, _profname);
                             setState(() {
                                img = AssetImage('phpfiles/cardlic/$_profname');
                              });
                            },
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  height: 70,
                ),
                Container(
                    child: TextField(
                  controller: _namecon,
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
                  height: 20,
                ),
                Container(
                  child: TextField(
                    controller: _emailcon,
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
                  height: 20,
                ),
                Container(
                  child: TextField(
                    controller: _phonecon,
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
                Container(
                    child: TextField(
                  readOnly: true,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.datetime,
                  controller: _insdate, //set username controller
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: "Lemonada"),
                  decoration: myInputDecoration(
                      label: "تحديث تاريخ انتهاء التأمين",
                      icon: Icons.date_range_rounded),
                  onTap: () {
                    showDatePicker(
                            builder: (BuildContext context, Widget child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: ColorScheme.light(
                                      primary: apcolor,
                                      onPrimary: Colors.white,
                                      surface: apBcolor,
                                      onSurface: Colors.black),
                                  dialogBackgroundColor: Colors.white,
                                ),
                                child: child,
                              );
                            },
                            context: context,
                            initialDate: _insT == null ? DateTime.now() : _insT,
                            firstDate: DateTime(DateTime.now().year,
                                DateTime.now().month, DateTime.now().day),
                            lastDate: DateTime(2100))
                        .then((value) {
                      setState(() {
                        _insT = value;
                        date = _insT.toString();
                        _insdate.text = DateFormat.yMMMd().format(value);
                        displayDate = displayFormater.parse(date);
                        formatted = serverFormater.format(displayDate);
                        updateinsdate(formatted);
                        //updateDate();
                      });
                      //print(formatted);
                    });
                  },
                )),
                SizedBox(
                  height: 20,
                ),
                MaterialButton(
                  color: apBcolor,
                  height: 30,
                  minWidth: 150.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  onPressed: () {
                    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
                    setState(() {
                      //box.remove('Email');
                      //auth.signOut();
                      //_prof = null;
                      //_profname = null;
                      globalState;
                      FlutterSession().set('driveremail', '');
                      FlutterSession().set('name', '');
                      FlutterSession().set('phone', '');
                      FlutterSession().set('profpic', '');
                    });
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
              onMapCreated: (GoogleMapController controller) async {
                _controller.complete(controller);
                newGoogleMapController = controller;
                await setupPositionLocator();
                currltlg =
                    LatLng(currentPosition.latitude, currentPosition.longitude);
                pickUpLatLng = tripInfo.pickUp;
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
                                                  destLatitude =
                                                      driverT.latitude;
                                                  destLongitude =
                                                      driverT.longitude;
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
                                                  destLatitude =
                                                      driverF.latitude;
                                                  destLongitude =
                                                      driverF.longitude;
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
              Icon(
                Icons.messenger,
                size: 25,
                color: Colors.white,
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

  void getPolyline() async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyDpIlaxbh4WTp4_Ecnz4lupswaRqyNcTv4",
      PointLatLng(currltlg.latitude, currltlg.longitude),
      PointLatLng(destLatitude, destLongitude),
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
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  void GoOnline() {
    Geofire.initialize('availableDrivers');
    Geofire.setLocation(
        currUser.uid, currentPosition.latitude, currentPosition.longitude);
     tripReq = FirebaseDatabase.instance
        .reference()
        .child('Drivers/${currUser.uid}/newTrip');
    tripReq.set('waiting'); 
    tripReq.onValue.listen((event) {});
  }
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  void GoOffline() {
    Geofire.removeLocation(currUser.uid);
    tripReq.onDisconnect();
    tripReq.remove();
    tripReq = null;
  }
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  void updateRideLocation() {
    LatLng oldP = LatLng(0, 0);
    ridePosStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    ).listen((Position position) {
      myPos = position;
      currentPosition = position;
      LatLng pos = LatLng(position.latitude, position.longitude);
      var rotate = MapKit.getMarkerRotation(
          oldP.latitude, oldP.longitude, pos.latitude, pos.longitude);
      Marker movingMarker = Marker(
        markerId: MarkerId('moving'),
        position: pos,
        icon: movingMarkerIcon,
        rotation: rotate,
        infoWindow: InfoWindow(title: 'الموقع الحالي'),
        onTap: () {
              if (state == 'accepted') {
            state = 'arrived';
            ridRef.child('status').set('arrived');
            setState(() {
              destLatitude = driverT.latitude;
              destLongitude = driverT.longitude;
              destltlg = LatLng(destLatitude, destLongitude);
              getPolyline();
              updMark();
            });
          } else if (state == 'arrived') {
            state = 'onTrip';
            ridRef.child('status').set('onTrip');
          } else if (state == 'onTrip') {
            endTrip();

            Funcs.enableLocUpdate();
          }
        },
      );
     setState(() {
        CameraPosition cp = new CameraPosition(target: pos, zoom: 17);
        newGoogleMapController
            .animateCamera(CameraUpdate.newCameraPosition(cp));
        gMarkers.removeWhere((marker) => marker.markerId.value == 'moving');
        gMarkers.add(movingMarker);
      });
      oldP = pos;
      Map locationMap = {
        'latitude': myPos.latitude,
        'longitude': myPos.longitude,
      };
      ridRef.child('driver_location').set(locationMap);
    });
  }
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  void updateTripDetails() async {
    if (myPos == null) return;
    var positionLt = LatLng(myPos.latitude, myPos.longitude);
    LatLng destLt;
    if (state == 'accepted') {
      destLt = tripInfo.pickUp;
    } else {
      destLt = tripInfo.dest;
    }
    var direcDetails;
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void acceptTrip() {
    String rideId = tripInfo.ridrReqId;

    ridRef = FirebaseDatabase.instance.reference().child('rideRequest/$rideId');
    ridRef.child('status').set('accepted');

    Map locationMap = {
      'latitude': currentPosition.latitude.toString(),
      'longitude': currentPosition.longitude.toString(),
    };
    ridRef.child('driver_location').set(locationMap);
    ridRef.child('driver_id').set(currUser.uid);
    ridRef.child('driver_phone').set(phone);

    /*   DatabaseReference numnum = FirebaseDatabase.instance
        .reference()
        .child('Drivers/${currUser.uid}/passengers');
    numnum.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        driverNum = driverNum - tripInfo.numb;
        numnum.set(driverNum);
      }
    }); */
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
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
}
