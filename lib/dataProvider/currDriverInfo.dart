import 'package:google_maps_flutter/google_maps_flutter.dart';

class CurrDriverInfo {
  String name, email, phone, begN, endN, busType;
  LatLng endLoc, begLoc;
  int numOfPass;
  CurrDriverInfo(
      {this.name,
      this.phone,
      this.email,
      this.begLoc,
      this.begN,
      this.endLoc,
      this.endN,
      this.busType,
      this.numOfPass});
}
