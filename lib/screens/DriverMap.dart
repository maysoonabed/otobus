import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;
import 'package:OtoBus/chat/PassChatDetailes.dart';
import 'package:OtoBus/chat/globalFunctions.dart';
import 'package:OtoBus/chat/passchat.dart';
import 'package:OtoBus/configMaps.dart';
import 'package:OtoBus/dataProvider/address.dart';
import 'package:OtoBus/dataProvider/appData.dart';
import 'package:OtoBus/dataProvider/fUNCS.dart';
import 'package:OtoBus/dataProvider/tripInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:gradient_bottom_navigation_bar/gradient_bottom_navigation_bar.dart';
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:OtoBus/chat/NotificChat.dart';
import 'package:firebase_core/firebase_core.dart';

DriverMapState globalState = new DriverMapState();

class DriverMap extends StatefulWidget {
  @override
  DriverMapState createState() => globalState;
}

TextEditingController _txtCtrl = TextEditingController();
Position currentPosition;
double destLongitude;
String currName;
String destName;
var currltlg;
var destltlg;
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
var _insalert = TextEditingController();
String roomId = "";
String passEmail = "";
String passName = "";
String passImgPath = "lib/Images/Defultprof.jpg";
String passPhone = "";
String path;
//////////////////////////insurance Date/////////////////////////
var _insdate = TextEditingController();
DateTime _insT;
String date;
final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
final DateFormat serverFormater = DateFormat('dd-MM-yyyy');
DateTime displayDate;
String formatted;
bool reqData = false;
File _insimg;
String _insname;
var insur;
String base64insu;
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

//////////////////////////////////////////////////////////////////
class DriverMapState extends State<DriverMap> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.947351, 35.227163),
    zoom: 9.4746,
  );
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  getInfoForChat(String dPhone) async {
    String apiurl =
        "http://192.168.1.108:8089/otobus/phpfiles/getdataforchat.php"; //10.0.0.8////192.168.1.108:8089
    var response = await http.post(apiurl, body: {'phone': dPhone});
    //print(response.body);
    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body);
      setState(() {
        passName = jsondata["name"];
        passEmail = jsondata["email"];
        path = jsondata["profpic"];
        if (path != "") {
          passImgPath = "phpfiles/cardlic/$path";
        }
      });
    }
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  int _selectedIndex = 1;
  final _widgetOptions = [
    Text('Index 0: Home'),
    Text('Index 1: Notification'),
    Text('Index 2: Messages'),
    Text('Index 2: Profile'),
  ];
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
        pickUp.placeName = jsonDecode(data)['data'][0]['label'].toString();
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
  /* void updMark() {
    gMarkers.removeWhere((marker) => marker.markerId.value == 'destination');
    Marker destMarker = Marker(
      markerId: MarkerId("destination"),
      position: destltlg,
      icon: BitmapDescriptor.defaultMarkerWithHue(90),
      infoWindow: InfoWindow(title: destName, snippet: 'Destination'),
    );
    gMarkers.add(destMarker);
  } */

  //  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void endTrip() {
    for (int i = 0; i < item.length; i++) {
      DatabaseReference reqq = FirebaseDatabase.instance
          .reference()
          .child('rideRequest/${item[i]['ridrReqId']}');
      reqq.child('status').set('ended');
      deletePassenger(item[i]['key'].toString());
      Funcs.enableLocUpdate();
      gMarkers.removeWhere(
          (marker) => marker.markerId.value == item[i]['ridrReqId']);
    }
    nnum.set(thisDriver.numOfPass);
    setState(() {
      accHeight = 0;
    });
    ridePosStream.cancel();
    gMarkers.removeWhere((marker) => marker.markerId.value == 'moving');
    setState(() {});
  }

  //  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void reqMarker() {
    Marker reqMarker = Marker(
      markerId: MarkerId(tripInfo.ridrReqId),
      position: tripInfo.pickUp,
      icon: BitmapDescriptor.defaultMarkerWithHue(200),
      infoWindow: InfoWindow(
          title: tripInfo.pickUpAdd,
          snippet: tripInfo.numb.toString() + 'ركاب'),
    );
    gMarkers.add(reqMarker);
  }
