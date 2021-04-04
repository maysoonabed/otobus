import 'dart:async';
import 'dart:convert';
import 'package:OtoBus/configMaps.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import '../main.dart';
import 'package:OtoBus/dataProvider/address.dart';
import 'package:provider/provider.dart';
import 'package:OtoBus/dataProvider/appData.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong/latlong.dart" as latLng;
import 'PassengerPage.dart';

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
const keyPoStack = 'b302ddec67beb4a453f6a3b36393cdf0';
const keyOpS = 'e29278e269d34185897708d17cb83bc4';
const keyGeo = 'AIzaSyDpIlaxbh4WTp4_Ecnz4lupswaRqyNcTv4';
const tokenkey =
    'pk.eyJ1IjoibW15eHQiLCJhIjoiY2ttbDMwZzJuMTcxdDJwazVoYjFmN29vZiJ9.zXZhziLKRg0-JEtO4KPG1w';

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
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void putvalues() async {
    thisUser.email = await FlutterSession().get('email');
    thisUser.name = await FlutterSession().get('name');
    thisUser.phone = await FlutterSession().get('phone');
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
    };
    rideReq.set(rideMap);
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void cancelReq() {
    rideReq.remove();
    setState(() {
      markers.removeAt(1);
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
              Text("اظهار الباصات"),
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
                    } else if (isExtended == 2) {
                      cancelReq();
                    }
                    setState(
                      () {
                        if (isExtended < 2) {
                          isExtended++;
                        } else
                          isExtended = 0;
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
    ]);
  }
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  @override
  void initState() {
    super.initState();
    setupPositionLocator();
  }
}
