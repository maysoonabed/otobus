import 'package:OtoBus/configMaps.dart';
import 'package:OtoBus/screens/DriverMap.dart';
import 'package:OtoBus/screens/PassengerMap.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:maps_toolkit/maps_toolkit.dart';

class Funcs {
  static void disbleLocUpdate() {
    posStream.pause();
    Geofire.removeLocation(currUser.uid);
  }

  static void enableLocUpdate() {
    posStream.resume();
    Geofire.setLocation(
        currUser.uid, currentPosition.latitude, currentPosition.longitude);
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  static void checkPoint(double tLat, double tLng, double fLat, double fLng,
      double pLat, double pLng) async {
    List<LatLng> pCoor = [];

    PolylinePoints pp = PolylinePoints();

    PolylineResult result = await pp.getRouteBetweenCoordinates(
      "AIzaSyDpIlaxbh4WTp4_Ecnz4lupswaRqyNcTv4",
      PointLatLng(fLat, fLng),
      PointLatLng(tLat, tLng),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        pCoor.add(LatLng(point.latitude, point.longitude));
      });
      pCoor.add(LatLng(tLat, tLng));
      pCoor.add(LatLng(fLat, fLng));
      bool x = PolygonUtil.isLocationOnEdge(LatLng(pLat, pLng), pCoor, true);
      bool y = PolygonUtil.isLocationOnPath(LatLng(pLat, pLng), pCoor, true);

      chP = x ||
          y; 
      print(chP.toString() + ' ' + x.toString()+' '+y.toString());
    }
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void sort() {}
}
