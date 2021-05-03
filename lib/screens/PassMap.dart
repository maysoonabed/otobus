import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;
import 'package:OtoBus/chat/PassChatDetailes.dart';
import 'package:OtoBus/chat/globalFunctions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:OtoBus/dataProvider/address.dart';
import 'package:OtoBus/dataProvider/appData.dart';
import 'package:OtoBus/dataProvider/fireDrivers.dart';
import 'package:OtoBus/dataProvider/nearDriver.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../configMaps.dart';
import '../main.dart';
import 'dart:math' show cos, sqrt, asin;
import '../chat/passchat.dart';

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
var disltlg;
var driverltlg;
bool nearLoaded = false;
var src_loc = TextEditingController();
var distance = TextEditingController();
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
BitmapDescriptor myIcon;
final picker = ImagePicker();
File _prof;
String _profname;
String st1, st2, st3;
AssetImage img;
bool showprogress = false;
var profile;
String base64prof = "";
var fileImg;
var _namecon = TextEditingController();
var _emailcon = TextEditingController();
var _phonecon = TextEditingController();
String roomId = "";
String drivEmail = "";
String drivName = "";
String drivImgPath = "lib/Images/Defultprof.jpg";
String drivPhone = "";
String path;

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
class _PassMapState extends State<PassMap> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  final GlobalKey _photopickey = GlobalKey();
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController newGoogleMapController;
  double totalDistance = 0.0;
  double llat, llng;
  DatabaseReference rideReq;
  bool reqbook = true;
  bool unbook = true;
  Adress destprv = new Adress();
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.947351, 35.227163),
    zoom: 9.4746,
  );
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void initState() {
    name = ""; //thisUser.name != null ? thisUser.name :
    phone = ""; //thisUser.phone != null ? thisUser.phone :
    email = ""; //thisUser.email != null ? thisUser.email :
    errormsg = "";
    error = false;
    homeispress = false;
    msgispress = false;
    notispress = false;
    proispress = false;
    super.initState();
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Future upload(File img, String imgname) async {
    profile = Io.File(img.path).readAsBytesSync();
    base64prof = base64Encode(profile);
    String url =
        "http://192.168.1.108:8089/otobus/phpfiles/updatepass.php"; //10.0.0.8//192.168.1.106:8089
    var response = await http.post(url, body: {
      'profimg': base64prof,
      'profname': imgname,
      'email': email,
    });
    if (response.statusCode == 200) {}
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  getInfoForChat(String dPhone) async {
    String apiurl =
        "http://192.168.1.108:8089/otobus/phpfiles/getdataforchat.php"; //10.0.0.8////192.168.1.108:8089
    var response = await http.post(apiurl, body: {'phone': dPhone});
    //print(response.body);
    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body);
      setState(() {
        drivName = jsondata["name"];
        drivEmail = jsondata["email"];
        path = jsondata["profpic"];
        if (path != "") {
          drivImgPath = "phpfiles/cardlic/$path";
        }
      });
    }
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void getData(double lat, double long) async {
    http.Response response = await http.get(
        'http://api.positionstack.com/v1/reverse?access_key=$keyPoStack&query=$lat,$long');

    if (response.statusCode == 200) {
      String data = response.body;
      setState(() {
        Adress pickUp = new Adress();
        pickUp.placeName = jsonDecode(data)['data'][0]['label'];
        //pickUp.placeName = jsonDecode(data)['data'][0]['county'];
        pickUp.lat = lat;
        pickUp.long = long;
        _currName = pickUp.placeName;
        src_loc.text = _currName;
        llat = lat;
        llng = long;
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
  void putvalues() async {
    thisUser.email = await FlutterSession().get('passemail');
    thisUser.name = await FlutterSession().get('name');
    var r = await FlutterSession().get('phone');
    thisUser.phone = r.toString();
    setState(() {
      _namecon.text = thisUser.name;
      email = _emailcon.text = thisUser.email;
      _phonecon.text = thisUser.phone;
    });
    /* if (_emailcon.text == "") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
    } */
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
  void createRequest() {
    //print(email);print(name);print(phone);
    rideReq = FirebaseDatabase.instance.reference().child('rideRequest').push();
    var pickUp = Provider.of<AppData>(context, listen: false).pickUpAdd;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;
    //print(pickUp);
    //print(destination);
    Map pickUpMap = {
      'longitude': pickUp.long.toString(),
      'latitude': pickUp.lat.toString(),
    };
    Map destinationMap = {
      'longitude': destination.long.toString(),
      'latitude': destination.lat.toString(),
    };
    Map rideMap = {
      'createdAt': DateTime.now().toString(),
      'passengerName': thisUser.name,
      'passengerPhone': thisUser.phone,
      'pickUpAddress': pickUp.placeName,
      'destinationAddress': destination.placeName,
      'location': pickUpMap,
      'destination': destinationMap,
      'driver_id': 'waiting',
      'status': 'waiting',
    };
    rideReq.set(rideMap);
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void cancelReq() {
    rideReq.remove();
    setState(() {
      markers.clear();
      circles.clear();
      polylines.clear();
    });
    LatLng pos = LatLng(_originLatitude, _originLongitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cp));
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void butMarker() {
    currltlg = LatLng(_originLatitude, _originLongitude);
    destltlg = LatLng(_destLatitude, _destLongitude);
    disltlg = LatLng((_originLatitude + _destLatitude) / 2,
        (_originLongitude + _destLongitude) / 2);
    Marker currMarker = Marker(
        markerId: MarkerId("current"),
        position: currltlg,
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: _currName, snippet: 'My Location'));
    Marker destMarker = Marker(
        markerId: MarkerId("destination"),
        position: destltlg,
        icon: BitmapDescriptor.defaultMarkerWithHue(90), //myIcon,
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
      strokeColor: Colors.black,
      strokeWidth: 1,
      radius: 80,
      center: destltlg,
      fillColor: apcolor,
    );
    circles.add(currCircle);
    circles.add(destCircle);
  }

  _bounds() {
    LatLngBounds bounds;
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

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void driversMarkers() {
    for (NearDrivers driver in FireDrivers.nDrivers) {
      setState(() {
        driverltlg = LatLng(driver.lat, driver.long);

        Marker driversmark = Marker(
          markerId: MarkerId("drivmk"),
          position: driverltlg,
          icon: BitmapDescriptor.defaultMarkerWithHue(30),
        );
        markers.add(driversmark);
      });
    }
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void startGeoListen() {
    Geofire.initialize('availableDrivers');
    Geofire.queryAtLocation(
            _originLatitude, _originLongitude, 5) //بدنا نغير ال5 كيلو
        .listen((map) {
      // print(map);
      if (map != null) {
        var callBack = map['callBack'];
        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']
        switch (callBack) {
          case Geofire.onKeyEntered:
            NearDrivers nDriver = NearDrivers();
            nDriver.key = map['key'];
            nDriver.lat = map['latitude'];
            nDriver.long = map['longitude'];
            FireDrivers.nDrivers.add(nDriver);
            if (nearLoaded) {
              driversMarkers();
            }
            break;

          case Geofire.onKeyExited:
            FireDrivers.removeDriver(map['key']);
            driversMarkers();
            break;

          case Geofire.onKeyMoved:
            // Update your key's location
            NearDrivers nDriver = NearDrivers();
            nDriver.key = map['key'];
            nDriver.lat = map['latitude'];
            nDriver.long = map['longitude'];
            FireDrivers.updateDriver(nDriver);
            driversMarkers();
            break;
          case Geofire.onGeoQueryReady:
            // All Intial Data is loaded
            nearLoaded = true;
            driversMarkers();
            //  print(map['result']);

            break;
        }
      }
    });
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
                    decoration: new InputDecoration(labelText: 'مكانك الحالي'),
                  ),
                ),
                new Expanded(
                  child: CustomTextField(
                    readOnly: true,
                    hintText: "اختر المكان الذي ترغب بالذهاب إليه",
                    textController: _startPointController,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapBoxAutoCompleteWidget(
                            apiKey: tokenkey,
                            hint: "ادخل اسم المدينة أو القرية",
                            closeOnSelect: true,
                            onSelect: (place) {
                              var str = place.placeName.toString();
                              var ss = str.split(',');
                              _startPointController.text = ss[0];
                              setState(() {
                                _destLatitude = place.center[1];
                                _destLongitude = place.center[0];
                                _destName = place.placeName;
                                destprv.placeName = _destName;
                                destprv.lat = _destLatitude;
                                destprv.long = _destLongitude;
                                Provider.of<AppData>(context, listen: false)
                                    .updateDestAddress(destprv);
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
                            language: 'ar',
                          ),
                        ),
                      );
                    },
                    enabled: true,
                  ),
                ),
                /*  new Expanded(
                  child: new TextField(
                    controller: distance,
                    readOnly: true,
                    minLines: 1,
                    maxLines: null,
                    autofocus: false,
                    decoration: new InputDecoration(labelText: 'المسافة'),
                  ),
                ), */
              ],
            )),
        actions: <Widget>[
          new FlatButton(
              child: const Text('إنهاء'),
              onPressed: () {
                Navigator.pop(context);
              }),
          new FlatButton(
              child: const Text('اختيار'),
              onPressed: () {
                setState(() {
                  _getPolyline();
                  butMarker();
                  _bounds();
                });
                Navigator.pop(context);
              })
        ],
      ),
      context: context,
    );
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  /*  int msgsCount = 0;
  gg() async {
    msgsCount = await globalFunctions().numUnredMsgs();
  } */

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    final Size size = MediaQuery.of(context).size;

    @override
    void initState() {
      BitmapDescriptor.fromAssetImage(
              ImageConfiguration(size: Size(1, 1)), 'lib/Images/icon2.png')
          .then((onValue) {
        myIcon = onValue;
      });

      homeispress = true;
      msgispress = false;
      notispress = false;
      proispress = false;
    }

    pic();
    initState();
    putvalues();
    //gg();
    // print(msgsCount);
    return MaterialApp(
        debugShowCheckedModeBanner: false, //لإخفاء شريط depug
        home: Scaffold(
          key: _scaffoldkey,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            //leading: new Container(),
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
                  height: 50,
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
                      markers.clear();
                      markers.clear();
                      polylines.clear();
                      homeispress = false;
                      msgispress = false;
                      notispress = false;
                      proispress = false;
                      _destName = "";
                      _startPointController.text = "";
                      //box.remove('Email');
                      //auth.signOut();
                      FlutterSession().set('passemail', '');
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
                  //setState(() {});
                  mapBottomPadding = 65;

                  setupPositionLocator();
                },
              ),
              markers.length > 1
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 170, right: 60),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton.extended(
                          backgroundColor: apBcolor,
                          isExtended: reqbook,
                          onPressed: () {
                            if (reqbook) {
                              createRequest();
                              startGeoListen();
                            }
                            setState(
                              () {
                                reqbook = false;
                              },
                            );
                          },
                          label: reqbook
                              ? Row(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.directions_bus),
                                    ),
                                    Text("اظهار الباصات"),
                                  ],
                                )
                              : Icon(Icons.directions_bus),
                        ),
                      ),
                    )
                  : Container(
                      height: 0.1,
                      width: 0.1,
                    ),
              markers.length > 1
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 120, right: 60),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton.extended(
                          backgroundColor: Colors.red,
                          isExtended: unbook,
                          onPressed: () {
                            setState(
                              () {
                                unbook = !unbook;
                              },
                            );
                            cancelReq();
                          },
                          label: unbook
                              ? Row(
                                  children: <Widget>[
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Icon(Icons.remove)),
                                    Text("إخفاء الباصات"),
                                  ],
                                )
                              : Icon(Icons.bus_alert),
                        ),
                      ),
                    )
                  : Container(
                      height: 0.1,
                      width: 0.1,
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
                            totalDistance = 0.0;
                            llat = _originLatitude;
                            llng = _originLongitude;
                            reqbook = true;
                            unbook = true;
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

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PassChat(
                                                  thisUser.email,
                                                  thisUser.name)));

                                      //_scaffoldkey.currentState.openDrawer();
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
                                      drivPhone = "054584";
                                      getInfoForChat(drivPhone);
                                      roomId = globalFunctions()
                                          .creatChatRoomInfo(
                                              thisUser.email, drivEmail);
                                      //print(roomId);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PassChatDetailes(
                                                    username: drivName,
                                                    imageURL: drivImgPath,
                                                    useremail: drivEmail,
                                                    roomID: roomId,
                                                  )));
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
  _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      width: 3,
      color: myblue,
    );
    polylines[id] = polyline;
  }

  void shared() {}
  double calcDistance(double plat, double plng, double llat, double llng) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((llat - plat) * p) / 2 +
        c(plat * p) * c(llat * p) * (1 - c((llng - plng) * p)) / 2;
    return 12742 * asin(sqrt(a));
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
        totalDistance +=
            calcDistance(point.latitude, point.longitude, llat, llng);
        llat = point.latitude;
        llng = point.longitude;
      });
    } else {
      print(result.errorMessage);
    }
    setState(() {
      distance.text = totalDistance.toStringAsFixed(2) +
          " km"; //المشكلة انه ما بصفر القيمة/ 80.0) * 100)
    });
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
