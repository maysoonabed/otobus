import 'package:OtoBus/configMaps.dart';
import 'package:OtoBus/dataProvider/tripInfo.dart';
import 'package:OtoBus/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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
            SizedBox(height: 30),
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
      } else if (thisRideId == 'cancelled') {
        print("ride has been cancelled");
      } else if (thisRideId == 'timeout') {
        print("ride has timed out");
      } else {
        print('ride not fount');
      }
    });
  }
}
