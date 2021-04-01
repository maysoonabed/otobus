import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class Fire extends StatefulWidget {
  @override
  _FireState createState() => _FireState();
}

class _FireState extends State<Fire> {
  Future<void> fire() async {
    WidgetsFlutterBinding.ensureInitialized();
    final FirebaseApp app = await Firebase.initializeApp(
      name: 'db2',
      options: Platform.isIOS || Platform.isMacOS
          ? const FirebaseOptions(
              appId: '1:297855924061:ios:c6de2b69b03a5be8',
              apiKey: 'AIzaSyD_shO5mfO9lhy2TVWhfo1VUmARKlG4suk',
              projectId: 'flutter-firebase-plugins',
              messagingSenderId: '297855924061',
              databaseURL: 'https://flutterfire-cd2f7.firebaseio.com',
            )
          : const FirebaseOptions(
              appId: '1:307201306561:android:c30270fe3d23239cc48940',
              apiKey: 'AIzaSyCqdqCzX70psNUfuYi6i8Q2Sgtz-6tK5cs',
              messagingSenderId: '297855924061',
              projectId: 'otobus-11914',
              databaseURL: 'https://otobus-11914-default-rtdb.firebaseio.com',
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'hi',
        home: Scaffold(
          appBar: AppBar(
            title: Text('FIRE'),
          ),
          body: Center(
            child: MaterialButton(
              onPressed: () {
                DatabaseReference df =
                    FirebaseDatabase.instance.reference().child('Samah');
                df.set('Tobasi');
              },
              height: 50,
              minWidth: 300,
              color: Colors.green,
              child: Text('Test'),
            ),
          ),
        ));
  }
}
