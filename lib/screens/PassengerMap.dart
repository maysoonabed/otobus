import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
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
  latLng.LatLng currLatLng;
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  void getData(double lat, double long) async {
    Response response = await get(
        'http://api.positionstack.com/v1/reverse?access_key=$keyPoStack&query=$lat,$long');

    if (response.statusCode == 200) {
      String data = response.body;
      setState(() {
        Adress pickUp = new Adress();
        pickUp.placeLabel = jsonDecode(data)['data'][0]['label'];
        pickUp.placeName = jsonDecode(data)['data'][0]['county'];
        pickUp.long = long;
        pickUp.lat = lat;
        src_loc.text = pickUp.placeLabel;
        setState(() {
          currLatLng = latLng.LatLng(lat, long);
        });

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
  Widget build(BuildContext context) {
    /*   if(currLatLng.latitude!=null){
    _mapct.move(currLatLng,10);} */
    List<latLng.LatLng> points = [
      currLatLng,
      latLng.LatLng(destinationAdd.lat, destinationAdd.long)
    ];

    final Size size = MediaQuery.of(context).size;
    return FlutterMap(
      options: MapOptions(
        center: currLatLng,
        zoom: 10.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate:
              "https://api.mapbox.com/styles/v1/mmyxt/ckmwm6oay1mpc17pgcsw3k0xc/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibW15eHQiLCJhIjoiY2ttbDMwZzJuMTcxdDJwazVoYjFmN29vZiJ9.zXZhziLKRg0-JEtO4KPG1w",
          additionalOptions: {
            'accessToken':
                'pk.eyJ1IjoibW15eHQiLCJhIjoiY2ttbDMwZzJuMTcxdDJwazVoYjFmN29vZiJ9.zXZhziLKRg0-JEtO4KPG1w',
            'id': 'mapbox.mapbox-streets-v8',
          },
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: currLatLng,
              builder: (ctx) => Container(
                  child: Icon(
                Icons.location_on,
                color: mypink,
                size: 45,
              )),
            ),
            Marker(
              width: 80.0,
              height: 80.0,
              point: latLng.LatLng(destinationAdd.lat, destinationAdd.long),
              builder: (ctx) => Container(
                  child: Icon(
                Icons.directions_bus,
                color: mypink,
                size: 45,
              )),
            ),
          ],
        ),
        PolylineLayerOptions(polylines: [
          Polyline(
            points: points,
            strokeWidth: 5.0,
            color: Colors.blue,
          )
        ])
      ],
    );
  }
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  @override
  void initState() {
    super.initState();
    currLatLng = latLng.LatLng(31.947351, 35.227163);
    destinationAdd.lat = currLatLng.latitude;
    destinationAdd.long = currLatLng.longitude;
    setupPositionLocator();
  }
}
