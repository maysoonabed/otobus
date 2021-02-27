import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String name, email, password, phone;
  String errormsg;
  bool error, showprogress;
  var _name = TextEditingController();
  var _email = TextEditingController();
  var _password = TextEditingController();
  var _phone = TextEditingController();
  startLogin() async {
    String apiurl = "http://10.0.0.15/otobus/regpass.php";

    var response = await http.post(apiurl, body: {
      'name': name, //get the username text
      'email': email,
      'phone': phone,
      'password': password //get password text
    });

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      if (jsondata["error"]) {
        setState(() {
          showprogress = false; //don't show progress indicator
          error = true;
          errormsg = jsondata["message"];
        });
      } else {
        if (jsondata["success"]) {
          setState(() {
            error = false;
            showprogress = false;
          });
        } else {
          showprogress = false; //don't show progress indicator
          error = true;
          errormsg = "Something went wrong.";
        }
      }
    } else {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Error during connecting to server.";
      });
    }
  }

  @override
  void initState() {
    name = "";
    email = "";
    phone = "";
    password = "";
    errormsg = "";
    error = false;
    showprogress = false;

    //_name.text = "defaulttext";
    //_password.text = "defaultpassword";
    super.initState();
  }

  @override
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
            colors: [
              Colors.green,
              Colors.lightGreenAccent,
              Colors.grey,
              Colors.lightGreen,
            ],
          ),
        ), //show linear gradient background of page

        padding: EdgeInsets.all(20),
        child: Column(children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 80),
            child: Text(
              "إنشاء حساب جديد",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontFamily: 'Lemonade',
                  fontWeight: FontWeight.bold),
            ), //title text
          ),
          /* Container(
            margin: EdgeInsets.only(top: 10),
            child: Text(
              "",
              style: TextStyle(color: Colors.white, fontSize: 15),
            ), //subtitle text
          ), */
          Container(
            //show error message here
            margin: EdgeInsets.only(top: 30),
            padding: EdgeInsets.all(10),
            child: error ? errmsg(errormsg) : Container(),
            //if error == true then show error message
            //else set empty container as child
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            margin: EdgeInsets.only(top: 10),
            child: TextField(
              controller: _name, //set username controller
              style: TextStyle(color: Colors.green[100], fontSize: 20),
              decoration: myInputDecoration(
                label: "اسم المستخدم",
                icon: Icons.person,
              ),
              onChanged: (value) {
                //set username  text on change
                name = value;
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            margin: EdgeInsets.only(top: 10),
            child: TextField(
              controller: _phone, //set username controller
              style: TextStyle(color: Colors.green[100], fontSize: 20),
              decoration: myInputDecoration(
                label: "رقم الهاتف",
                icon: Icons.phone_android,
              ),
              onChanged: (value) {
                //set username  text on change
                phone = value;
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            margin: EdgeInsets.only(top: 10),
            child: TextField(
              controller: _email, //set username controller
              style: TextStyle(color: Colors.green[100], fontSize: 20),
              decoration: myInputDecoration(
                label: "البريد الإلكتروني",
                icon: Icons.email,
              ),
              onChanged: (value) {
                //set username  text on change
                email = value;
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _password, //set password controller
              style: TextStyle(color: Colors.green[100], fontSize: 20),
              obscureText: true,
              decoration: myInputDecoration(
                label: "كلمة السر",
                icon: Icons.lock,
              ),
              onChanged: (value) {
                // change password text
                password = value;
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(top: 20),
            child: SizedBox(
              height: 60,
              width: double.infinity,
              child: RaisedButton(
                onPressed: () {
                  setState(() {
                    //show progress indicator on click
                    showprogress = true;
                  });
                  startLogin();
                },
                child: showprogress
                    ? SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.green[100],
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.lightGreenAccent),
                        ),
                      )
                    : Text(
                        "إنشاء حساب",
                        style: TextStyle(fontSize: 20, fontFamily: 'Lemonade'),
                      ),
                // if showprogress == true then show progress indicator
                // else show "LOGIN NOW" text
                colorBrightness: Brightness.dark,
                color: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)
                    //button corner radius
                    ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(top: 20),
            child: InkResponse(
                onTap: () {
                  //action on tap
                },
                child: Text(
                  "لديك حساب؟ سجل الدخول",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                )),
          )
        ]),
      )),
    );
  }

  InputDecoration myInputDecoration({String label, IconData icon}) {
    return InputDecoration(
      hintText: label, //show label as placeholder
      hintStyle:
          TextStyle(color: Colors.green[100], fontSize: 20), //hint text style
      suffixIcon: Padding(
          padding: EdgeInsets.only(left: 20, right: 10),
          child: Icon(
            icon,
            color: Colors.green[100],
          )
          //padding and icon for prefix
          ),

      contentPadding: EdgeInsets.fromLTRB(111, 20, 30, 20),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
              color: Colors.green[300], width: 1)), //default border of input

      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide:
              BorderSide(color: Colors.green[200], width: 1)), //focus border

      fillColor: Color.fromRGBO(55, 140, 0, 0.5),
      filled: true, //set true if you want to show input background
    );
  }

  Widget errmsg(String text) {
    //error message widget.
    return Container(
      padding: EdgeInsets.all(15.00),
      margin: EdgeInsets.only(bottom: 10.00),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.red,
          border: Border.all(color: Colors.red[300], width: 2)),
      child: Row(children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 6.00),
          child: Icon(Icons.info, color: Colors.white),
        ), // icon for error message

        Text(text, style: TextStyle(color: Colors.white, fontSize: 18)),
        //show error message text
      ]),
    );
  }
}
