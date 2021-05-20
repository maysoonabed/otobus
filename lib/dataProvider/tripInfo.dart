import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripInfo {
  String destAdd;
  String pickUpAdd;
  LatLng pickUp;
  LatLng dest;
  int numb;
  String ridrReqId;
  String riderPhone;
  String passPhone;
  TripInfo(
      {this.dest,
      this.destAdd,
      this.pickUp,
      this.pickUpAdd,
      this.riderPhone,
      this.ridrReqId,
      this.numb,
      this.passPhone});
}
