import 'dart:async';
import 'dart:convert';
import 'dart:io' as Io;
import 'dart:io';
import 'package:OtoBus/chat/NotificChat.dart';
import 'package:OtoBus/chat/PassChatDetailes.dart';
import 'package:OtoBus/chat/globalFunctions.dart';
import 'package:OtoBus/screens/LineString.dart';
import 'package:OtoBus/screens/NetworkHelper.dart';
import 'package:cube_transition/cube_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:OtoBus/configMaps.dart';
import 'package:OtoBus/dataProvider/currDriverInfo.dart';
import 'package:OtoBus/dataProvider/fUNCS.dart';
import 'package:OtoBus/screens/CurrUserInfo.dart';
import 'package:OtoBus/screens/driverInfoBottomSheet.dart';
import 'package:OtoBus/screens/noDriversDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import 'package:OtoBus/dataProvider/address.dart';
import 'package:provider/provider.dart';
import 'package:OtoBus/dataProvider/appData.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong/latlong.dart" as latLng;
import 'PassengerPage.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:OtoBus/dataProvider/nearDriver.dart';
import 'package:OtoBus/dataProvider/fireDrivers.dart';
import 'package:OtoBus/screens/rating.dart';

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
const keyPoStack = 'b302ddec67beb4a453f6a3b36393cdf0';
const keyOpS = 'e29278e269d34185897708d17cb83bc4';
const keyGeo = 'AIzaSyDpIlaxbh4WTp4_Ecnz4lupswaRqyNcTv4';

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
final List<latLng.LatLng> points = [
  /*  currLatLng,
      latLng.LatLng(destinationAdd.lat, destinationAdd.long)
     */
];
final List<Polyline> polyLines = [];
final List<Marker> markers = [];
Map<String, Marker> marks = {};
var data;
latLng.LatLng currLatLng;
DatabaseReference rideReq;
DatabaseReference driverRef =
    FirebaseDatabase.instance.reference().child('Drivers');
bool nearLoaded = false;
String errmsg;
String driverPhone;
File prof;
String profname;
var profile;
String base64prof = "";
var fileImg;
Position myPos;
String roomId = "";
String drivEmail = "";
String drivName = "";
String drivImgPath = "lib/Images/Defultprof.jpg";
String drivPhone = "";
String path;
String oneNamePlace;
int isExtended;
bool btn;
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

class PassengerMap extends StatefulWidget {
  @override
  PassengerMapState createState() => PassengerMapState();
}
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

class PassengerMapState extends State<PassengerMap> {
  double mapBottomPadding = 0;

  MapController _mapct = MapController();

  var geoLocator = Geolocator();
  Position currentPosition;
  String stat = 'normal';
  StreamSubscription<Event> ridestreams;
  bool reqPosDet = false;
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void putvalues() async {
    var x;
    thisUser.email = await FlutterSession().get('passemail');
    thisUser.name = await FlutterSession().get('name');
    x = await FlutterSession().get('phone');
    thisUser.phone = x.toString();
    setState(() {
      namecon.text = thisUser.name;
      emailcon.text = thisUser.email;
      phonecon.text = thisUser.phone;
    });
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Future upload(File img, String imgname) async {
    profile = Io.File(img.path).readAsBytesSync();
    base64prof = base64Encode(profile);
    String url =
        "http://192.168.1.8/otobus/phpfiles/updatepass.php"; //10.0.0.8//192.168.1.106:8089
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
        "http://192.168.1.8/otobus/phpfiles/getdataforchat.php"; //10.0.0.8////192.168.1.8
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

  getRatings() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    String apiurl =
        "http://192.168.1.8/otobus/phpfiles/avgRatings.php"; //10.0.0.8//
    var response = await http.post(apiurl, body: {
      'phone': theDriver.phone, //get the username text
    });

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      if (jsondata["error"] == 1) {
        errormsg = jsondata["message"];
        Fluttertoast.showToast(
          context,
          msg: errormsg,
        );
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
          Fluttertoast.showToast(
            context,
            msg: errormsg,
          );
        }
      }
    } else {
      errormsg = "حدث خطأ أثناء الاتصال بالشبكة";
      Fluttertoast.showToast(
        context,
        msg: errormsg,
      );
    }
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Future<void> displayDriverDetails() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    String apiurl =
        "http://192.168.1.8/otobus/phpfiles/getDriverInfo.php"; //10.0.0.8//
    var response = await http.post(apiurl, body: {
      'phone': driverPhone,
    });
    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      if (jsondata["error"] == 1) {
        errmsg = jsondata["message"];
        Fluttertoast.showToast(
          context,
          msg: errmsg != null ? errmsg : 'hi',
        );
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
      Fluttertoast.showToast(
        context,
        msg: errmsg != null ? errmsg : 'hi',
      );
    }