//  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  void putMarker() async {
    LatLngBounds bounds;
    await setupPositionLocator();
    currltlg = LatLng(currentPosition.latitude, currentPosition.longitude);
    Marker currMarker = Marker(
      markerId: MarkerId("Current"),
      position: currltlg,
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(title: currName, snippet: 'موقعي'),
    );
    Marker destMarker = Marker(
      markerId: MarkerId('Final_Destination'),
      position: destltlg,
      icon: BitmapDescriptor.defaultMarkerWithHue(90),
      infoWindow: InfoWindow(title: destName, snippet: "الوجهة"),
    );

    gMarkers.add(currMarker);
    gMarkers.add(destMarker);
    Circle currCircle = Circle(
      circleId: CircleId('current'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 10,
      center: currltlg,
      fillColor: Colors.green,
    );
    Circle destCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 10,
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
          southwest: LatLng(currltlg.latitude, destltlg.longitude),
          northeast: LatLng(destltlg.latitude, currltlg.longitude));
    } else if (currltlg.latitude > destltlg.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destltlg.latitude, currltlg.longitude),
          northeast: LatLng(currltlg.latitude, destltlg.longitude));
    } else {
      bounds = LatLngBounds(southwest: currltlg, northeast: destltlg);
    }
    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(bounds, 160));
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void driverInfo() async {
    currUser = await FirebaseAuth.instance.currentUser;
    PushNotifications pushNot = PushNotifications();
    pushNot.initialize(context);
    pushNot.getToken();
    /* NotificChat pushNotifc = NotificChat();
    pushNotifc.initialize(context); */
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void putvalues() async {
    email = await FlutterSession().get('driveremail');
    name = await FlutterSession().get('name');
    setState(() {
      thisDriver.email = email;
      thisDriver.name = name;
    });
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
    driverT = thisDriver.endLoc;
    driverF = thisDriver.begLoc;
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void pic() async {
    var pic = await FlutterSession().get('profpic');
    setState(() {
      if (pic != "") {
        _profname = pic;
        img = AssetImage('phpfiles/cardlic/$_profname');
      } else
        _profname = null;
    });
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
  Future upinspic(File img, String imgname) async {
    insur = Io.File(img.path).readAsBytesSync();
    base64insu = base64Encode(insur);
    String url =
        "http://192.168.1.108:8089/otobus/phpfiles/upinspic.php"; //10.0.0.8//192.168.1.106:8089
    var response = await http.post(url, body: {
      'insimg': base64insu,
      'insname': imgname,
      'email': email,
    });
    if (response.statusCode == 200) {
      //print(response.body);
    }
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  uupplloodd() async {
    var picked = await picker.getImage(source: ImageSource.gallery);
    _insimg = File(picked.path);
    _insname = _insimg.path.split('/').last;
    upinspic(_insimg, _insname);
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
  var driverInsDate = 0;
  var onoff;
  Future insphp() async {
    String url =
        "http://192.168.1.108:8089/otobus/phpfiles/insdate.php"; //10.0.0.8//192.168.1.106:8089
    var response = await http.post(url, body: {'email': email});
    //print(response.body);
    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body);
      driverInsDate = jsondata["insdate"];
      _insalert.text = (driverInsDate > 0)
          ? "لم يتبقى سوى $driverInsDate يوم على انتهاءالتأمين"
          : "لقد انتهى تأمينك يُرجى تجديده  ";
      onoff = jsondata["onofflag"];
      //print(driverInsDate);
    }
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  @override
  void initState() {
    name = "";
    phone = "";
    email = "";
    acc = false;
    acCount = 0;
    driverNum = thisDriver.numOfPass;
    super.initState();
    driverInfo();
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  bool status = false;
  bool backOn = false;
  int msgsCount = 0;
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  @override
  Widget build(BuildContext context) {
    //Firebase.initializeApp();
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    numUnredMsgs() {
      int count = 0;
      FirebaseFirestore.instance
          .collection('chatrooms')
          .where("users", arrayContains: thisDriver.email)
          .get()
          .then((val) {
        for (int i = 0; i < val.docs.length; i++) {
          if (val.docs[i]['lastmsgread'] == null) {
            break;
          } else if ((val.docs[i]['lastmsgread'] == false) &&
              (val.docs[i]['lastMessageSendBy'] != thisDriver.name)) {
            count++;
          }
        }
        if (mounted) {
          setState(() {
            msgsCount = count;
          });
        }
        //print(count);
      });
    }

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    putvalues();
    pic();
    numUnredMsgs();
    insphp();
    //driverInsDate <= 15 ? print(driverInsDate) : print("No");
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
                          key: _photopickey,
                          bottom: -20.0,
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
                                  img =
                                      AssetImage('phpfiles/cardlic/$_profname');
                                });
                              },
                            ),
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 30,
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
                    height: 10,
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
                    height: 10,
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
                    height: 10,
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
                              initialDate:
                                  _insT == null ? DateTime.now() : _insT,
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
                          uupplloodd();
                          //updateDate();
                        });
                        //print(formatted);
                      });
                    },
                  )),
                  SizedBox(
                    height: 10,
                  ),
                  driverInsDate <= 15
                      ? Container(
                          child: TextField(
                              controller: _insalert,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: "Lemonada",
                              ),
                              readOnly: true,
                              autofocus: false,
                              decoration: InputDecoration(
                                suffixIcon: Padding(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: Icon(
                                      Icons.bus_alert,
                                      color: Colors.white,
                                    )),
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 10, 0, 10),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.red,
                                        width: 1)), //default border of input
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide:
                                        BorderSide(color: apBcolor, width: 1)),
                                fillColor: Colors.red,
                                filled:
                                    true, //set true if you want to show input background
                              )),
                        )
                      : Container(),
                  SizedBox(
                    height: 10,
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
                            //box.remove('Email');
                            //auth.signOut();
                            //_prof = null;
                            //_profname = null;
                            //globalState;
                            FlutterSession().set('driveremail', '');
                            FlutterSession().set('name', '');
                            FlutterSession().set('phone', '');
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
                    height: 40,
                  ),
                ],
              ),
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
              },
            ),
            (driverInsDate > 0)
                ? Padding(
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      child: driverInsDate != 0
                                          ? Row(
                                              children: <Widget>[
                                                Expanded(
                                                    child: InkWell(
                                                        onTap: () {
                                                          Map toMap = {
                                                            'latitude':
                                                                thisDriver
                                                                    .endLoc
                                                                    .latitude,
                                                            'longitude':
                                                                thisDriver
                                                                    .endLoc
                                                                    .longitude
                                                          };
                                                          whereTo.set(toMap);

                                                          setState(() {
                                                            driverT = thisDriver
                                                                .endLoc;
                                                            destName =
                                                                thisDriver.endN;
                                                            destltlg =
                                                                thisDriver
                                                                    .endLoc;

                                                            putMarker();
                                                            getPolyline();

                                                            backOn = false;
                                                          });
                                                        },
                                                        child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          decoration: BoxDecoration(
                                                              color: backOn
                                                                  ? Colors.white
                                                                  : iconBack,
                                                              borderRadius: BorderRadius.only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          12),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          12))),
                                                          child: Text("ذهاب",
                                                              style: TextStyle(
                                                                color: backOn
                                                                    ? iconBack
                                                                    : Colors
                                                                        .white,
                                                                fontSize: 12,
                                                              )),
                                                        ))),
                                                Expanded(
                                                    child: InkWell(
                                                        onTap: () {
                                                          Map toMap = {
                                                            'latitude':
                                                                thisDriver
                                                                    .begLoc
                                                                    .latitude,
                                                            'longitude':
                                                                thisDriver
                                                                    .begLoc
                                                                    .longitude
                                                          };
                                                          whereTo.set(toMap);
                                                          /////مشكوك في أمرها  تزكريييييهههههههاااااا
                                                          setState(() {
                                                            destName =
                                                                thisDriver.begN;
                                                            driverT = thisDriver
                                                                .begLoc;

                                                            destltlg =
                                                                thisDriver
                                                                    .begLoc;
                                                            putMarker();
                                                            getPolyline();

                                                            backOn = true;
                                                          });
                                                        },
                                                        child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          decoration: BoxDecoration(
                                                              color: backOn
                                                                  ? iconBack
                                                                  : Colors
                                                                      .white,
                                                              borderRadius: BorderRadius.only(
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          12),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          12))),
                                                          child: Text("عودة",
                                                              style: TextStyle(
                                                                color: backOn
                                                                    ? Colors
                                                                        .white
                                                                    : iconBack,
                                                                fontSize: 12,
                                                              )),
                                                        ))),
                                              ],
                                            )
                                          : Container(),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 0.1,
                                  width: 0.1,
                                ),
                          CustomSwitch(
                            activeColor: iconBack,
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
                : Container(),
            //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(1.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16),
                        topLeft: Radius.circular(16)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: 0.5,
                          blurRadius: 16,
                          color: Colors.black54,
                          offset: Offset(0.7, 0.7)),
                    ]),
                height: accHeight,
                child: Column(
                  children: [
                    firebaseRef != null
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'الوجهة',
                                  textAlign: TextAlign.end,
                                ),
                                Text(
                                  'الموقع',
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                          )
                        : Container(
                            height: 0,
                          ),
                    Divider(),
                    Flexible(
                      child: firebaseRef != null
                          ? StreamBuilder(
                              stream: firebaseRef.onValue,
                              builder: (context, snap) {
                                if (snap.hasData &&
                                    !snap.hasError &&
                                    snap.data.snapshot.value != null) {
                                  reqData = true;
                                  Map data = snap.data.snapshot.value;
                                  item = [];
                                  data.forEach((index, data) {
                                    item.add({"key": index, ...data});
                                  });
                                  /*    for (int i = 0; i < item.length; i++) {
                                    gMarkers.add(Marker(
                                      markerId: MarkerId(item[i]['ridrReqId']),
                                      position: LatLng(
                                          double.parse(item[i]['pickUpLat']),
                                          double.parse(item[i]['pickUpLng'])),
                                      icon:
                                          BitmapDescriptor.defaultMarkerWithHue(
                                              90),
                                      infoWindow: InfoWindow(
                                          title: destName,
                                          snippet: 'passenger' + i.toString()),
                                    ));
                                  } */

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: item.length,
                                    itemBuilder: (context, index) {
                                      /*              return ListTile(
      contentPadding: EdgeInsets.all(10.0),
      leading: _thumbnail(item),
      title: _title(
          item.title, TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
      subtitle: _title(item.subtitle, TextStyle(fontSize: 14.0)),
      onTap: () {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Tile ${item.title} clicked"),
        )); */
                                      return ListTile(
                                        contentPadding: EdgeInsets.only(
                                            left: 90, right: 60),
                                        title: Text(
                                            getFstWord(item[index]['destAdd'])),
                                        trailing: Text(getSndWord(
                                            item[index]['pickUpAdd'])),
                                        onTap: () {
                                          DatabaseReference reqq = FirebaseDatabase
                                              .instance
                                              .reference()
                                              .child(
                                                  'rideRequest/${item[index]['ridrReqId']}');
                                          reqq
                                              .once()
                                              .then((DataSnapshot snapshot) {
                                            if (snapshot.value != null) {
                                              String ss = snapshot
                                                  .value['status']
                                                  .toString();
                                              if (ss == 'accepted') {
                                                reqq
                                                    .child('status')
                                                    .set('arrived');
                                                setState(() {
                                                  getPolyline();
                                                  //updMark();
                                                });
                                              } else if (ss == 'arrived') {
                                                reqq
                                                    .child('status')
                                                    .set('onTrip');
                                                gMarkers.removeWhere((marker) =>
                                                    marker.markerId.value ==
                                                    item[index]['ridrReqId']);
                                              } else if (ss == 'onTrip') {
                                                reqq
                                                    .child('status')
                                                    .set('ended');
                                                deletePassenger(item[index]
                                                        ['key']
                                                    .toString());
                                                driverNum = driverNum +
                                                    int.parse(
                                                        item[index]['numb']);
                                                nnum.set(driverNum);
                                                Funcs.enableLocUpdate();
                                              }
                                            }
                                          });
                                        },
                                      );
                                    },
                                  );
                                } else {
                                  reqData = false;
                                  return Center(
                                      child: Text(
                                    "لا يوجد ركاب حاليًا",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontFamily: "Lemonada",
                                    ),
                                  ));
                                }
                              },
                            )
                          : Container(
                              height: 0,
                            ),
                    ),
                  ],
                ),
              ),
            ),
            accHeight != 0 && reqData == true
                ? Positioned(
                    bottom: 0,
                    left: MediaQuery.of(context).size.width / 2 - 40,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(60.0),
                            ),
                            primary: apBcolor,
                            padding:
                                EdgeInsets.only(top: 5, left: 10, right: 10),
                            textStyle: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          endTrip();
                        },
                        child: Text('إنهاء الرحلة')),
                  )
                : Container(
                    height: 0,
                  ),
          ]),
          bottomNavigationBar: GradientBottomNavigationBar(
            backgroundColorStart: Color(0xFF64726f),
            backgroundColorEnd: Color(0xFF01d5ab),
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), title: Text('الخريطة')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications), title: Text('الإشعارات')),
              BottomNavigationBarItem(
                  icon: new Stack(
                    children: <Widget>[
                      Icon(
                        Icons.messenger,
                        size: 25,
                        color: Colors.white,
                      ), //Icons.message_outlined
                      new Positioned(
                        right: 0,
                        child: new Container(
                          padding: EdgeInsets.all(1),
                          decoration: new BoxDecoration(
                            color: (msgsCount > 0)
                                ? Colors.red
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 17,
                            minHeight: 17,
                          ),
                          child: new Text(
                            (msgsCount > 0) ? '$msgsCount' : '',
                            style: new TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  ),
                  title: Text('الرسائل')),
              BottomNavigationBarItem(
                  icon: new Stack(
                    children: <Widget>[
                      Icon(
                        Icons.person,
                        size: 25,
                        color: Colors.white,
                      ), //Icons.message_outlined
                      new Positioned(
                        right: 0,
                        child: new Container(
                          padding: EdgeInsets.only(left: 15, bottom: 15),
                          child: (driverInsDate <= 15)
                              ? Icon(
                                  Icons.sd_card_alert_sharp,
                                  size: 15,
                                  color: Colors.red,
                                )
                              : null,
                        ),
                      )
                    ],
                  ),
                  title: Text('الصفحة الشخصية')),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ));
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 1) {
      passPhone = "187";
      getInfoForChat(passPhone);
      roomId = globalFunctions().creatChatRoomInfo(thisDriver.email, passEmail);
      //print(roomId);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PassChatDetailes(
                    username: passName,
                    imageURL: passImgPath,
                    useremail: passEmail,
                    roomID: roomId,
                    sendername: thisDriver.name,
                  )));
    } else if (_selectedIndex == 2) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PassChat(thisDriver.email, thisDriver.name)));
    } else if (_selectedIndex == 3) {
      _scaffoldkey.currentState.openEndDrawer();
    }
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
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

    /*  for (int i = 0; i < picks.length; i++) {
      print(picks[i].latitude.toString() + ' ' + picks[i].longitude.toString());
    } */
    /*  double distanceInMeters = Geolocator.distanceBetween(
        tripInfo.pickUp.latitude,
        tripInfo.pickUp.longitude,
        currentPosition.latitude,
        currentPosition.longitude);
    print(distanceInMeters.toString()); */

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyDpIlaxbh4WTp4_Ecnz4lupswaRqyNcTv4",
      PointLatLng(currltlg.latitude, currltlg.longitude),
      PointLatLng(destltlg.latitude, destltlg.longitude),
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
    nnum = FirebaseDatabase.instance
        .reference()
        .child('Drivers/${currUser.uid}/passengers');
    nnum.set(driverNum);
    whereTo = FirebaseDatabase.instance
        .reference()
        .child('Drivers/${currUser.uid}/whereTo');
    Map toMap = {
      'latitude': thisDriver.endLoc.latitude,
      'longitude': thisDriver.endLoc.longitude
    };
    whereTo.set(toMap);
    firebaseRef = FirebaseDatabase()
        .reference()
        .child('Drivers/${currUser.uid}/acceptedReqs');
    setState(() {
      destName = thisDriver.endN;
      destltlg = thisDriver.endLoc;
      putMarker();
      getPolyline();
    });
  }
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  void GoOffline() {
    Geofire.removeLocation(currUser.uid);
    tripReq.onDisconnect();
    tripReq.remove();
    tripReq = null;
    nnum.onDisconnect();
    nnum.remove();
    nnum = null;
    whereTo.onDisconnect();
    whereTo.remove();
    whereTo = null;
    gMarkers
        .removeWhere((marker) => marker.markerId.value == 'Final_Destination');
    gMarkers.removeWhere((marker) => marker.markerId.value == 'Current');
    gMarkers.removeWhere((marker) => marker.markerId.value == 'moving');
    polylines.clear();
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
    setState(() {
      accHeight = 200;
    });
    Map locationMap = {
      'latitude': currentPosition.latitude.toString(),
      'longitude': currentPosition.longitude.toString(),
    };
    ridRef.child('driver_location').set(locationMap);
    ridRef.child('driver_id').set(currUser.uid);
    ridRef.child('driver_phone').set(phone);
    driverNum = driverNum - tripInfo.numb;
    nnum.set(driverNum);
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

deletePassenger(key) {
  firebaseRef.child(key).remove();
}

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
String getSndWord(String input) {
  int i = input.indexOf(',');
  String rest = input.substring(i + 1, input.length - 1);
  i = rest.indexOf(',');
  String word = rest.substring(0, i);
  return word;
}

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
String getFstWord(String input) {
  int i = input.indexOf(',');
  String word = input.substring(0, i);
  return word;
}
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
