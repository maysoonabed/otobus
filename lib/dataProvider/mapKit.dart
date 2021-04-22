import 'package:maps_toolkit/maps_toolkit.dart';

class MapKit {
  static double getMarkerRotation(sLat, sLong, dLat, dLong) {
    var rotation =
        SphericalUtil.computeHeading(LatLng(sLat, sLong), LatLng(dLat, dLong));
    return rotation;
  }
}
