import 'dart:async';
import 'dart:convert';
import 'package:OtoBus/configMaps.dart';
import 'package:OtoBus/screens/noDriversDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../main.dart';
import 'package:OtoBus/dataProvider/address.dart';
import 'package:provider/provider.dart';
import 'package:OtoBus/dataProvider/appData.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong/latlong.dart" as latLng;
import 'PassengerPage.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:OtoBus/dataProvider/nearDriver.dart';
import 'package:OtoBus/dataProvider/fireDrivers.dart';

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
const keyPoStack = 'b302ddec67beb4a453f6a3b36393cdf0';
const keyOpS = 'e29278e269d34185897708d17cb83bc4';
const keyGeo = 'AIzaSyDpIlaxbh4WTp4_Ecnz4lupswaRqyNcTv4';

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
final List<latLng.LatLng> points = [
  /* 
      currLatLng,
      latLng.LatLng(destinationAdd.lat, destinationAdd.long)
     */
];
final List<Polyline> polyLines = [];
final List<Marker> markers = [];
var data;
latLng.LatLng currLatLng;
DatabaseReference rideReq;
DatabaseReference driverRef =
    FirebaseDatabase.instance.reference().child('Drivers');
bool nearLoaded = false;
double driversDetailes = 0;
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

class PassengerMap extends StatefulWidget {
  @override
  _PassengerMapState createState() => _PassengerMapState();
}
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

class _PassengerMapState extends State<PassengerMap> {
  double mapBottomPadding = 0;

  MapController _mapct = MapController();

  var geoLocator = Geolocator();
  Position currentPosition;
  String stat = 'normal';
  StreamSubscription<Event> ridestreams;
  bool reqPosDet = false;
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void putvalues() async {
    thisUser.email = await FlutterSession().get('email');
    thisUser.name = await FlutterSession().get('name');
    thisUser.phone = await FlutterSession().get('phone').toString();
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void displayDriverDetails() {
    setState(() {
      driversDetailes = 400;
    });
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void createRequest() {
    rideReq = FirebaseDatabase.instance.reference().child('rideRequest').push();

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
    };
    rideReq.set(rideMap);
    ridestreams = rideReq.onValue.listen((event) {
      if (event.snapshot.value == null) {
        return;
      }
      if (event.snapshot.value['driver_location'] != null) {
        double driverLat = double.parse(
            event.snapshot.value['driver_location']['latitude'].toString());
        double driverLong = double.parse(
            event.snapshot.value['driver_location']['longitude'].toString());
        latLng.LatLng driverCurrLoc = latLng.LatLng(driverLat, driverLong);
        if (statusRide == 'accepted') {
          updateDriTime(driverCurrLoc);
        } else if (statusRide == 'onTrip') {
          updateTripTime(driverCurrLoc);
        } else if (statusRide == 'arrived') {
          setState(() {
            arrivalStatus = 'وصل الباص';
          });
        }
      }
      if (event.snapshot.value['status'] != null) {
        statusRide = event.snapshot.value['status'].toString();
      }
      if (statusRide == 'accepted') {
        displayDriverDetails();
        Geofire.stopListener();
        //DELETE MARKERS : لازم تشوفي مشكلة هاد و ترتبيها
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
        arrivalStatus = ' سيصل الباص بحدود ' + time /* + " دقائق " */;
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
    rideReq.remove();
    setState(() {
      stat = 'normal';
      markers.length > 1 ? markers.removeRange(1, markers.length) : null;
      points.clear();
      polyLines.clear();
    });
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
        //   pickUp.placeName = jsonDecode(data)['data'][0]['county'];
        pickUp.lat = lat;
        pickUp.long = long;

        src_loc.text = pickUp.placeName;
        setState(() {
          currLatLng = latLng.LatLng(lat, long);
        });

        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: currLatLng,
            builder: (ctx) => Container(
                child: Icon(
              Icons.location_on,
              color: mypink,
              size: 40,
            )),
          ),
        );

        Provider.of<AppData>(context, listen: false).updatePickAddress(pickUp);
      });
    } else {
      print(response.statusCode);
    }
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void setupPositionLocator() async {
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    getData(currentPosition.latitude, currentPosition.longitude);
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void startGeoListen() {
    Geofire.initialize('availableDrivers');
    Geofire.queryAtLocation(currLatLng.latitude, currLatLng.longitude, 5)
        .listen((map) {
      print(map);
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
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  void driversMarkers() {
    setState(() {
      markers.length > 1 ? markers.removeRange(1, markers.length) : null;
      points.clear();
      polyLines.clear();
    });
    for (NearDrivers driver in FireDrivers.nDrivers) {
      setState(() {
        latLng.LatLng driverPos = latLng.LatLng(driver.lat, driver.long);
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: driverPos,
            builder: (ctx) => Container(
                child: Icon(
              Icons.directions_bus,
              color: Colors.black,
              size: 40,
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
  int isExtended = 0;

  Widget build(BuildContext context) {
    /*   if(currLatLng.latitude!=null){
    _mapct.move(currLatLng,10);} */
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
      markers.length > 1
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
                  '  نوع الباص',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  ' اسم السواق ',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontFamily: 'Lemonada'),
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
                            borderRadius: BorderRadius.all(Radius.circular(26)),
                            border: Border.all(width: 2, color: Colors.grey),
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
                        Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(26)),
                            border: Border.all(width: 2, color: Colors.grey),
                          ),
                          child: Icon(Icons.message),
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
                        Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(26)),
                            border: Border.all(width: 2, color: Colors.grey),
                          ),
                          child: Icon(Icons.list),
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
    ]);
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void searchNearestDriver() {
    if (availableDrivers.length == 0) {
      setState(() {
        isExtended = -1;
      });
      cancelReq();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => NoDriverDialog(),
      );
    } else {
      setState(() {
        markers.length > 1 ? markers.removeRange(1, markers.length) : null;
        points.clear();
        polyLines.clear();
      });
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

  @override
  void initState() {
    super.initState();
    setupPositionLocator();
  }
}
