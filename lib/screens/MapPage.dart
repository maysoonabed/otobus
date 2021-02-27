import 'package:flutter/material.dart';
import '../main.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //لإخفاء شريط depug
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "OtoBüs",
            style: TextStyle(
              fontSize: 25,
              fontFamily: 'Pacifico',
              color: Colors.white,
            ),
          ),
          backgroundColor: apcolor,
        ),
        body: Container(
          alignment: Alignment.bottomCenter,
          color: bacolor,
          width: double.infinity,
        ),
      ),
    );
  }
}
