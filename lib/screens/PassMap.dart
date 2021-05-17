import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;
import 'package:OtoBus/chat/PassChatDetailes.dart';
import 'package:OtoBus/chat/globalFunctions.dart';
import 'package:OtoBus/dataProvider/fUNCS.dart';
import 'package:OtoBus/screens/rating.dart';
import 'package:cube_transition/cube_transition.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:OtoBus/chat/NotificChat.dart';
import 'package:page_transition/page_transition.dart';
import 'driverInfoBottomSheet.dart';
import 'noDriversDialog.dart';

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
AssetImage img;
var profile;
String base64prof = "";
var fileImg;
String st1, st2, st3;
bool showprogress = false;
var _namecon = TextEditingController();
var _emailcon = TextEditingController();
var _phonecon = TextEditingController();
String roomId = "";
String drivEmail = "";
String drivName = "";
String drivImgPath = "lib/Images/Defultprof.jpg";
String drivPhone = "";
String path;
String oneNamePlace;

StreamSubscription<Event> ridestreams;
String driverPhone;
String errmsg;
bool reqPosDet = false;
List<NearDrivers> availableDrivers;
DatabaseReference rideReq;
DatabaseReference driverRef =
    FirebaseDatabase.instance.reference().child('Drivers');
String stat = 'normal';

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
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(1, 1)), 'lib/Images/icon2.png')
        .then((onValue) {
      myIcon = onValue;
    });
    homeispress = true;
    msgispress = false;
    notispress = false;
    proispress = false;
    super.initState();
    setupPositionLocator();
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
    setState(() {
      currentPosition = position;
      LatLng pos = LatLng(currentPosition.latitude, currentPosition.longitude);
      CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
      newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cp));
    });
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

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  favlist(String favname, double lattt, double longgg, context) {
    return GestureDetector(
        onTap: () {
          setState(() {
            _startPointController.text = favname;
            _destLatitude = lattt;
            _destLongitude = longgg;
            _destName = favname;
            destprv.placeName = _destName;
            destprv.lat = _destLatitude;
            destprv.long = _destLongitude;
          });
          Provider.of<AppData>(context, listen: false)
              .updateDestAddress(destprv);
          LatLng posd = LatLng(_destLatitude, _destLongitude);
          CameraPosition cpd = new CameraPosition(target: posd, zoom: 14);
          newGoogleMapController
              .animateCamera(CameraUpdate.newCameraPosition(cpd));
          _searchDialog();
          Navigator.of(context).pop();
        },
        child: Container(
          color: Colors.transparent, //Color(0xFF01d5ab), //(0xFF548279)
          child: Column(
            children: [
              Container(
                color: Color(0xFF1fdeb9), //Color(0xFF4b8b7e), //
                //padding: EdgeInsets.only(left: 40),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Icon(
                        Icons.star_sharp,
                        color: Colors.amber,
                        size: 35,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        color: Colors.transparent,
                        child: Text(
                          favname,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Lemonada'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ));
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
                Row(
                  children: [
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
                          controller: _startPointController,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapBoxAutoCompleteWidget(
                                  apiKey: tokenkey,
                                  hint: "حدد وجهتك",
                                  closeOnSelect: true,
                                  onSelect: (place) {
                                    var str = place.placeName.toString();
                                    var ss = str.split(',');
                                    setState(() {
                                      oneNamePlace = ss[0];
                                      _startPointController.text = oneNamePlace;
                                      _destLatitude = place.center[1];
                                      _destLongitude = place.center[0];
                                      _destName = place.placeName;
                                      destprv.placeName = _destName;
                                      destprv.lat = _destLatitude;
                                      destprv.long = _destLongitude;
                                      Provider.of<AppData>(context,
                                              listen: false)
                                          .updateDestAddress(destprv);
                                      LatLng posd =
                                          LatLng(_destLatitude, _destLongitude);
                                      CameraPosition cpd = new CameraPosition(
                                          target: posd, zoom: 14);
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
                    ),
                    (_startPointController.text == "")
                        ? Container()
                        : IconButton(
                            icon: Icon(
                              Icons.star_sharp,
                              color: Colors.amber,
                            ),
                            onPressed: () {
                              Map<String, dynamic> newFav = {
                                "FavPlaceName": oneNamePlace,
                                "lattitude": _destLatitude,
                                "longitude": _destLongitude
                              };
                              Future addnewplace(
                                  Map newplace, String oneNamePlace) async {
                                return FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(currUser.uid)
                                    .collection("favorit")
                                    .doc(oneNamePlace)
                                    .set(newplace);
                              }

                              addnewplace(newFav, oneNamePlace);
                              Navigator.pop(context);
                              _scaffoldkey.currentState.openDrawer();
                            },
                          ),
                  ],
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

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  void updateDriTime(LatLng driverCurrLoc) async {
    if (reqPosDet == false) {
      reqPosDet = true;
      var pos = LatLng(_originLatitude, _originLongitude);
      String time = await calcTime(pos, driverCurrLoc);
      setState(() {
        arrivalStatus = ' سيصل الباص بحدود ' + time /* + " دقائق " */;
      });
      reqPosDet = false;
    }
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void updateTripTime(LatLng driverCurrLoc) async {
    if (reqPosDet == false) {
      reqPosDet = true;
      var posAdd =
          Provider.of<AppData>(context, listen: false).destinationAddress;
      var pos = LatLng(posAdd.lat, posAdd.long);
      String time = await calcTime(pos, driverCurrLoc);
      setState(() {
        arrivalStatus = ' باقٍ على الوصول للوجهة ' + time /* + 'دقائق' */;
      });
      reqPosDet = false;
    }
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Future<String> calcTime(LatLng source, LatLng dest) async {
    http.Response response = await http.get(
        'https://maps.googleapis.com/maps/api/distancematrix/json?origins=${source.latitude},${source.longitude}&destinations=side_of_road:${dest.latitude},${dest.longitude}&key=$googlekey');
    //rows[0].elements[0].duration.text
    if (response.statusCode == 200) {
      String data = response.body;
      String input =
          jsonDecode(data)['rows'][0]['elements'][0]['duration']['text'];
      int i = input.indexOf(' ');
      String word = input.substring(0, i);
      return word + ' دقائق ';
    }
    return 'لم يحدد';
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  getRatings() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    String apiurl =
        "http://192.168.1.108:8089/otobus/phpfiles/avgRatings.php"; //10.0.0.8//
    var response = await http.post(apiurl, body: {
      'phone': theDriver.phone, //get the username text
    });

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      if (jsondata["error"] == 1) {
        errormsg = jsondata["message"];
      } else {
        if (jsondata["success"] == 1) {
          print(jsondata['cou']);
          rateCount = int.parse(jsondata['cou']);
          s1 = int.parse(jsondata['cnt1']);
          s2 = int.parse(jsondata['cnt2']);
          s3 = int.parse(jsondata['cnt3']);
          s4 = int.parse(jsondata['cnt4']);
          s5 = int.parse(jsondata['cnt5']);

          errormsg = jsondata["message"];
        } else {
          errormsg = "حدث خطأ";
        }
      }
    } else {
      errormsg = "حدث خطأ أثناء الاتصال بالشبكة";
    }
    Fluttertoast.showToast(
      context,
      msg: errormsg,
    );
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Future<void> displayDriverDetails() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    String apiurl =
        "http://192.168.1.108:8089/otobus/phpfiles/getDriverInfo.php"; //10.0.0.9//
    var response = await http.post(apiurl, body: {
      'phone': driverPhone,
    });
    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      if (jsondata["error"] == 1) {
        errmsg = jsondata["message"];
      } else {
        theDriver.phone = driverPhone;
        theDriver.name = jsondata["name"];
        theDriver.pic = jsondata['profpic'];
        theDriver.begN = jsondata['begN'];
        theDriver.endN = jsondata['endN'];
        theDriver.busType = jsondata["busType"];

        var x = jsondata["rate"];
        theDriver.rate = double.parse(x);
        var xx = jsondata["numOfPass"];
        theDriver.numOfPass = int.parse(xx);
        getRatings();
        errmsg = jsondata["message"];
      }
    } else {
      errmsg = "حدث خطأ أثناء الاتصال بالشبكة";
    }
    Fluttertoast.showToast(
      context,
      msg: errmsg != null ? errmsg : 'hi',
    );

    setState(() {
      driversDetailes = 400;
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
      'passengers': numCont != null ? numCont : 1,
    };
    rideReq.set(rideMap);
    ridestreams = rideReq.onValue.listen((event) {
      if (event.snapshot.value == null) {
        return;
      }
      if (event.snapshot.value['status'] != null) {
        statusRide = event.snapshot.value['status'].toString();
      }
      if (event.snapshot.value['driver_location'] != null) {
        double driverLat = double.parse(
            event.snapshot.value['driver_location']['latitude'].toString());
        double driverLong = double.parse(
            event.snapshot.value['driver_location']['longitude'].toString());
        LatLng driverCurrLoc = LatLng(driverLat, driverLong);
        driverPhone = '';
        if (event.snapshot.value['driver_phone'] != null) {
          driverPhone = event.snapshot.value['driver_phone'].toString();
        }
        if (statusRide == 'accepted') {
          updateDriTime(driverCurrLoc); //bbbbbbbaaaaaaaccckkkk
        } else if (statusRide == 'onTrip') {
          updateTripTime(driverCurrLoc);
        } else if (statusRide == 'arrived') {
          setState(() {
            arrivalStatus = 'وصل الباص';
          });
        }
      }

      if (statusRide == 'accepted') {
        displayDriverDetails();
        Geofire.stopListener();
        //DELETE MARKERS : لازم تشوفي مشكلة هاد و ترتبيها
      }
      if (statusRide == 'ended') {
        if (event.snapshot.value['driver_phone'] != null) {
          driverPhone = event.snapshot.value['driver_phone'].toString();
        }
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) =>
                Rating(driverPhone: driverPhone));

        rideReq.onDisconnect();
        rideReq = null;
        ridestreams.cancel();
        ridestreams = null;
        //reset the app/ احزفي كل الاشياء و رجعيه كانو جديد

        driversDetailes = 0;
        statusRide = '';
        arrivalStatus = ' الباص على الطريق ';
      }
    });
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
  void driversMarkers() {
    setState(() {
      //markers.length > 1 ? markers.removeRange(1, markers.length) : null;//removeAll()
      circles.clear();
      polylines.clear();
      markers.clear();
    });
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
          //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
          case Geofire.onKeyEntered:
            NearDrivers nDriver = NearDrivers();
            int dNum; //
            nDriver.key = map['key'];
            nDriver.lat = map['latitude'];
            nDriver.long = map['longitude'];

            /* FireDrivers.nDrivers.add(nDriver);
            if (nearLoaded) {
              driversMarkers();
            } */
            DatabaseReference nDrivers = FirebaseDatabase.instance
                .reference()
                .child('Drivers/${nDriver.key}');
            nDrivers.once().then((DataSnapshot snapshot) {
              if (snapshot.value != null) {
                dNum = snapshot.value['passengers'];
                double wLat = double.parse(
                    snapshot.value['whereTo']['latitude'].toString());
                double wLng = double.parse(
                    snapshot.value['whereTo']['longitude'].toString());
                Funcs.checkPoint(wLat, wLng, nDriver.lat, nDriver.long,
                    _destLatitude, _destLongitude);
                if (dNum >= numCont && chP == true) {
                  FireDrivers.nDrivers.add(nDriver);
                  if (nearLoaded) {
                    setState(() {
                      driversMarkers();
                    });
                  }
                }
              }
            });
            break;
          //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
          case Geofire.onKeyExited:
            FireDrivers.removeDriver(map['key']);
            setState(() {
              driversMarkers();
            });
            break;
          //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
          case Geofire.onKeyMoved:
            // Update your key's location
            NearDrivers nDriver = NearDrivers();
            nDriver.key = map['key'];
            nDriver.lat = map['latitude'];
            nDriver.long = map['longitude'];
            FireDrivers.updateDriver(nDriver);
            setState(() {
              driversMarkers();
            });
            break;
          //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
          case Geofire.onGeoQueryReady:
            // All Intial Data is loaded
            setState(() {
              nearLoaded = true;
              driversMarkers();
            });
            //  print(map['result']);

            break;
          //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
        }
      }
    });
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Widget getWidget() {
    switch (isExtended) {
      case 0:
        {
          return Icon(Icons.directions_bus);
        }
        break;

      case 1:
        {
          return Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.check),
              ),
              Text(" طلب توصيلة"),
            ],
          );
        }
        break;
      case 2:
        {
          return Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.cancel),
              ),
              Text("إلغاء الأمر"),
            ],
          );
        }
        break;

      default:
        {
          Icon(Icons.directions_bus);
        }
        break;
    }
  }

  int isExtended = 0;

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void logFire() async {
    currUser = await FirebaseAuth.instance.currentUser;
    NotificChat pushNot = NotificChat();
    pushNot.initialize(context);
  }

  int msgsCount = 0;
  int busflaf = 0;
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  @override
  Widget build(BuildContext context) {
    logFire();
    final Size size = MediaQuery.of(context).size;
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
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

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    pic();
    putvalues();
    numUnredMsgs();
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
                                    return favlist(fpname, ltt, lgg, context);
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
                  height: 60,
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
                  height: 20,
                ),
                Align(
                  alignment: Alignment.center,
                  child: FloatingActionButton.extended(
                      backgroundColor: Colors.amber,
                      isExtended: true,
                      onPressed: () {
                        _scaffoldkey.currentState.openDrawer();
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
                          markers.clear();
                          circles.clear();
                          polylines.clear();
                          homeispress = false;
                          msgispress = false;
                          notispress = false;
                          proispress = false;
                          _destName = "";
                          _startPointController.text = "";
                          FirebaseAuth.instance.signOut();
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
              GoogleMap(
                mapType: MapType.normal,
                padding: EdgeInsets.only(bottom: mapBottomPadding),
                initialCameraPosition: _kGooglePlex,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                tiltGesturesEnabled: true,
                compassEnabled: true,
                zoomControlsEnabled: false,
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
                      padding: const EdgeInsets.only(bottom: 90, right: 10),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton.extended(
                          backgroundColor:
                              isExtended < 2 ? apBcolor : Colors.black,
                          isExtended: isExtended > 0 ? true : false,
                          onPressed: () {
                            if (isExtended == 1) {
                              createRequest();
                              startGeoListen();
                              //Future.delayed(const Duration(seconds: 2), () {});
                              availableDrivers = FireDrivers.nDrivers;
                              searchNearestDriver();
                            } else if (isExtended == 2) {
                              cancelReq();
                            }
                            setState(
                              () {
                                if (isExtended < 2) {
                                  isExtended++;
                                  isExtended == 1 ? stat = 'requesting' : null;
                                } else {
                                  isExtended = 0;
                                }
                              },
                            );
                          },
                          label: getWidget(),
                        ),
                      ),
                    )
                  : Container(
                      height: 0.1,
                      width: 0.1,
                    ),
              //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
              //Display driver's info
              //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Container(
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
                  height: driversDetailes,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              arrivalStatus,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        Divider(),
                        Text(
                          theDriver.busType != null
                              ? theDriver.busType
                              : ' نوع الباص',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          theDriver.name != null
                              ? theDriver.name
                              : 'اسم السائق',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'Lemonada'),
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        Divider(),
                        SizedBox(
                          height: 22,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 55,
                                  width: 55,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(26)),
                                    border: Border.all(
                                        width: 2, color: Colors.grey),
                                  ),
                                  child: Icon(Icons.cancel),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('إلغاء طلب الرحلة'),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    drivPhone = theDriver.phone;
                                    getInfoForChat(drivPhone);
                                    roomId = globalFunctions()
                                        .creatChatRoomInfo(
                                            thisUser.email, drivEmail);
                                    //print(roomId);
                                    Navigator.of(context).push(
                                      CubePageRoute(
                                        enterPage: PassChatDetailes(
                                          username: drivName,
                                          imageURL: drivImgPath,
                                          useremail: drivEmail,
                                          roomID: roomId,
                                          sendername: thisUser.name,
                                        ),
                                        exitPage: PassMap(),
                                        duration:
                                            const Duration(milliseconds: 1200),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 55,
                                    width: 55,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(26)),
                                      border: Border.all(
                                          width: 2, color: Colors.grey),
                                    ),
                                    child: Icon(Icons.message),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('تواصل مع السائق'),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    showBottomSheet(
                                        context: context,
                                        backgroundColor: Colors.transparent,
                                        builder: (BuildContext context) {
                                          return DriverInfoBottom(); // returns your BottomSheet widget
                                        });
                                  },
                                  child: Container(
                                    height: 55,
                                    width: 55,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(26)),
                                      border: Border.all(
                                          width: 2, color: Colors.grey),
                                    ),
                                    child: Icon(Icons.list),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(' معلومات السائق'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
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
                                color:
                                    (msgispress) ? Color(0xFF1ccdaa) : apcolor,
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
                                    color: (msgispress) ? mypink : Colors.white,
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
                                          exitPage: PassMap(),
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
                                color:
                                    (notispress) ? Color(0xFF1ccdaa) : apcolor,
                                shape: CircleBorder(),
                                clipBehavior: Clip.hardEdge,
                                child: IconButton(
                                    icon: Icon(Icons.notifications),
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
                                    icon: Icon(Icons.person),
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
  void searchNearestDriver() {
    if (availableDrivers.length == 0) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => NoDriverDialog(),
      );
      cancelReq();
    } else {
      setState(() {
        //markers.length > 1 ? markers.removeRange(1, markers.length) : null;
        markers.clear();
        polylines.clear();
      });
      var driver = availableDrivers[0]; //length-1
      //print(driver.key);
      availableDrivers.removeAt(0);
      notifyDriver(driver);
    }
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void notifyDriver(NearDrivers driver) {
    driverRef.child(driver.key).child('newTrip').set(rideReq.key);
    driverRef.child(driver.key).child('token').once().then((DataSnapshot snap) {
      if (snap.value != null) {
        String token = snap.value.toString();
        sendNotifToDriver(token, rideReq.key, context);
      } else {
        return;
      }
      const sec = Duration(seconds: 1);
      var timer = Timer.periodic(sec, (timer) {
        if (stat != 'requesting') {
          driverRef.child(driver.key).child('newTrip').set('cancelled');
          driverRef.child(driver.key).child('newTrip').onDisconnect();
          dReqTimeout = 10;
          timer.cancel();
        }
        dReqTimeout = dReqTimeout - 1;
        driverRef.child(driver.key).child('newTrip').onValue.listen((event) {
          if (event.snapshot.value.toString() == 'accepted') {
            //     driverRef.child(driver.key).child('newTrip').set('waiting');
            driverRef.child(driver.key).child('newTrip').onDisconnect();
            dReqTimeout = 10;
            timer.cancel();
          }
        });
        if (dReqTimeout == 0) {
          driverRef.child(driver.key).child('newTrip').set('timeout');
          driverRef.child(driver.key).child('newTrip').onDisconnect();
          dReqTimeout = 10;
          timer.cancel();
          searchNearestDriver();
        }
      });
    });
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void sendNotifToDriver(String token, String rideReqId, context) async {
    var destin =
        Provider.of<AppData>(context, listen: false).destinationAddress;
    Map<String, String> headerMap = {
      'Content-Type': 'application/json',
      'Authorization': serverToken,
    };
    Map notificationMap = {
      'body': '${destin.placeName} إلى ',
      'title': 'طلب توصيلة جديد'
    };
    Map dataMap = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'riderequest_id': rideReqId,
    };
    Map sendNotificationMao = {
      "notification": notificationMap,
      "data": dataMap,
      'priority': 'high',
      'to': token,
    };
    var respon = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: headerMap,
      body: jsonEncode(sendNotificationMao),
    );
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
