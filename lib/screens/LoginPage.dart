import 'dart:convert';

import 'package:OtoBus/screens/PassengerMap.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import 'DriverMap.dart';
import 'SignupPage.dart';

int id = 1;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String password, phone;
  String errormsg;
  bool error, showprogress;
  TextEditingController _password = TextEditingController();
  TextEditingController _phone = TextEditingController();
  bool _obscureText = true;

  startLogin() async {
    String apiurl = "http://192.168.1.107:8089/otobus/login.php"; //10.0.0.15

    var response = await http.post(apiurl, body: {
      'phone': phone,
      'password': password,
      'id': id.toString(),
    });
    //print(phone + password + id.toString());
    //print(response.statusCode);
    //print(response.body);
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
          setState(() {
            error = false;
            showprogress = false;
          });
          if (id == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PassengerMap()));
          } else {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => DriverMap()));
          }
        }
      }
    } else {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "هناك مشكلة في الاتصال بالسيرفر";
      });
    }
  }

  @override
  void initState() {
    phone = "";
    password = "";
    errormsg = "";
    error = false;
    showprogress = false;
    super.initState();
  }

  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent
            //color set to transperent or set your own color
            ));

    return Scaffold(
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
            child: Column(children: <Widget>[
              /*************************************************************/
              Container(
                margin: EdgeInsets.only(top: 60),
                child: Text(
                  "تسجيل الدخول",
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
                child: TextFormField(
                  textAlign: TextAlign.center,
                  controller: _phone,
                  maxLength: 13,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Lemonada'),
                  keyboardType: TextInputType.number,
                  decoration: myInputDecoration(
                    label: "رقم الهاتف",
                    icon: Icons.phone_android,
                  ),
                  onChanged: (value) {
                    phone = value;
                  },
                  validator: (phone) {
                    if (phone.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
              ),
              /*************************************************************/
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: _password,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Lemonada'),
                  obscureText: _obscureText,
                  decoration: myPasswordDecoration(
                    label: "كلمة السر",
                    icon: Icons.lock,
                  ),
                  onChanged: (value) {
                    password = value;
                  },
                ),
              ),
              /*************************************************************/
              RadioGroup(),
              /*************************************************************/
              Container(
                padding: EdgeInsets.all(10),
                // margin: EdgeInsets.only(top: 20),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () {
                      setState(() {
                        showprogress = true;
                      });
                      startLogin();
                    },
                    child: showprogress
                        ? SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(
                              backgroundColor: apcolor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.lightGreenAccent),
                            ),
                          )
                        : Text(
                            "تسجيل الدخول",
                            style:
                                TextStyle(fontSize: 20, fontFamily: 'Lemonada'),
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
              Container(
                padding: EdgeInsets.all(10),
                //margin: EdgeInsets.only(top: 20),
                child: InkResponse(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupPage()));
                    },
                    child: Text(
                      "ليس لديك حساب؟ إنشاء حساب جديد",
                      style: TextStyle(
                          color: Colors.white, //ba2color,
                          fontSize: 15,
                          fontFamily: 'Lemonada'), //
                    )),
              )
            ])),
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
          fontFamily: 'Lemonada'), //hint text style
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

  InputDecoration myPasswordDecoration({String label, IconData icon}) {
    return InputDecoration(
      hintText: label, //show label as placeholder
      alignLabelWithHint: true,
      //prefixText: '+97',
      hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 20,
          fontFamily: 'Lemonada'), //hint text style
      suffixIcon: Padding(
          padding: EdgeInsets.only(left: 20, right: 10),
          child: Icon(
            icon,
            color: Colors.white,
          )
          //padding and icon for prefix
          ),

      ///************************
      prefixIcon: GestureDetector(
        onTap: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        child: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: Colors.white,
        ),
      ),

      ///************************
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

class RadioGroup extends StatefulWidget {
  @override
  RadioGroupWidget createState() => RadioGroupWidget();
}

class RadioGroupWidget extends State {
  // Default Radio Button Selected Item When App Starts.
  String radioButtonItem = 'passenger';

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        /*  Padding(
            padding: EdgeInsets.all(14.0),
            child: Text('Selected Radio Item = ' + '$id',
                style: TextStyle(fontSize: 21))),
                */
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Radio(
              toggleable: true,
              activeColor: apcolor,
              value: 1,
              groupValue: id,
              onChanged: (val) {
                setState(() {
                  radioButtonItem = 'driver';
                  id = 1;
                });
              },
            ),
            Text(
              'سائق',
              style: new TextStyle(
                  fontSize: 17.0, fontFamily: 'Lemonada', color: Colors.white),
            ),
            Radio(
              toggleable: true,
              activeColor: apcolor,
              value: 2,
              groupValue: id,
              onChanged: (val) {
                setState(() {
                  radioButtonItem = 'passenger';
                  id = 2;
                });
              },
            ),
            Text(
              'راكب',
              style: new TextStyle(
                  fontSize: 17.0, fontFamily: 'Lemonada', color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
