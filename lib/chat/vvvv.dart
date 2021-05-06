final FirebaseMessaging fireMess = FirebaseMessaging();
//*********************************************************/
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
  /* fireMess.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true)); */
}

//*********************************************************/
Future<String> getToken() async {
  String token = await fireMess.getToken();
  print('token:$token');
  DatabaseReference tokenRef = FirebaseDatabase.instance
      .reference()
      .child('Drivers/${currUser.uid}/token');
  tokenRef.set(token);
  fireMess
      .subscribeToTopic('toAllDrivers'); //عشان نبعت نوتيفيكيشين لكل الدرايفرز
  fireMess.subscribeToTopic('toAllUsers');
}

//*********************************************************/
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

  rideRef = FirebaseDatabase.instance.reference().child('rideRequest/$rideId');
  rideRef.once().then((DataSnapshot snapshot) {
    Navigator.pop(context);

    if (snapshot.value != null) {
      playFile();
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
      int numb = snapshot.value['passengers'];
      tripInfo.ridrReqId = rideId;
      tripInfo.numb = numb;
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

//*********************************************************/
void playFile() async {
  notifPlayer = await cache.play('request_notifi.mp3'); // assign player here
}
//*******************************************************************************************************/
notifyDriver(driver);
 void notifyDriver(NearDrivers driver) {
    driverRef.child(driver.key).child('newTrip').set(rideReq.key);
    driverRef.child(driver.key).child('token').once().then((DataSnapshot snap) {
      if (snap.value != null) {
        String token = snap.value.toString();
        sendNotifToDriver(token, rideReq.key, context);
      } else {
        return;
      }
      const sec = Duration(seconds: 1);
      var timer = Timer.periodic(sec, (timer) {
        if (stat != 'requesting') {
          driverRef.child(driver.key).child('newTrip').set('cancelled');
          driverRef.child(driver.key).child('newTrip').onDisconnect();
          dReqTimeout = 10;
          timer.cancel();
        }
        dReqTimeout = dReqTimeout - 1;
        driverRef.child(driver.key).child('newTrip').onValue.listen((event) {
          if (event.snapshot.value.toString() == 'accepted') {
            //     driverRef.child(driver.key).child('newTrip').set('waiting');
            driverRef.child(driver.key).child('newTrip').onDisconnect();
            dReqTimeout = 10;
            timer.cancel();
          }
        });
        if (dReqTimeout == 0) {
          driverRef.child(driver.key).child('newTrip').set('timeout');
          driverRef.child(driver.key).child('newTrip').onDisconnect();
          dReqTimeout = 10;
          timer.cancel();
          searchNearestDriver();
        }
      });
    });
  }
//*********************************************************/
void sendNotifToDriver(String token, String rideReqId, context) async {
    var destin =
        Provider.of<AppData>(context, listen: false).destinationAddress;
    Map<String, String> headerMap = {
      'Content-Type': 'application/json',
      'Authorization': serverToken,
    };
    Map notificationMap = {
      'body': '${destin.placeName} إلى ',
      'title': 'طلب توصيلة جديد'
    };
    Map dataMap = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'riderequest_id': rideReqId,
    };
    Map sendNotificationMao = {
      "notification": notificationMap,
      "data": dataMap,
      'priority': 'high',
      'to': token,
    };
    var respon = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: headerMap,
      body: jsonEncode(sendNotificationMao),
    );
  }
//*********************************************************/