    setState(() {
      driversDetailes = 280;
    });
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  void updateRideLocation() {
    latLng.LatLng oldP = latLng.LatLng(0, 0);
    pridePosStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    ).listen((Position position) {
      currLatLng = latLng.LatLng(position.latitude, position.longitude);
      myPos = position;
      currentPosition = position;
      latLng.LatLng pos = latLng.LatLng(position.latitude, position.longitude);
      setState(() {
        marks['current'] = Marker(
          width: 80.0,
          height: 80.0,
          point: pos,
          builder: (ctx) => Container(
              child: Icon(
            Icons.location_on,
            color: mypink,
            size: 40,
          )),
        );
        if (markers.length >= 1) {
          markers.removeAt(0);
        }

        markers.insert(0, marks['current']);
      });

      oldP = pos;
      Map locationMap = {
        'latitude': myPos.latitude,
        'longitude': myPos.longitude,
      };
      if (rideReq != null) {
        rideReq.child('location').set(locationMap);
      }
    });
  }

  updateDriverLocation(latLng.LatLng loc) async {
    marks['driver'] = Marker(
      width: 50.0,
      height: 50.0,
      point: loc,
      builder: (ctx) => Container(
          child: Icon(
        Icons.directions_bus,
        color: apcolor,
        size: 30,
      )),
    );
    setState(() {
      if (markers.length > 3) {
        markers.removeRange(3, markers.length);
      }
      markers.insert(3, marks['driver']);
    });

    points.isNotEmpty ? points.clear() : null;
    NetworkHelper network = NetworkHelper(
      startLat: currLatLng.latitude,
      startLng: currLatLng.longitude,
      endLat: loc.latitude,
      endLng: loc.longitude,
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

      Polyline polyline = Polyline(
        points: points,
        strokeWidth: 3.0,
        color: myblue,
      );
      points.isNotEmpty ? polyLines.insert(1, polyline) : null;
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  driverPoly(latLng.LatLng loc, latLng.LatLng dest) async {
    List<latLng.LatLng> pts = [];
    marks['driverDes'] = Marker(
      width: 50.0,
      height: 50.0,
      point: dest,
      builder: (ctx) => Container(
          child: Icon(
        Icons.location_pin,
        color: myPink,
        size: 30,
      )),
    );
    marks['driverloc'] = Marker(
      width: 50.0,
      height: 50.0,
      point: loc,
      builder: (ctx) => Container(
          child: Icon(
        Icons.location_pin,
        color: myPink,
        size: 30,
      )),
    );

    markers.insert(1, marks['driverDes']);
    markers.insert(2, marks['driverloc']);

    NetworkHelper network = NetworkHelper(
      startLat: loc.latitude,
      startLng: loc.longitude,
      endLat: dest.latitude,
      endLng: dest.longitude,
    );

    try {
      // getData() returns a json Decoded data
      data = await network.getData();

      // We can reach to our desired JSON data manually as following
      LineString ls =
          LineString(data['features'][0]['geometry']['coordinates']);

      for (int i = 0; i < ls.lineString.length; i++) {
        pts.add(latLng.LatLng(ls.lineString[i][1], ls.lineString[i][0]));
      }

      Polyline polyline = Polyline(
        points: pts,
        strokeWidth: 5.0,
        color: Colors.black,
      );
      polyLines.insert(0, polyline);
      setState(() {});
    } catch (e) {
      print(e);
    }
  }
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  void createRequest() {
    rideReq = FirebaseDatabase.instance.reference().child('rideRequest').push();
    numCont != null ? null : numCont = 1;
    var pickUp = Provider.of<AppData>(context, listen: false).pickUpAdd;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

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
        latLng.LatLng driverCurrLoc = latLng.LatLng(driverLat, driverLong);
        driverPhone = '';
        latLng.LatLng driverLoc;
        latLng.LatLng driverDest;
        if (event.snapshot.value['driver_phone'] != null) {
          driverPhone = event.snapshot.value['driver_phone'].toString();
        }

        if (event.snapshot.value['driver_loc'] != null) {
          double driverLat = double.parse(
              event.snapshot.value['driver_loc']['latitude'].toString());
          double driverLong = double.parse(
              event.snapshot.value['driver_loc']['longitude'].toString());
          driverLoc = latLng.LatLng(driverLat, driverLong);
        }
        if (event.snapshot.value['driver_dest'] != null) {
          double driverLat = double.parse(
              event.snapshot.value['driver_dest']['latitude'].toString());
          double driverLong = double.parse(
              event.snapshot.value['driver_dest']['longitude'].toString());
          driverDest = latLng.LatLng(driverLat, driverLong);
        }
        if (statusRide == 'accepted') {
          updateDriTime(driverCurrLoc);
          updateRideLocation();
          driverPoly(driverLoc, driverDest);
          updateDriverLocation(driverCurrLoc);
        } else if (statusRide == 'onTrip') {
          updateTripTime(driverCurrLoc);

          setState(() {
            polyLines.removeAt(1);
            markers.removeAt(3);
          });
          updateRideLocation();
          driverPoly(driverLoc, driverDest);

          //resetApp: polylines and such
        } else if (statusRide == 'arrived') {
          setState(() {
            arrivalStatus = 'وصل الباص';
          });
        }
      }

      if (statusRide == 'accepted') {
        displayDriverDetails();
        Geofire.stopListener();
        isExtended = 0;
        //DELETE MARKS : لازم تشوفي مشكلة هاد و ترتبيها
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
        rideReq.remove();
        rideReq = null;
        ridestreams.cancel();
        ridestreams = null;
        pridePosStream.cancel();
        pridePosStream = null;
        setState(() {
          isExtended = 0;
          btn = false;
          stat = 'normal';
          markers.clear();
          points.clear();
          polyLines.clear();
          marks['current'] = Marker(
            width: 80.0,
            height: 80.0,
            point: currLatLng,
            builder: (ctx) => Container(
                child: Icon(
              Icons.location_on,
              color: mypink,
              size: 40,
            )),
          );

          markers.insert(0, marks['current']);
          driversDetailes = 0;
          statusRide = '';
          arrivalStatus = ' الباص على الطريق ';
        });
        //reset the app/ احزفي كل الاشياء و رجعيه كانو جديد

      }
    });
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void updateDriTime(latLng.LatLng driverCurrLoc) async {
    if (reqPosDet == false) {
      reqPosDet = true;
      var pos = latLng.LatLng(currLatLng.latitude, currLatLng.longitude);
      String time = await calcTime(pos, driverCurrLoc);
      setState(() {
        if (arrivalStatus == ' الباص على الطريق ') {
          markers.clear();
          marks['current'] = Marker(
            width: 80.0,
            height: 80.0,
            point: pos,
            builder: (ctx) => Container(
                child: Icon(
              Icons.location_on,
              color: mypink,
              size: 40,
            )),
          );
          markers.insert(0, marks['current']);
        }
        arrivalStatus = ' الرجاء التوجه إلى مسار الباص, الباص يبعد ' +
            time /* + " دقائق " */;
      });
      reqPosDet = false;
    }
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void updateTripTime(latLng.LatLng driverCurrLoc) async {
    if (reqPosDet == false) {
      reqPosDet = true;
      var posAdd =
          Provider.of<AppData>(context, listen: false).destinationAddress;
      var pos = latLng.LatLng(posAdd.lat, posAdd.long);
      String time = await calcTime(pos, driverCurrLoc);
      setState(() {
        arrivalStatus = ' باقٍ على الوصول للوجهة ' + time /* + 'دقائق' */;
      });
      reqPosDet = false;
    }
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Future<String> calcTime(latLng.LatLng source, latLng.LatLng dest) async {
    Response response = await get(
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
  void cancelReq() {
    isExtended = 0;
    btn = false;
    rideReq.remove();
    setState(() {
      stat = 'normal';
      markers.clear();
      points.clear();
      polyLines.clear();
      marks['current'] = Marker(
        width: 80.0,
        height: 80.0,
        point: currLatLng,
        builder: (ctx) => Container(
            child: Icon(
          Icons.location_on,
          color: mypink,
          size: 40,
        )),
      );
      markers.insert(0, marks['current']);
    });
  }

//^^^^^^^^^/^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  void getData(double lat, double long) async {
    Response response = await get(
        'http://api.positionstack.com/v1/reverse?access_key=$keyPoStack&query=$lat,$long');

    if (response.statusCode == 200) {
      String data = response.body;
      setState(() {
        Adress pickUp = new Adress();
        pickUp.placeName = jsonDecode(data)['data'][0]['label'];
        //   pickUp.placeName = jsonDecode(data)['data'][0]['county'];
        pickUp.lat = lat;
        pickUp.long = long;
        Provider.of<AppData>(context, listen: false).updatePickAddress(pickUp);

        src_loc.text = pickUp.placeName;
        currLatLng = latLng.LatLng(lat, long);
      });
    } else {
      print(response.statusCode);
    }
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void setupPositionLocator() async {
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    setState(() {
      currLatLng =
          latLng.LatLng(currentPosition.latitude, currentPosition.longitude);
      Adress pickUp = new Adress();
      pickUp.lat = currentPosition.latitude;
      pickUp.long = currentPosition.longitude;
      Provider.of<AppData>(context, listen: false).updatePickAddress(pickUp);
    });

    marks['current'] = Marker(
      width: 80.0,
      height: 80.0,
      point: currLatLng,
      builder: (ctx) => Container(
          child: Icon(
        Icons.location_on,
        color: mypink,
        size: 40,
      )),
    );

    markers.insert(0, marks['current']);

    getData(currentPosition.latitude, currentPosition.longitude);
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void startGeoListen() async {
    Geofire.initialize('availableDrivers');
    await Geofire.queryAtLocation(currLatLng.latitude, currLatLng.longitude, 5)
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];
        switch (callBack) {
          case Geofire.onKeyEntered:
            NearDrivers nDriver = NearDrivers();
            int dNum;
            nDriver.key = map['key'];
            nDriver.lat = map['latitude'];
            nDriver.long = map['longitude'];
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
                    destinationAdd.lat, destinationAdd.long);
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

          case Geofire.onKeyExited:
            FireDrivers.removeDriver(map['key']);
            setState(() {
              driversMarkers();
            });

            break;

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

          case Geofire.onGeoQueryReady:
            // All Intial Data is loaded
            setState(() {
              nearLoaded = true;
              driversMarkers();
            });

            //  print(map['result']);

            break;
        }
      }
    });
    Future.delayed(const Duration(seconds: 2), () {});
    availableDrivers = FireDrivers.nDrivers;
    searchNearestDriver();
  }
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  void driversMarkers() {
    for (NearDrivers driver in FireDrivers.nDrivers) {
      setState(() {
        latLng.LatLng driverPos = latLng.LatLng(driver.lat, driver.long);
        markers.add(
          Marker(
            width: 40.0,
            height: 40.0,
            point: driverPos,
            builder: (ctx) => Container(
                child: Icon(
              Icons.directions_bus,
              color: Colors.black,
              size: 20,
            )),
          ),
        );
      });
    }
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

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  void logFire() async {
    currUser = await FirebaseAuth.instance.currentUser;
    NotificChat pushNot = NotificChat();
    pushNot.initialize(context);
  }
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  Widget build(BuildContext context) {
    /*   if(currLatLng.latitude!=null){
    _mapct.move(currLatLng,10);} */
    logFire();
    putvalues();
    final Size size = MediaQuery.of(context).size;
    putvalues();
    return Stack(children: [
      FlutterMap(
        options: MapOptions(
          center: latLng.LatLng(32.0442, 35.2242),
          zoom: 10.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          PolylineLayerOptions(
            polylines: polyLines,
          ),
          MarkerLayerOptions(
            markers: markers,
          ),
        ],
      ),
      btn
          ? Padding(
              padding: const EdgeInsets.only(bottom: 90, right: 10),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton.extended(
                  backgroundColor: isExtended < 2 ? apBcolor : Colors.black,
                  isExtended: isExtended > 0 ? true : false,
                  onPressed: () {
                    if (isExtended == 1) {
                      createRequest();
                      startGeoListen();
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
                  topRight: Radius.circular(16), topLeft: Radius.circular(16)),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 6,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        arrivalStatus,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
                Divider(),
                Text(
                  theDriver.busType != null ? theDriver.busType : ' نوع الباص',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
                Text(
                  theDriver.name != null ? theDriver.name : 'اسم السائق',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontFamily: 'Lemonada'),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(26)),
                              border: Border.all(width: 2, color: Colors.grey),
                            ),
                            child: Icon(
                              Icons.cancel,
                              size: 23,
                            ),
                          ),
                          onTap: () {
                            //reset the app/ احزفي كل الاشياء و رجعيه كانو جديد
                            statusRide = '';
                            arrivalStatus = ' الباص على الطريق ';
                            setState(() {
                              stat = 'normal';
                              driversDetailes = 0;
                              isExtended = 0;
                              btn = false;
                              markers.clear();
                              points.clear();
                              polyLines.clear();
                              markers.add(marks['current']);
                            });
                            rideReq.child('status').set('cancelled');
                            Future.delayed(const Duration(seconds: 2), () {});
                            rideReq.onDisconnect();
                            rideReq.remove();
                            rideReq = null;
                            ridestreams.cancel();
                            ridestreams = null;
                            pridePosStream.cancel();
                            pridePosStream = null;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'إلغاء طلب الرحلة',
                          style: TextStyle(fontSize: 12),
                        ),
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
                                  .creatChatRoomInfo(thisUser.email, drivEmail);
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
                                  exitPage: PassengerMap(),
                                  duration: const Duration(milliseconds: 1200),
                                ),
                              );
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(26)),
                                border:
                                    Border.all(width: 2, color: Colors.grey),
                              ),
                              child: Icon(
                                Icons.message,
                                size: 23,
                              ),
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'تواصل مع السائق',
                          style: TextStyle(fontSize: 12),
                        ),
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
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(26)),
                              border: Border.all(width: 2, color: Colors.grey),
                            ),
                            child: Icon(
                              Icons.list,
                              size: 23,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          ' معلومات السائق',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void searchNearestDriver() {
    print('search');

    if (availableDrivers.length == 0) {
      isExtended = 0;
      cancelReq();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => NoDriverDialog(),
      );
    } else {
      var driver = availableDrivers[0];

      print(driver.key);
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
      // dReqTimeout = 0; ///////
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
          print('timeout');

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

  @override
  void initState() {
    isExtended = 0;
    btn = false;
    homeispress = true;
    msgispress = false;
    notispress = false;
    proispress = false;
    super.initState();
    setupPositionLocator();
  }
}
