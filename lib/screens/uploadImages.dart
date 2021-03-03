import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;
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

  File _idcard, _license;
  String _idcardname, _licensename;
  final picker = ImagePicker();
  var byt1, byt2;
  String base64idcard, base64license = "";

  Future upIm1() async {
    var picked = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _idcard = File(picked.path);
    });
  }

  Future upIm2() async {
    var picked = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _license = File(picked.path);
    });
  }

  Future upload(File im1, String fname1, File im2, String fname2) async {
    byt1 = Io.File(im1.path).readAsBytesSync();
    byt2 = Io.File(im2.path).readAsBytesSync();
    base64idcard = base64Encode(byt1);
    base64license = base64Encode(byt2);
    String url = "http://192.168.1.107:8089/otobus/phpfiles/regdriver.php";
    var response = await http.post(url, body: {
      'idcardimg': base64idcard,
      'idcardname': fname1,
      'licenseimg': base64license,
      'licensename': fname2,
      'busId': busId,
      'numpass': numpass,
      'type': type,
    });
    print(response.body);
    //if(response.body==200){}else{//error}
  }

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
              "استكمال التسجيل",
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
                icon: Icons.directions_bus,
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
                icon: Icons.money,
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
              maxLength: 2,
              keyboardType: TextInputType.number,
              controller: _numpass, //set username controller
              style: TextStyle(color: Colors.green[100], fontSize: 20),
              decoration: myInputDecoration(
                label: "عدد الركاب",
                icon: Icons.people,
              ),
              onChanged: (value) {
                //set username  text on change
                numpass = value;
              },
            ),
          ),
          /*************************************************************/
          IconButton(
              icon: Icon(Icons.camera),
              onPressed: () {
                upIm1();
              }),
          Container(
            child: _idcard == null
                ? Text(
                    'لم يتم رفع الصورة',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                      fontFamily: 'Lemonada',
                    ),
                  )
                : Image.file(_idcard),
          ),

          /*************************************************************/
          IconButton(
              icon: Icon(Icons.camera),
              onPressed: () {
                upIm2();
              }),
          Container(
            child: _license == null
                ? Text(
                    'لم يتم رفع الصورة',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                      fontFamily: 'Lemonada',
                    ),
                  )
                : Image.file(_license),
          ),
          /*************************************************************/

          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(top: 20),
            child: SizedBox(
              height: 60,
              width: double.infinity,
              child: RaisedButton(
                onPressed: () {
                  _idcardname = _idcard.path.split('/').last;
                  _licensename = _license.path.split('/').last;
                  upload(_idcard, _idcardname, _license, _licensename); //
                },
                child: Text(
                  "إنشاء حساب",
                  style: TextStyle(fontSize: 20, fontFamily: 'Lemonada'),
                ),
                // if showprogress == true then show progress indicator
                // else show "LOGIN NOW" text
                colorBrightness: Brightness.dark,
                color: apcolor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)
                    //button corner radius
                    ),
              ),
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
        fontSize: 15,
        fontFamily: 'Lemonada',
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
