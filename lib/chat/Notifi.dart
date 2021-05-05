import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'PushNotifc.dart';
import 'package:overlay_support/overlay_support.dart';

class Notifi {
  String currentUserId;
  Notifi({@required this.currentUserId});
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  PushNotific notificationInfo;
  int totalNotifications;

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  void registerNotification() {
    //############################################
    firebaseMessaging.getToken().then((token) {
      //print('token: $token');
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId) //current user id
          .update({'token': token});
    });
    //############################################
    firebaseMessaging.requestNotificationPermissions();
    //############################################
    /*   firebaseMessaging.configure(
        onMessage: (message) async {
          print('onMessage received: $message');

          // Parse the message received
          PushNotific notification = PushNotific.fromJson(message);

          //setState(() {});
          notificationInfo = notification;
          totalNotifications++;
          showSimpleNotification(
            Text(notificationInfo.title),
            //leading: NotificationBadge(totalNotifications: _totalNotifications),
            subtitle: Text(notificationInfo.body),
            background: Colors.cyan[700],
            duration: Duration(seconds: 2),
          );
        },
        onBackgroundMessage: _firebaseMessagingBackgroundHandler,
        onLaunch: (message) async {
          PushNotific notification = PushNotific.fromJson(message);
          //setState(() { });
          notificationInfo = notification;
          totalNotifications++;
        },
        onResume: (message) async {
          print('onResume: $message');
        }); */

    /* firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      //print('onMessage: OONN MMEESSAAGGEE '); //$message
      Platform.isAndroid
          ? showNotification(message['notification'], currentUserId,
              flutterLocalNotificationsPlugin)
          : showNotification(message['aps']['alert'], currentUserId,
              flutterLocalNotificationsPlugin);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    }); */

    /* .catchError((err) {
      FlutterToast(context).showToast(child: Text(err.message.toString()));
    }); */
  }

  void showNotification(var message, String currentUserId,
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'com.example.OtoBus',
      'Flutter chat demo',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    print("hdfgjkjf");
    /*   print(message);

    print(message['body'].toString());
    print(json.encode(message));

    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
 */
//    await flutterLocalNotificationsPlugin.show(
//        0, 'plain title', 'plain body', platformChannelSpecifics,
//        payload: 'item x');
  }
}

Future<dynamic> _firebaseMessagingBackgroundHandler(
  Map<String, dynamic> message,
) async {
  // Initialize the Firebase app
  // await Firebase.initializeApp();
  print('onBackgroundMessage received: $message');
}
