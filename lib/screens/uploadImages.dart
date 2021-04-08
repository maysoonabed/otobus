import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import 'LoginPage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class UploadImages extends StatefulWidget {
  UploadImages(this.name, this.phone, this.email, this.pass);

  final String name;
  final String email;
  final String phone;
  final String pass;

  @override
  _UploadImagesState createState() => _UploadImagesState();
}

class _UploadImagesState extends State<UploadImages> {
  final _formKey = GlobalKey<FormState>();

  String busId, numpass, type;
  var _busId = TextEditingController();
  var _numpass = TextEditingController();
  var _type = TextEditingController();
  var items = ['باص أبيض', 'باص أصفر'];

  File _idcard, _license;
  String _idcardname, _licensename;
  final picker = ImagePicker();
  var byt1, byt2;
  String base64idcard, base64license = "";
  String errormsg = "";
  bool error = false;
  bool showprogress = false;

  void regFire() async {
    final User user = (await _auth.createUserWithEmailAndPassword(
      email: widget.email,
      password: widget.pass,
    ))
        .user;
    if (user != null) {
      DatabaseReference newUser =
          FirebaseDatabase.instance.reference().child('Drivers/${user.uid}');
      Map userMap = {
        'phone': widget.phone,
      };
      newUser.set(userMap);
      print('registFFFire');
    } else
      print('regFFFFAAAAAAIIIILLL');
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: Text(
                      "تم التسجيل بنجاح",
                      style: TextStyle(fontSize: 24.0),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText:
                            "سيتم إرسال بريد إلكتروني حال موافقة الآدمن, يرجى الانتظار",
                        border: InputBorder.none,
                      ),
                      maxLines: 5,
                    ),
                  ),
                  InkWell(
                    child: Container(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF1abc9c),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32.0),
                            bottomRight: Radius.circular(32.0)),
                      ),
                      child: Text(
                        "حسنًا",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Lemonada', //'ArefRuqaaR',
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

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
    String url =
        "http://192.168.1.107:8089/otobus/phpfiles/regdriver.php"; //10.0.0.8//192.168.1.107:8089
    var response = await http.post(url, body: {
      'busId': busId,
      'numpass': numpass,
      'type': type,
      'idcardimg': base64idcard,
      'idcardname': fname1,
      'licenseimg': base64license,
      'licensename': fname2,
      'name': widget.name, //get the username text
      'email': widget.email,
      'phone': widget.phone,
      'password': widget.pass, //get password text
    });
    print(response.body);
    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body); //json.decode
      if (jsondata["error"] == 1) {
        setState(() {
          showprogress = false;
          error = true;
          errormsg = jsondata["message"];
        });
      } else {
        if (jsondata["value"] == 1) {
          regFire();
          setState(() {
            error = false;
            showprogress = false;
            _showMyDialog();
          });
        } else {
          setState(() {
            showprogress = false;
            error = true;
            errormsg = "هناك مشكلة في الاتصال بالسيرفر";
          });
        }
      }
    }
  }

  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent
            //color set to transperent or set your own color
            ));

    return Scaffold(
      extendBodyBehindAppBar: true,
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
              child: Form(
                key: _formKey,
                child: Column(
                    /*   mainAxisAlignment:
                MainAxisAlignment.center, //Center Column contents vertically,
            crossAxisAlignment:
                CrossAxisAlignment.start, //Center Column contents horizontally,
          */
                    children: <Widget>[
                      /*************************************************************/
                      Container(
                        margin: EdgeInsets.only(top: 50),
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
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.all(10),
                        child: error ? errmsg(errormsg) : Container(),
                      ),
                      /*************************************************************/
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.only(top: 10),
                        child: TextField(
                          textAlign: TextAlign.center,
                          controller: _busId, //set username controller
                          style:
                              TextStyle(color: Colors.green[100], fontSize: 20),
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
                          style:
                              TextStyle(color: Colors.green[100], fontSize: 20),
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
                      Container(
                        child: new Column(
                          children: [
                            new Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                      child: new TextField(
                                    readOnly: true,
                                    controller: _type,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.green[100], fontSize: 20),
                                    decoration: myInputDecoration(
                                      label: "نوع الباص",
                                      icon: Icons.directions_bus,
                                    ),
                                    onChanged: (value) {
                                      //set username  text on change
                                      type = value;
                                    },
                                  )),
                                  new PopupMenuButton<String>(
                                    icon: const Icon(Icons.arrow_drop_down),
                                    onSelected: (String value) {
                                      _type.text = value;
                                      type = value;
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return items.map<PopupMenuItem<String>>(
                                          (String value) {
                                        return new PopupMenuItem(
                                            child: new Text(value),
                                            value: value);
                                      }).toList();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      /*************************************************************/

                      SizedBox(
                        height: 20,
                      ),
                      /*************************************************************/
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, //Center Row contents horizontally,
                        crossAxisAlignment: CrossAxisAlignment
                            .center, //Center Row contents vertically,
                        children: [
                          IconButton(
                              icon: Icon(Icons.camera),
                              onPressed: () {
                                upIm1();
                              }),
                          Container(
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              //  margin: EdgeInsets.only(top: 10),
                              child: Text(
                                "نسخة عن رخصة المركبة",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontFamily: 'Lemonada',
                                ),
                              )),
                        ],
                      ),
                      /*************************************************************/

                      const Divider(
                        height: 10,
                        thickness: 2,
                        indent: 20,
                        color: Color(0xFF1ABC9C),
                        endIndent: 20,
                      ),
                      /*************************************************************/

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
                            : InkResponse(
                                onTap: () async {
                                  await showDialog(
                                      context: context,
                                      builder: (_) => ImageDialog(_idcard));
                                },
                                child: Text(
                                  "معاينة الصورة؟",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 10,
                                    fontFamily: 'Lemonada',
                                  ), //
                                ),
                              ),
                      ),

                      /*************************************************************/
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, //Center Row contents horizontally,
                        crossAxisAlignment: CrossAxisAlignment
                            .center, //Center Row contents vertically,
                        children: [
                          IconButton(
                              icon: Icon(Icons.camera),
                              onPressed: () {
                                upIm2();
                              }),
                          Container(
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              //  margin: EdgeInsets.only(top: 10),
                              child: Text(
                                "نسخة عن رخصة القيادة ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontFamily: 'Lemonada',
                                ),
                              )),
                        ],
                      ),
                      /*************************************************************/

                      const Divider(
                        height: 10,
                        thickness: 2,
                        indent: 20,
                        color: Color(0xFF1ABC9C),
                        endIndent: 20,
                      ),
                      /*************************************************************/

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
                            :
                            //Image.file(_license),
                            InkResponse(
                                onTap: () async {
                                  await showDialog(
                                      context: context,
                                      builder: (_) => ImageDialog(_license));
                                },
                                child: Text(
                                  "معاينة الصورة؟",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 10,
                                    fontFamily: 'Lemonada',
                                  ), //
                                ),
                              ),
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
                              if (numpass == "" ||
                                  busId == "" ||
                                  type == "" ||
                                  _idcard == null ||
                                  _license == null) {
                                setState(() {
                                  showprogress = false;
                                  error = true;
                                  errormsg = 'الرجاء تعبئة كافة البيانات';
                                });
                              } else {
                                setState(() {
                                  showprogress = true;
                                });
                                _idcardname = _idcard.path.split('/').last;
                                _licensename = _license.path.split('/').last;
                                upload(_idcard, _idcardname, _license,
                                    _licensename);
                              }
                            },
                            child: Text(
                              "إنشاء حساب",
                              style: TextStyle(
                                  fontSize: 20, fontFamily: 'Lemonada'),
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
              ))),
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

  Widget errmsg(String text) {
    return Container(
      padding: EdgeInsets.all(15.00),
      margin: EdgeInsets.only(bottom: 10.00),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
          border: Border.all(color: Colors.red[300], width: 2)),
      child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, //Center Row contents horizontally,
          crossAxisAlignment:
              CrossAxisAlignment.center, //Center Row contents vertically,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 6.00),
              child: Icon(Icons.info, color: Colors.red),
            ), // icon for error message

            Text(text, style: TextStyle(color: Colors.red, fontSize: 18)),
            //show error message text
          ]),
    );
  }
}

class ImageDialog extends StatelessWidget {
  ImageDialog(this.image);
  final File image;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 200,
        height: 400,
        decoration: BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
                image: ExactAssetImage(image.path), fit: BoxFit.scaleDown)),
      ),
    );
  }
}
