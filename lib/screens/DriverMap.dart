import 'package:flutter/material.dart';
import '../main.dart';

class DriverMap extends StatefulWidget {
  @override
  _DriverMapState createState() => _DriverMapState();
}

class _DriverMapState extends State<DriverMap> {
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
