import 'package:OtoBus/configMaps.dart';
import 'package:OtoBus/dataProvider/tripInfo.dart';
import 'package:OtoBus/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:OtoBus/screens/DriverMap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NotificationsDialog extends StatelessWidget {
  final TripInfo trip;
  NotificationsDialog({this.trip});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30),
            /*   Image.asset(
              'lib/Images/bus.jpg',
              width: 100,
            ), */
            Icon(
              Icons.directions_bus,
              color: myOrange,
              size: 100,
            ),
            SizedBox(height: 16),
            Text(
              'طلب توصيلة',
              style: TextStyle(fontFamily: 'Lemonada', fontSize: 18),
            ),
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                          child: Container(
                              child: Text(trip.pickUpAdd,
                                  style: TextStyle(fontSize: 18)))),
                      SizedBox(height: 18),
                      Icon(
                        Icons.location_on_outlined,
                        color: apBcolor,
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                          child: Container(
                              child: Text(trip.destAdd,
                                  style: TextStyle(fontSize: 18)))),
                      SizedBox(height: 18),
                      Icon(
                        Icons.location_on,
                        color: apBcolor,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Divider(
                    height: 20,
                    thickness: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            child: ElevatedButton(
                                child: Text('رفض',
                                    style: TextStyle(
                                        fontFamily: 'Lemonada', fontSize: 14)),
                                onPressed: () {
                                  notifPlayer.stop();
                                  Navigator.pop(context);
                                },
                                style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                      Color(0xFF159a7f),
                                    ),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                            side: BorderSide(
                                              color: Color(0xFF159a7f),
                                            ))))),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            child: ElevatedButton(
                                child: Text('قبول',
                                    style: TextStyle(
                                        fontFamily: 'Lemonada', fontSize: 14)),
                                onPressed: () {
                                  notifPlayer.stop();
                                  checkAvailability(context);
                                },
                                style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      Color(0xFF159a7f),
                                    ),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                            side: BorderSide(
                                              color: Color(0xFF159a7f),
                                            ))))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkAvailability(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              backgroundColor: Color(0xFF138871),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1fdeb9)),
            ),
          ),
        ],
      ),
    );
    DatabaseReference nRideRef = FirebaseDatabase.instance
        .reference()
        .child('Drivers/${currUser.uid}/newTrip');
    nRideRef.once().then((DataSnapshot snapshot) {
      Navigator.pop(context);
      Navigator.pop(context);

      String thisRideId;
      if (snapshot.value != null) {
        thisRideId = snapshot.value.toString();
      }
      if (thisRideId == trip.ridrReqId) {
        nRideRef.set('accepted');
        putMarker();
      } else if (thisRideId == 'cancelled') {
        Fluttertoast.showToast(
          context,
          msg: "تم الغاء الطلب",
        );
      } else if (thisRideId == 'timeout') {
        Fluttertoast.showToast(
          context,
          msg: "انتهى الوقت",
        );
      } else {
        Fluttertoast.showToast(
          context,
          msg: "لم يتم ايجاد الطلب",
          // backgroundColor: Colors.grey,
          // fontSize: 25
          // gravity: ToastGravity.TOP,
          // textColor: Colors.pink
        );
      }
    });
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  void putMarker() {
    LatLngBounds bounds;
    destltlg = LatLng(destLatitude, destLongitude);
    Marker currMarker = Marker(
        markerId: MarkerId("current"),
        position: currltlg,
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: currName, snippet: 'My Location'));
    Marker destMarker = Marker(
        markerId: MarkerId("destination"),
        position: pickUpLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(90),
        infoWindow: InfoWindow(title: destName, snippet: 'Destination'));
    gMarkers.add(currMarker);
    gMarkers.add(destMarker);

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
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 40,
      center: destltlg,
      fillColor: Colors.green,
    );
    circles.add(currCircle);
    circles.add(destCircle);
    //*************************************//
    if (currltlg.latitude > destltlg.latitude &&
        currltlg.longitude > destltlg.longitude) {
      bounds = LatLngBounds(southwest: destltlg, northeast: currltlg);
    } else if (currltlg.longitude > destltlg.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(currltlg.latitude, destLongitude),
          northeast: LatLng(destLatitude, destltlg.longitude));
    } else if (currltlg.longitude > destltlg.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destltlg.latitude, currltlg.latitude),
          northeast: LatLng(currltlg.longitude, destltlg.longitude));
    } else {
      bounds = LatLngBounds(southwest: currltlg, northeast: destltlg);
    }
    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }
}
