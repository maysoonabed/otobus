import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

final FirebaseMessaging fireMess = FirebaseMessaging();

class NotificChat {
  Future initialize(context) async {
    fireMess.configure(
      onMessage: (Map<String, dynamic> message) async {
        //print("onMessage: $message");
        fetchInfo(message, context);
      },
      onLaunch: (Map<String, dynamic> message) async {
        //print("onLaunch: $message");
        fetchInfo(message, context);
      },
      onResume: (Map<String, dynamic> message) async {
        //print("onResume: $message");
        fetchInfo(message, context);
      },
    );
    fireMess.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    FlutterRingtonePlayer.play(
      android: AndroidSounds.notification,
      ios: IosSounds.glass,
      looping: true, // Android only - API >= 28
      volume: 0.1, // Android only - API >= 28
      asAlarm: false, // Android only - all APIs
    );
  }

  void fetchInfo(Map<String, dynamic> message, context) {
    /* showDialog(
      context: context,
      builder: (BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[],
      ),
    ); */
  }
}
