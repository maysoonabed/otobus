import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import 'SignupPage.dart';
import 'package:image_picker/image_picker.dart';

class UploadImages extends StatefulWidget {
  @override
  _UploadImagesState createState() => _UploadImagesState();
}

class _UploadImagesState extends State<UploadImages> {
  String busId, numpass, type;
  var _busId = TextEditingController();
  var _numpass = TextEditingController();
  var _type = TextEditingController();

  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent
            //color set to transperent or set your own color
            ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.red,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        //   backgroundColor: Color(0x44000000),
        elevation: 0,
      ),
      body: SingleChildScrollView(
          child: Container(
        constraints:
            BoxConstraints(minHeight: MediaQuery.of(context).size.height
                //set minimum height equal to 100% of VH
                ),
        width: MediaQuery.of(context).size.width,
        //make width of outer wrapper to 100%
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: myGradients1,
          ),
        ), //show linear gradient background of page

        padding: EdgeInsets.all(20),
        child: Column(children: <Widget>[
          /*************************************************************/
          Container(
            margin: EdgeInsets.only(top: 80),
            child: Text(
              "أوراق مطلوبة",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontFamily: 'Lemonada', //'ArefRuqaaR',
                  fontWeight: FontWeight.bold),
            ), //title text
          ),

          /*************************************************************/
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            margin: EdgeInsets.only(top: 10),
            child: TextField(
              textAlign: TextAlign.center,
              controller: _type, //set username controller
              style: TextStyle(color: Colors.green[100], fontSize: 20),
              decoration: myInputDecoration(
                label: "نوع الباص",
                icon: Icons.email,
              ),
              onChanged: (value) {
                //set username  text on change
                type = value;
              },
            ),
          ),
          /*************************************************************/
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            margin: EdgeInsets.only(top: 10),
            child: TextField(
              textAlign: TextAlign.center,
              controller: _busId, //set username controller
              style: TextStyle(color: Colors.green[100], fontSize: 20),
              decoration: myInputDecoration(
                label: "لوحة التسجيل",
                icon: Icons.email,
              ),
              onChanged: (value) {
                //set username  text on change
                busId = value;
              },
            ),
          ),
          /*************************************************************/

          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            margin: EdgeInsets.only(top: 10),
            child: TextField(
              textAlign: TextAlign.center,
              controller: _numpass, //set username controller
              style: TextStyle(color: Colors.green[100], fontSize: 20),
              decoration: myInputDecoration(
                label: "عدد الركاب",
                icon: Icons.email,
              ),
              onChanged: (value) {
                //set username  text on change
                numpass = value;
              },
            ),
          ),
          /*************************************************************/
        ]),
      )),
    );
  }

  InputDecoration myInputDecoration({String label, IconData icon}) {
    return InputDecoration(
      hintText: label, //show label as placeholder
      alignLabelWithHint: true,
      //prefixText: '+97',
      hintStyle: TextStyle(
        color: Colors.white.withOpacity(0.4),
        fontSize: 20,
      ), //hint text style
      suffixIcon: Padding(
          padding: EdgeInsets.only(left: 20, right: 10),
          child: Icon(
            icon,
            color: Colors.white,
          )
          //padding and icon for prefix
          ),

      contentPadding: EdgeInsets.fromLTRB(30, 15, 0, 15),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide:
              BorderSide(color: apcolor, width: 1)), //default border of input

      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(color: Colors.white, width: 1)),

      //focus border
      fillColor: apcolor,
      filled: false, //set true if you want to show input background
    );
  }
}