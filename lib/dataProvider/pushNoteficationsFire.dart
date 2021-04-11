import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:OtoBus/configMaps.dart';

class PushNotifications {
  final FirebaseMessaging fireMess = FirebaseMessaging();
  Future initialize() async {
    fireMess.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
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
}
