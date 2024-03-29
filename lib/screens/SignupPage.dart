import 'dart:convert';
import 'package:OtoBus/screens/uploadImages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import '../main.dart';
import 'LoginPage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'MapTy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity/connectivity.dart';

int id = 1;
final FirebaseAuth _auth = FirebaseAuth.instance;
final firest = Firestore.instance;

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

enum SingingCharacter { driver, passenger }

class _SignupPageState extends State<SignupPage> {
  //SingingCharacter _character = SingingCharacter.passenger;
  String name, email, password, phone;
  String errormsg;
  bool error, showprogress;
  var _name = TextEditingController();
  var _email = TextEditingController();
  var _password = TextEditingController();
  var _phone = TextEditingController();
  bool _obscureText = true;

  Future pf() {
    showprogress = false;
  }

  void regFire() async {
    final User user = (await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ))
        .user;
    if (user != null) {
      DatabaseReference newUser =
          FirebaseDatabase.instance.reference().child('Passengers/${user.uid}');
      Map userMap = {
        'phone': phone,
      };
      newUser.set(userMap);
      if (email != null) {
        firest
            .collection('users')
            .doc('${user.uid}')
            .set({'email': email, 'name': name, 'token': ""}); //add
      }
      print('registFFFire');
    } else
      print('regFFFFAAAAAAIIIILLL');
  }

  startLogin() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    String apiurl =
        "http://192.168.1.8/otobus/phpfiles/regpass.php"; //10.0.0.8//
    var response = await http.post(apiurl, body: {
      'name': name, //get the username text
      'email': email,
      'phone': phone,
      'password': password, //get password text
    });

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      if (jsondata["error"] == 1) {
        setState(() {
          showprogress = false; //don't show progress indicator
          error = true;
          errormsg = jsondata["message"];
        });
      } else {
        if (jsondata["success"] == 1) {
          setState(() {
            error = false;
            showprogress = false;
          });

          regFire();
          //if(){}else{}
          await FlutterSession().set('passemail', email);
          await FlutterSession().set('name', name);
          await FlutterSession().set('phone', phone);
          FlutterToast(context).showToast(
              child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Colors.greenAccent,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check),
                SizedBox(
                  width: 20.0,
                ),
                Text("أهلاً بك " + name),
              ],
            ),
          ));
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MapTy())); //PassengerPage()
        } else {
          setState(() {
            showprogress = false; //don't show progress indicator
            error = true;
            errormsg = "حدث خطأ";
          });
        }
      }
    } else {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "حدث خطأ أثناء الاتصال بالشبكة";
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
              colors: myGradients1),
        ), //show linear gradient background of page

        padding: EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
            Widget>[
          /*************************************************************/
          Container(
            margin: EdgeInsets.only(top: 30),
            child: Text(
              "إنشاء حساب جديد",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontFamily: 'Lemonada',
                  fontWeight: FontWeight.bold),
            ), //title text
          ),
          /*************************************************************/
          Container(
            //show error message here
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(10),
            child: error ? errmsg(errormsg) : Container(),
            //if error == true then show error message
            //else set empty container as child
          ),
          /*************************************************************/
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            margin: EdgeInsets.only(top: 10),
            child: TextField(
              textAlign: TextAlign.center,
              controller: _name, //set username controller
              style: TextStyle(
                  color: Colors.white, fontSize: 15, fontFamily: 'Lemonada'),
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
          /*************************************************************/
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            margin: EdgeInsets.only(top: 10),
            child: TextField(
              textAlign: TextAlign.center,
              controller: _phone, //set username controller
              keyboardType: TextInputType.number,
              maxLength: 13,
              style: TextStyle(
                  color: Colors.white, fontSize: 15, fontFamily: 'Lemonada'),
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
          /*************************************************************/
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            margin: EdgeInsets.only(top: 10),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              controller: _email, //set username controller
              style: TextStyle(
                  color: Colors.white, fontSize: 15, fontFamily: 'Lemonada'),
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
          /*************************************************************/
          Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              textAlign: TextAlign.center,
              controller: _password, //set password controller
              style: TextStyle(
                  color: Colors.white, fontSize: 15, fontFamily: 'Lemonada'),
              obscureText: _obscureText,
              decoration: myPasswordDecoration(
                label: "كلمة السر, 6 أحرف على الأقل",
                icon: Icons.lock,
              ),
              onChanged: (value) {
                // change password text
                password = value;
              },
            ),
          ),
          /*************************************************************/
          RadioGroup(),
          Container(
            padding: EdgeInsets.all(10),
            //margin: EdgeInsets.only(top: 20),
            child: SizedBox(
              height: 60,
              width: double.infinity,
              child: RaisedButton(
                onPressed: () async {
                  setState(() {
                    //show progress indicator on click
                    showprogress = true;
                  });
                  var conn = await Connectivity().checkConnectivity();

                  bool emailValid = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(email);

                  if (conn != ConnectivityResult.mobile &&
                      conn != ConnectivityResult.wifi) {
                    setState(() {
                      showprogress = false;
                      error = true;
                      errormsg = ' يرجى التحقق من الاتصال بالإنترنت';
                    });
                  } else if (email.isEmpty ||
                      phone.isEmpty ||
                      name.isEmpty ||
                      password.isEmpty) {
                    setState(() {
                      showprogress = false;
                      error = true;
                      errormsg = 'يرجى تعبئة كافة البيانات';
                    });
                  } else if (!emailValid) {
                    setState(() {
                      showprogress = false;
                      error = true;
                      errormsg = 'عنوان البريد الإلكتروني غير صالح';
                    });
                  } else if (password.length < 6) {
                    setState(() {
                      showprogress = false;
                      error = true;
                      errormsg = 'كلمة السر قصيرة';
                    });
                  } else if (id == 2) {
                    startLogin();
                  } else {
                    Navigator.push(
                            context,
                            PageTransition(
                                alignment: Alignment.bottomCenter,
                                curve: Curves.easeInOut,
                                duration: Duration(milliseconds: 600),
                                reverseDuration: Duration(milliseconds: 600),
                                type: PageTransitionType.rightToLeftJoined,
                                child:
                                    UploadImages(name, phone, email, password),
                                childCurrent: SignupPage()))
                        .whenComplete(pf);
                    //setState(() {});
                  }
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
          Container(
            padding: EdgeInsets.all(10),
            //margin: EdgeInsets.only(top: 20),
            child: InkResponse(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginPage())); //action on tap
                },
                child: Text(
                  "لديك حساب؟ سجل الدخول",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Lemonada'),
                )),
          )
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
          fontSize: 14,
          fontFamily: 'Lemonada'), //hint text style
      suffixIcon: Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
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
          _obscureText ? Icons.visibility_off : Icons.visibility,
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
    //error message widget.
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
              //margin: EdgeInsets.only(left: 15.00),
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

  // Group Value for Radio Button.

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        /*    Padding(
            padding: EdgeInsets.all(14.0),
            child: Text('Selected Radio Item = ' + '$id',
                style: TextStyle(fontSize: 21))), */
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
