import 'package:OtoBus/configMaps.dart';
import 'package:OtoBus/screens/DriverMap.dart';
import 'package:OtoBus/screens/PassengerMap.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'dart:math' show cos, sqrt, asin;

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

}
