import 'package:flutter/material.dart';
import '../main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: new Container(
        alignment: Alignment.bottomCenter,
        color: Colors.white,
        width: double.infinity,
        child: ListView(
          children: [
            SizedBox(
              height: 100.0,
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: myGradients4),
                  borderRadius: BorderRadius.circular(20.0)
                  /*boxShadow: new BoxShadow(
                    color: Colors.red,
                      offset: new Offset(20.0, 10.0),
                   )*/
                  ),
              child: TextField(
                  //controller: _username,
                  style: TextStyle(
                      color: Colors.white,
                      /*fontFamily: ArefRuqaa,*/ fontSize: 20),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: "رقم الهاتف",
                    labelStyle: TextStyle(
                      color: Colors.white,
                    ),
                  )),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: myGradients4),
                  borderRadius: BorderRadius.circular(20.0)),
              child: TextField(
                  //controller: _password,
                  style: TextStyle(
                      color: Colors.white,
                      /*fontFamily: ArefRuqaa,*/ fontSize: 20),
                  //textAlign: TextAlign.right,
                  obscureText: true,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    border: InputBorder.none,
                    labelText: ("كلمة السر"),
                    labelStyle: TextStyle(
                      color: Colors.white,
                    ),
                    alignLabelWithHint: false,
                  )),
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
