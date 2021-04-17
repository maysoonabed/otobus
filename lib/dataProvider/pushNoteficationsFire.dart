import 'dart:io';

import 'package:OtoBus/dataProvider/tripInfo.dart';
import 'package:OtoBus/screens/NotificationsDialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:OtoBus/configMaps.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

final FirebaseMessaging fireMess = FirebaseMessaging();

class PushNotifications {
  Future initialize(context) async {
    fireMess.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        fetchInfo(message, context);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        fetchInfo(message, context);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        fetchInfo(message, context);
      },
    );
  }

  Future<String> getToken() async {
    String token = await fireMess.getToken();
    print('token:$token');
    DatabaseReference tokenRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currUser.uid}/token');
    tokenRef.set(token);
    fireMess
        .subscribeToTopic('toAllDrivers'); //عشان نبعت نوتيفيكيشين لكل الدرايفرز
    fireMess.subscribeToTopic('toAllUsers');
  }

  void fetchInfo(Map<String, dynamic> message, context) {
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
    String rideId;
    DatabaseReference rideRef;
    if (Platform.isAndroid) {
      rideId = message['data']['riderequest_id'];
    } else {
      rideId = message['riderequest_id'];
    }
    print('ride id:$rideId');

    rideRef =
        FirebaseDatabase.instance.reference().child('rideRequest/$rideId');
    rideRef.once().then((DataSnapshot snapshot) {
      Navigator.pop(context);
      if (snapshot.value != null) {
        double pickUpLat =
            double.parse(snapshot.value['location']['latitude'].toString());
        double pickUpLong =
            double.parse(snapshot.value['location']['longitude'].toString());
        String pickUpAdd = snapshot.value['pickUpAddress'].toString();
        double destLat =
            double.parse(snapshot.value['destination']['latitude'].toString());
        double destLong =
            double.parse(snapshot.value['destination']['longitude'].toString());
        String desAdd = snapshot.value['destinationAddress'].toString();
        TripInfo tripInfo = TripInfo();
        tripInfo.ridrReqId = rideId;
        tripInfo.destAdd = desAdd;
        tripInfo.pickUpAdd = pickUpAdd;
        tripInfo.dest = LatLng(destLat, destLong);
        tripInfo.pickUp = LatLng(pickUpLat, pickUpLong);
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) =>
                NotificationsDialog(trip: tripInfo));
      }
    });
  }
}
