import 'dart:convert';
import 'dart:io';
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
  final picker = ImagePicker();

  Future upIm() async {
    var picked = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _idcard = File(picked.path);
    });
  }

  String base64Image =
      "iVBORw0KGgoAAAANSUhEUgAAABEAAAAOCAMAAAD+MweGAAADAFBMVEUAAAAAAFUAAKoAAP8AJAAAJFUAJKoAJP8ASQAASVUASaoASf8AbQAAbVUAbaoAbf8AkgAAklUAkqoAkv8AtgAAtlUAtqoAtv8A2wAA21UA26oA2/8A/wAA/1UA/6oA//8kAAAkAFUkAKokAP8kJAAkJFUkJKokJP8kSQAkSVUkSaokSf8kbQAkbVUkbaokbf8kkgAkklUkkqokkv8ktgAktlUktqoktv8k2wAk21Uk26ok2/8k/wAk/1Uk/6ok//9JAABJAFVJAKpJAP9JJABJJFVJJKpJJP9JSQBJSVVJSapJSf9JbQBJbVVJbapJbf9JkgBJklVJkqpJkv9JtgBJtlVJtqpJtv9J2wBJ21VJ26pJ2/9J/wBJ/1VJ/6pJ//9tAABtAFVtAKptAP9tJABtJFVtJKptJP9tSQBtSVVtSaptSf9tbQBtbVVtbaptbf9tkgBtklVtkqptkv9ttgBttlVttqpttv9t2wBt21Vt26pt2/9t/wBt/1Vt/6pt//+SAACSAFWSAKqSAP+SJACSJFWSJKqSJP+SSQCSSVWSSaqSSf+SbQCSbVWSbaqSbf+SkgCSklWSkqqSkv+StgCStlWStqqStv+S2wCS21WS26qS2/+S/wCS/1WS/6qS//+2AAC2AFW2AKq2AP+2JAC2JFW2JKq2JP+2SQC2SVW2Saq2Sf+2bQC2bVW2baq2bf+2kgC2klW2kqq2kv+2tgC2tlW2tqq2tv+22wC221W226q22/+2/wC2/1W2/6q2///bAADbAFXbAKrbAP/bJADbJFXbJKrbJP/bSQDbSVXbSarbSf/bbQDbbVXbbarbbf/bkgDbklXbkqrbkv/btgDbtlXbtqrbtv/b2wDb21Xb26rb2//b/wDb/1Xb/6rb////AAD/AFX/AKr/AP//JAD/JFX/JKr/JP//SQD/SVX/Sar/Sf//bQD/bVX/bar/bf//kgD/klX/kqr/kv//tgD/tlX/tqr/tv//2wD/21X/26r/2////wD//1X//6r////qm24uAAAA1ElEQVR42h1PMW4CQQwc73mlFJGCQChFIp0Rh0RBGV5AFUXKC/KPfCFdqryEgoJ8IX0KEF64q0PPnow3jT2WxzNj+gAgAGfvvDdCQIHoSnGYcGDE2nH92DoRqTYJ2bTcsKgqhIi47VdgAWNmwFSFA1UAAT2sSFcnq8a3x/zkkJrhaHT3N+hD3aH7ZuabGHX7bsSMhxwTJLr3evf1e0nBVcwmqcTZuatKoJaB7dSHjTZdM0G1HBTWefly//q2EB7/BEvk5vmzeQaJ7/xKPImpzv8/s4grhAxHl0DsqGUAAAAASUVORK5CYII=";
  Future upload(File im) async {
    /*
    var uri = Uri.parse("http://10.0.0.15/otobus/regdriver.php");
    var request = http.MultipartRequest('POST', uri);
    request.fields['name'] = _type.text;
    var pic = await http.MultipartFile.fromPath("image", im.path);
    request.files.add(pic);
    var response = await request.send();
    if (response.statusCode == 200) {
      print("Image Uploaded");
    } else {
      print("Image not Uploaded");
    }
    */
    String url = "http://192.168.1.107:8089/otobus/upim.php";
    var response = await http.post(url, body: {
      'image': base64Image,
      'name': "tttt.png",
    });
    print(response.body);
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
                upIm();
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

          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(top: 20),
            child: SizedBox(
              height: 60,
              width: double.infinity,
              child: RaisedButton(
                onPressed: () {
                  upload(_idcard);
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
