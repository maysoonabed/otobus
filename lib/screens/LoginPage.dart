import 'package:flutter/material.dart';
import '../main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //لإخفاء شريط depug
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Login",
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
